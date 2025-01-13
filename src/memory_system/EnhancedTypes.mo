/// Enhanced Memory System Types
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Types "../lnft_core/Types";

module {
    public type MemoryCategory = {
        #General;       // Basic memories
        #Skill;        // Skill-related memories
        #Achievement;   // Task completion memories
        #Interaction;  // Social interaction memories
        #Emotional;    // Strong emotional experiences
        #Summary;      // Compressed memory summaries
    };

    public type EnhancedMemoryEntry = {
        timestamp : Time.Time;
        content : Text;
        category : MemoryCategory;
        emotional_impact : ?Types.EmotionalState;
        tags : [Text];
        metadata : ?Blob;
        linked_entities : ?[Text];  // IDs of related skills, tasks, or other LNFTs
        importance : Nat8;          // 0-100 scale for memory significance
    };

    public type MemoryStats = {
        total_memories : Nat;
        compressed_memories : Nat;
        memory_by_category : [(MemoryCategory, Nat)];
        emotional_distribution : [(Text, Nat)];  // Distribution of emotional states
        top_tags : [(Text, Nat)];               // Most common tags
    };

    public type MemoryFilter = {
        categories : ?[MemoryCategory];
        tags : ?[Text];
        emotional_states : ?[Text];
        importance_threshold : ?Nat8;
        start_time : ?Time.Time;
        end_time : ?Time.Time;
    };

    public type EnhancedEmotionalState = {
        base : Text;            // Primary emotion
        secondary : ?Text;      // Secondary emotion
        intensity : Nat8;       // 0-100 scale
        duration : ?Time.Time;  // How long this state has persisted
        triggers : [Text];      // What caused this emotional state
        context : ?Text;        // Additional context
    };

    public type MemoryCapacity = {
        current : Nat;
        maximum : Nat;
        compression_threshold : Nat;
        compressed_count : Nat;
    };
}