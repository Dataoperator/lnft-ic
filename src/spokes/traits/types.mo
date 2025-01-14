import Hub "../../hub/types";
import Time "mo:base/Time";

module {
    public type Trait = {
        id: Hub.TraitId;
        name: Text;
        description: Text;
        category: TraitCategory;
        rarity: RarityLevel;
        level: Nat;
        experience: Nat;
        modifiers: TraitModifiers;
        requirements: TraitRequirements;
        evolutionPaths: [EvolutionPath];
    };

    public type TraitCategory = {
        #Personality;
        #Ability;
        #Physical;
        #Mental;
        #Social;
        #Special;
    };

    public type RarityLevel = {
        #Common;
        #Uncommon;
        #Rare;
        #Epic;
        #Legendary;
    };

    public type TraitModifiers = {
        emotional: [EmotionalModifier];
        learning: [LearningModifier];
        memory: [MemoryModifier];
        special: [(Text, Int)];
    };

    public type EmotionalModifier = {
        emotion: Text;
        magnitude: Int;
        condition: ?Text;
    };

    public type LearningModifier = {
        skillCategory: Text;
        multiplier: Float;
    };

    public type MemoryModifier = {
        memoryType: Text;
        retentionBonus: Nat;
    };

    public type TraitRequirements = {
        traits: [Hub.TraitId];
        skills: [Hub.SkillId];
        level: Nat;
        experience: Nat;
    };

    public type EvolutionPath = {
        targetTrait: Hub.TraitId;
        requirements: TraitRequirements;
        catalysts: [Text];
    };

    public type TraitEvolutionEvent = {
        traitId: Hub.TraitId;
        tokenId: Hub.TokenId;
        timestamp: Time.Time;
        previousLevel: Nat;
        newLevel: Nat;
        catalyst: ?Text;
    };

    public type TraitActivation = {
        traitId: Hub.TraitId;
        tokenId: Hub.TokenId;
        timestamp: Time.Time;
        duration: ?Nat;
        context: Text;
    };
};