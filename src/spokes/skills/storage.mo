import Types "./types";
import Hub "../../hub/types";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

module {
    public class SkillStorage() {
        // Core storage
        private var skills = HashMap.HashMap<Hub.SkillId, Types.Skill>(0, Text.equal, Text.hash);
        private var progress = HashMap.HashMap<Text, Types.SkillProgress>(0, Text.equal, Text.hash);
        private var learningEvents = Buffer.Buffer<Types.LearningEvent>(0);

        // Helper function to create compound key for progress
        private func _makeProgressKey(tokenId: Hub.TokenId, skillId: Hub.SkillId) : Text {
            tokenId # ":" # skillId
        };

        // Skill Management
        public func storeSkill(skill: Types.Skill) : Bool {
            skills.put(skill.id, skill);
            true
        };

        public func getSkill(skillId: Hub.SkillId) : ?Types.Skill {
            skills.get(skillId)
        };

        public func getAllSkills() : [Types.Skill] {
            HashMap.map<Hub.SkillId, Types.Skill, Types.Skill>(
                skills,
                Text.equal,
                Text.hash,
                func(k: Hub.SkillId, v: Types.Skill) : Types.Skill = v
            )
        };

        // Progress Management
        public func initializeProgress(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            initialLevel: Nat
        ) : Types.SkillProgress {
            let newProgress = {
                skillId = skillId;
                tokenId = tokenId;
                currentLevel = initialLevel;
                currentExperience = 0;
                practiceLog = [];
                achievements = [];
            };
            progress.put(_makeProgressKey(tokenId, skillId), newProgress);
            newProgress
        };

        public func getProgress(tokenId: Hub.TokenId, skillId: Hub.SkillId) : ?Types.SkillProgress {
            progress.get(_makeProgressKey(tokenId, skillId))
        };

        public func updateProgress(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            updateFn: (Types.SkillProgress) -> Types.SkillProgress
        ) : ?Types.SkillProgress {
            let key = _makeProgressKey(tokenId, skillId);
            switch (progress.get(key)) {
                case (null) { null };
                case (?current) {
                    let updated = updateFn(current);
                    progress.put(key, updated);
                    ?updated
                };
            }
        };

        public func getTokenSkills(tokenId: Hub.TokenId) : [Types.SkillProgress] {
            let results = Buffer.Buffer<Types.SkillProgress>(0);
            for ((key, prog) in progress.entries()) {
                if (Text.startsWith(key, #text(tokenId))) {
                    results.add(prog);
                };
            };
            Buffer.toArray(results)
        };

        // Practice Log Management
        public func addPracticeEntry(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            entry: Types.PracticeEntry
        ) : Bool {
            switch (getProgress(tokenId, skillId)) {
                case (null) { false };
                case (?current) {
                    let updated = {
                        current with
                        practiceLog = Array.append(current.practiceLog, [entry])
                    };
                    progress.put(_makeProgressKey(tokenId, skillId), updated);
                    true
                };
            }
        };

        public func getPracticeLogs(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            limit: ?Nat
        ) : [Types.PracticeEntry] {
            switch (getProgress(tokenId, skillId)) {
                case (null) { [] };
                case (?prog) {
                    switch (limit) {
                        case (null) { prog.practiceLog };
                        case (?n) {
                            let start = if (prog.practiceLog.size() > n) {
                                prog.practiceLog.size() - n
                            } else {
                                0
                            };
                            Array.tabulate<Types.PracticeEntry>(
                                Nat.min(n, prog.practiceLog.size()),
                                func (i: Nat) : Types.PracticeEntry {
                                    prog.practiceLog[start + i]
                                }
                            )
                        };
                    }
                };
            }
        };

        // Achievement Management
        public func addAchievement(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            achievement: Types.Achievement
        ) : Bool {
            switch (getProgress(tokenId, skillId)) {
                case (null) { false };
                case (?current) {
                    let updated = {
                        current with
                        achievements = Array.append(current.achievements, [achievement])
                    };
                    progress.put(_makeProgressKey(tokenId, skillId), updated);
                    true
                };
            }
        };

        // Learning Event Management
        public func recordLearningEvent(event: Types.LearningEvent) {
            learningEvents.add(event);
        };

        public func getLearningEvents(
            tokenId: Hub.TokenId,
            skillId: Hub.SkillId,
            limit: ?Nat
        ) : [Types.LearningEvent] {
            let filtered = Buffer.mapFilter<Types.LearningEvent, Types.LearningEvent>(
                learningEvents,
                func (event: Types.LearningEvent) : ?Types.LearningEvent {
                    if (event.tokenId == tokenId and event.skillId == skillId) {
                        ?event
                    } else {
                        null
                    }
                }
            );

            switch (limit) {
                case (null) { Buffer.toArray(filtered) };
                case (?n) {
                    let arr = Buffer.toArray(filtered);
                    let start = if (arr.size() > n) {
                        arr.size() - n
                    } else {
                        0
                    };
                    Array.tabulate<Types.LearningEvent>(
                        Nat.min(n, arr.size()),
                        func (i: Nat) : Types.LearningEvent {
                            arr[start + i]
                        }
                    )
                };
            }
        };

        // Stable Storage Management
        public func toStable() : {
            skills: [(Hub.SkillId, Types.Skill)];
            progress: [(Text, Types.SkillProgress)];
            events: [Types.LearningEvent];
        } {
            {
                skills = HashMap.toArray(skills);
                progress = HashMap.toArray(progress);
                events = Buffer.toArray(learningEvents);
            }
        };

        public func loadStable(stable: {
            skills: [(Hub.SkillId, Types.Skill)];
            progress: [(Text, Types.SkillProgress)];
            events: [Types.LearningEvent];
        }) {
            skills := HashMap.fromIter<Hub.SkillId, Types.Skill>(
                stable.skills.vals(),
                stable.skills.size(),
                Text.equal,
                Text.hash
            );
            progress := HashMap.fromIter<Text, Types.SkillProgress>(
                stable.progress.vals(),
                stable.progress.size(),
                Text.equal,
                Text.hash
            );
            learningEvents := Buffer.fromArray(stable.events);
        };
    };
};