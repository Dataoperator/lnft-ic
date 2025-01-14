import Hub "../../hub/types";
import Time "mo:base/Time";

module {
    public type Skill = {
        id: Hub.SkillId;
        name: Text;
        description: Text;
        category: SkillCategory;
        level: Nat;
        experience: Nat;
        masteryLevel: MasteryLevel;
        prerequisites: [Hub.SkillId];
        relatedTraits: [Hub.TraitId];
        learningPath: LearningPath;
    };

    public type SkillCategory = {
        #Technical;
        #Creative;
        #Social;
        #Cognitive;
        #Special;
    };

    public type MasteryLevel = {
        #Novice;
        #Apprentice;
        #Practitioner;
        #Expert;
        #Master;
    };

    public type LearningPath = {
        stages: [LearningStage];
        currentStage: Nat;
        requiredPractice: Nat;
        completedPractice: Nat;
    };

    public type LearningStage = {
        name: Text;
        description: Text;
        requirements: StageRequirements;
        rewards: StageRewards;
    };

    public type StageRequirements = {
        practiceHours: Nat;
        traitLevels: [(Hub.TraitId, Nat)];
        prerequisites: [Hub.SkillId];
    };

    public type StageRewards = {
        experienceGain: Nat;
        traitBoosts: [(Hub.TraitId, Nat)];
        unlockedAbilities: [Text];
    };

    public type SkillProgress = {
        skillId: Hub.SkillId;
        tokenId: Hub.TokenId;
        currentLevel: Nat;
        currentExperience: Nat;
        practiceLog: [PracticeEntry];
        achievements: [Achievement];
    };

    public type PracticeEntry = {
        timestamp: Time.Time;
        duration: Nat;  // in minutes
        type: PracticeType;
        effectiveness: Nat;  // 0-100
        notes: ?Text;
    };

    public type PracticeType = {
        #Study;
        #Exercise;
        #RealWorld;
        #Teaching;
        #Collaboration;
    };

    public type Achievement = {
        id: Text;
        name: Text;
        description: Text;
        timestamp: Time.Time;
        significance: Nat;  // 0-100
    };

    public type LearningEvent = {
        skillId: Hub.SkillId;
        tokenId: Hub.TokenId;
        eventType: {
            #Started;
            #LevelUp;
            #PracticeCompleted;
            #AchievementUnlocked;
            #MasteryReached;
        };
        timestamp: Time.Time;
        details: Text;
        experienceGained: Nat;
    };

    // Request Types
    public type LearnSkillRequest = {
        tokenId: Hub.TokenId;
        skillId: Hub.SkillId;
        initialLevel: ?Nat;
        context: ?Text;
    };

    public type PracticeRequest = {
        tokenId: Hub.TokenId;
        skillId: Hub.SkillId;
        duration: Nat;
        practiceType: PracticeType;
        notes: ?Text;
    };

    public type ProgressCheckRequest = {
        tokenId: Hub.TokenId;
        skillId: Hub.SkillId;
        checkType: {
            #LevelUp;
            #Achievement;
            #Mastery;
        };
    };
};