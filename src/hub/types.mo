import Time "mo:base/Time";
import Result "mo:base/Result";

module {
    public type Event = {
        #emotional: EmotionalEvent;
        #memory: MemoryEvent;
        #skill: SkillEvent;
        #social: SocialEvent;
    };

    public type EventPriority = {
        #immediate;    // Process right away
        #high;         // Process soon
        #normal;       // Regular processing
        #low;         // Process when idle
        #background;   // Process during maintenance
    };

    public type EventImpact = {
        neuralChange: ?NeuralChange;
        emotionalChange: ?EmotionalChange;
        traitChange: ?TraitChange;
        socialChange: ?SocialChange;
        systemChange: ?SystemChange;
    };

    public type EmotionalEvent = {
        type_: {
            #interaction;
            #environmental;
            #internal;
        };
        intensity: Float;
        data: ?MetadataContainer;
        context: ?Context;
    };

    public type MemoryEvent = {
        type_: {
            #formation;
            #recall;
            #association;
        };
        id: Text;
        target_id: ?Text;
        data: ?MetadataContainer;
        context: ?Context;
    };

    public type SkillEvent = {
        type_: {
            #activation;
            #learning;
            #mastery;
        };
        skill_id: SkillId;
        level: Nat;
        data: ?MetadataContainer;
        context: ?Context;
    };

    public type SocialEvent = {
        type_: {
            #interaction;
            #bond_formation;
            #relationship_change;
        };
        target_id: Text;
        change: Float;
        data: ?MetadataContainer;
        context: ?Context;
    };

    // Core type definitions
    public type TraitId = Text;
    public type SkillId = Text;
    public type MemoryId = Text;
    public type ActionId = Text;
