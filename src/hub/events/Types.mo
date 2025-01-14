import Time "mo:base/Time";
import Types "../Types";

module {
    public type EmotionalEvent = {
        type_: {
            #interaction;
            #environmental;
            #internal;
        };
        intensity: Float;
        data: ?Types.MetadataContainer;
        context: ?Types.Context;
    };

    public type MemoryEvent = {
        type_: {
            #formation;
            #recall;
            #association;
        };
        id: Text;
        target_id: ?Text;
        data: ?Types.MetadataContainer;
        context: ?Types.Context;
    };

    public type SkillEvent = {
        type_: {
            #activation;
            #learning;
            #mastery;
        };
        skill_id: Types.SkillId;
        level: Nat;
        data: ?Types.MetadataContainer;
        context: ?Types.Context;
    };

    public type SocialEvent = {
        type_: {
            #interaction;
            #bond_formation;
            #relationship_change;
        };
        target_id: Text;
        change: Float;
        data: ?Types.MetadataContainer;
        context: ?Types.Context;
    };

    public type EventMetrics = {
        processing_time: Int;
        queue_position: Nat;
        impact_score: Float;
        resource_usage: Float;
        priority_level: Nat;
    };

    public type EventValidation = {
        is_valid: Bool;
        checks: [(Text, Bool)];
        messages: [Text];
        timestamp: Time.Time;
    };
};