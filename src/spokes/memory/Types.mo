import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";

module {
    public type MemoryEntry = {
        id: Nat;
        content: Text;
        timestamp: Time.Time;
        emotionalStrength: Nat;
        tags: [Text];
        associatedTokenId: Nat;
    };

    public type EmotionalState = {
        joy: Nat;
        sadness: Nat;
        anger: Nat;
        fear: Nat;
        trust: Nat;
    };

    public type MemoryFilter = {
        #ByTokenId: Nat;
        #ByTimeRange: (Time.Time, Time.Time);
        #ByEmotionalStrength: Nat;
        #ByTags: [Text];
    };

    public type MemoryUpdateRequest = {
        id: Nat;
        newContent: ?Text;
        newEmotionalStrength: ?Nat;
        addTags: ?[Text];
        removeTags: ?[Text];
    };
}