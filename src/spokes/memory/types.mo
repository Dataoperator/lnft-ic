import Time "mo:base/Time";
import Hub "../../hub/types";

module {
    public type Memory = {
        id: Hub.MemoryId;
        tokenId: Hub.TokenId;
        content: Text;
        timestamp: Time.Time;
        emotionalState: Hub.EmotionalState;
        strength: Nat;  // 0-100
        tags: [Text];
        associations: [Hub.MemoryId];
        memoryType: MemoryType;
    };

    public type MemoryType = {
        #Experience;     // Direct experiences
        #Learning;       // Knowledge gained
        #Interaction;    // Social interactions
        #Reflection;     // Internal processing
        #Dream;         // Subconscious processing
    };

    public type MemoryIndex = {
        emotionalIndex: [(Text, [Hub.MemoryId])];
        temporalIndex: [(Time.Time, Hub.MemoryId)];
        associativeIndex: [(Hub.MemoryId, [Hub.MemoryId])];
        tagIndex: [(Text, [Hub.MemoryId])];
    };

    public type CreateMemoryRequest = {
        tokenId: Hub.TokenId;
        content: Text;
        strength: Nat;
        timestamp: Time.Time;
        emotionalState: Hub.EmotionalState;
    };

    public type MemoryFilter = {
        #ByTimeRange: (Time.Time, Time.Time);
        #ByStrength: (Nat, Nat);
        #ByEmotion: Hub.EmotionalState;
        #ByTags: [Text];
        #ByAssociation: Hub.MemoryId;
    };

    public type MemoryUpdateRequest = {
        id: Hub.MemoryId;
        newContent: ?Text;
        newStrength: ?Nat;
        addTags: ?[Text];
        removeTags: ?[Text];
        addAssociations: ?[Hub.MemoryId];
        removeAssociations: ?[Hub.MemoryId];
    };

    public type RetrievalContext = {
        currentState: Hub.EmotionalState;
        recentMemories: [Hub.MemoryId];
        trigger: Text;
    };
};