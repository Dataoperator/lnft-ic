import Hub "../../hub/types";
import Time "mo:base/Time";

module {
    // Core Cronolink Types
    public type NeuralResponse = {
        response: Text;
        emotionalImpact: Hub.EmotionalState;
        confidence: Float;
        memoryTriggers: [Hub.MemoryId];
        suggestedActions: [ActionSuggestion];
    };

    public type ProcessRequest = {
        tokenId: Hub.TokenId;
        input: Text;
        currentState: Hub.EmotionalState;
        context: ?InteractionContext;
    };

    public type InteractionContext = {
        recentMemories: [Hub.MemoryId];
        activeTraits: [Hub.TraitId];
        conversationHistory: [ConversationEntry];
        environmentalFactors: [Text];
    };

    public type ConversationEntry = {
        timestamp: Time.Time;
        speaker: {#User; #Entity};
        content: Text;
        emotionalState: Hub.EmotionalState;
    };

    public type ActionSuggestion = {
        actionType: ActionType;
        priority: Nat; // 1-100
        reason: Text;
        requiredTraits: [Hub.TraitId];
    };

    public type ActionType = {
        #FormMemory: MemoryFormation;
        #EvolveTrait: TraitEvolution;
        #LearnSkill: SkillAcquisition;
        #EmotionalResponse: EmotionalAdjustment;
        #Custom: Text;
    };

    public type MemoryFormation = {
        content: Text;
        suggestedStrength: Nat;
        associatedMemories: [Hub.MemoryId];
    };

    public type TraitEvolution = {
        traitId: Hub.TraitId;
        evolutionPath: Text;
        catalystSuggestion: ?Text;
    };

    public type SkillAcquisition = {
        skillId: Hub.SkillId;
        learningApproach: Text;
        estimatedDifficulty: Nat;
    };

    public type EmotionalAdjustment = {
        targetEmotion: Text;
        intensity: Nat;
        duration: ?Time.Time;
    };

    // Personality Profile for response modulation
    public type PersonalityProfile = {
        dominantTraits: [Hub.TraitId];
        emotionalBaseline: Hub.EmotionalState;
        responsePatterns: [ResponsePattern];
        learningPreferences: [Text];
    };

    public type ResponsePattern = {
        trigger: Text;
        tendency: {#Positive; #Neutral; #Negative};
        strength: Nat; // 1-100
    };

    // Neural processing configuration
    public type ProcessingConfig = {
        emotionalSensitivity: Nat; // 1-100
        memoryThreshold: Nat; // Minimum strength for memory formation
        traitInfluence: Nat; // How much traits affect responses
        randomnessFactor: Nat; // Adds unpredictability
    };
};