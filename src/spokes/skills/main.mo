import Types "./types";
import Storage "./storage";
import Hub "../../hub/types";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Float "mo:base/Float";

actor SkillSystem {
    // Previous code remains the same...

    private func _calculatePracticeEffectiveness(
        practiceType: Types.PracticeType,
        duration: Nat
    ) : Nat {
        // Base effectiveness by practice type
        let baseEffectiveness = switch (practiceType) {
            case (#Study) { 60 };
            case (#Exercise) { 75 };
            case (#RealWorld) { 90 };
            case (#Teaching) { 85 };
            case (#Collaboration) { 80 };
        };

        // Duration modifier (diminishing returns after 60 minutes)
        let durationModifier = if (duration <= 60) {
            1.0
        } else {
            1.0 + (Float.fromInt(duration - 60) / 120.0) * 0.5
        };

        Nat.min(100, Nat.max(0, 
            Int.abs(Float.toInt(
                Float.fromInt(baseEffectiveness) * durationModifier
            ))
        ))
    };

    private func _calculateExperienceGain(
        effectiveness: Nat,
        duration: Nat
    ) : Nat {
        // Base XP per minute of practice
        let baseXP = 10;
        
        // Apply effectiveness modifier
        let effectiveXP = (baseXP * effectiveness) / 100;
        
        // Calculate total XP for duration
        effectiveXP * duration
    };

    private func _createLearningMemory(
        tokenId: Hub.TokenId,
        skillName: Text,
        context: ?Text
    ) : async Hub.Result<Hub.MemoryId, Hub.Error> {
        let content = switch (context) {
            case (null) { "Started learning " # skillName };
            case (?ctx) { "Started learning " # skillName # ": " # ctx };
        };

        await memory.createMemory({
            tokenId = tokenId;
            content = content;
            strength = 75; // Learning new skills is significant
            timestamp = Time.now();
            emotionalState = {
                joy = 70;
                sadness = 0;
                anger = 0;
                fear = 20;
                trust = 80;
            };
        })
    };

    private func _updateExperience(
        tokenId: Hub.TokenId,
        skillId: Hub.SkillId,
        expGain: Nat
    ) : async Hub.Result<(), Hub.Error> {
        switch (storage.getProgress(tokenId, skillId)) {
            case (null) { #err(#NotFound) };
            case (?current) {
                let updated = storage.updateProgress(
                    tokenId,
                    skillId,
                    func (prog: Types.SkillProgress) : Types.SkillProgress = {
                        prog with
                        currentExperience = prog.currentExperience + expGain
                    }
                );
                switch (updated) {
                    case (null) { #err(#SystemError) };
                    case (?_) { #ok(()) };
                }
            };
        }
    };

    private func _checkPrerequisites(
        tokenId: Hub.TokenId,
        prerequisites: [Hub.SkillId]
    ) : async Bool {
        let progress = storage.getTokenSkills(tokenId);
        
        for (prereq in prerequisites.vals()) {
            let hasPrereq = Array.find<Types.SkillProgress>(
                progress,
                func (p: Types.SkillProgress) : Bool = p.skillId == prereq
            );
            if (hasPrereq == null) {
                return false;
            };
        };
        true
    };

    private func _checkLevelUp(
        tokenId: Hub.TokenId,
        skillId: Hub.SkillId,
        progress: Types.SkillProgress
    ) : async Hub.Result<(), Hub.Error> {
        let skill = switch (storage.getSkill(skillId)) {
            case (null) { return #err(#NotFound) };
            case (?s) { s };
        };

        let expForNextLevel = _calculateExpForLevel(progress.currentLevel + 1);
        
        if (progress.currentExperience >= expForNextLevel) {
            let updated = storage.updateProgress(
                tokenId,
                skillId,
                func (prog: Types.SkillProgress) : Types.SkillProgress = {
                    prog with
                    currentLevel = prog.currentLevel + 1;
                    currentExperience = prog.currentExperience - expForNextLevel;
                }
            );

            switch (updated) {
                case (null) { return #err(#SystemError) };
                case (?_) {
                    _recordLearningEvent(
                        tokenId,
                        skillId,
                        #LevelUp,
                        ?("Advanced to level " # Int.toText(progress.currentLevel + 1)),
                        0
                    );
                    #ok(())
                };
            }
        } else {
            #ok(()) // Not enough experience yet
        }
    };

    private func _checkAchievements(
        tokenId: Hub.TokenId,
        skillId: Hub.SkillId,
        progress: Types.SkillProgress
    ) : async Hub.Result<(), Hub.Error> {
        let achievements = Buffer.Buffer<Types.Achievement>(0);

        // Check for level milestones
        if (progress.currentLevel >= 10 and not _hasAchievement(progress, "level_10")) {
            achievements.add({
                id = "level_10";
                name = "Dedicated Student";
                description = "Reached level 10 in a skill";
                timestamp = Time.now();
                significance = 60;
            });
        };

        // Check practice consistency
        let recentPractices = storage.getPracticeLogs(tokenId, skillId, ?30);
        if (recentPractices.size() >= 20 and not _hasAchievement(progress, "consistent_20")) {
            achievements.add({
                id = "consistent_20";
                name = "Consistent Practitioner";
                description = "Practiced 20 times in a month";
                timestamp = Time.now();
                significance = 75;
            });
        };

        // Record new achievements
        for (achievement in achievements.vals()) {
            if (storage.addAchievement(tokenId, skillId, achievement)) {
                _recordLearningEvent(
                    tokenId,
                    skillId,
                    #AchievementUnlocked,
                    ?("Unlocked: " # achievement.name),
                    0
                );
            };
        };

        #ok(())
    };

    private func _checkMastery(
        tokenId: Hub.TokenId,
        skillId: Hub.SkillId,
        progress: Types.SkillProgress
    ) : async Hub.Result<(), Hub.Error> {
        let skill = switch (storage.getSkill(skillId)) {
            case (null) { return #err(#NotFound) };
            case (?s) { s };
        };

        if (progress.currentLevel >= 50 and not _hasAchievement(progress, "mastery")) {
            let masteryAchievement : Types.Achievement = {
                id = "mastery";
                name = "True Mastery";
                description = "Achieved complete mastery of " # skill.name;
                timestamp = Time.now();
                significance = 100;
            };

            if (storage.addAchievement(tokenId, skillId, masteryAchievement)) {
                _recordLearningEvent(
                    tokenId,
                    skillId,
                    #MasteryReached,
                    ?("Achieved mastery in " # skill.name),
                    0
                );
            };
        };

        #ok(())
    };

    private func _hasAchievement(progress: Types.SkillProgress, achievementId: Text) : Bool {
        Array.find<Types.Achievement>(
            progress.achievements,
            func (a: Types.Achievement) : Bool = a.id == achievementId
        ) != null
    };

    private func _calculateExpForLevel(level: Nat) : Nat {
        // Experience curve: 100 * level^1.5
        let base = 100;
        let multiplier = Float.fromInt(level);
        let exponent = 1.5;
        
        Int.abs(Float.toInt(
            Float.fromInt(base) * Float.pow(multiplier, exponent)
        ))
    };

    // System Functions
    stable var stableStorage = {
        skills = [] : [(Hub.SkillId, Types.Skill)];
        progress = [] : [(Text, Types.SkillProgress)];
        events = [] : [Types.LearningEvent];
    };

    system func preupgrade() {
        stableStorage := storage.toStable();
    };

    system func postupgrade() {
        storage.loadStable(stableStorage);
    };
};