import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

module {
    // ICRC-7 standard types
    public type TokenId = Nat;
    public type Metadata = {
        name : Text;
        description : Text;
        image : ?Text;
    };

    // Custom LNFT types
    public type TraitRarity = {
        #Common;
        #Uncommon;
        #Rare;
        #Legendary;
        #Event : Text;  // Event-specific traits
    };

    public type Trait = {
        id : Text;
        name : Text;
        rarity : TraitRarity;
        supply : ?Nat;  // Optional total supply limit
    };

    public type EmotionalState = {
        base : Text;    // Base emotion (happy, sad, etc.)
        intensity : Nat8;  // 0-100 intensity level
        modifiers : [Text];  // Additional emotional nuances
        lastUpdate : Time.Time;
    };

    public type MemoryEntry = {
        timestamp : Time.Time;
        content : Text;
        emotionalImpact : ?EmotionalState;
        tags : [Text];
    };

    public type LNFT = {
        id : TokenId;
        owner : Principal;
        metadata : Metadata;
        traits : [Trait];
        emotionalState : EmotionalState;
        memories : Buffer.Buffer<MemoryEntry>;
        created : Time.Time;
        lastInteraction : Time.Time;
    };

    // Events for logging and tracking
    public type Event = {
        #Mint : {
            to : Principal;
            id : TokenId;
        };
        #Transfer : {
            from : Principal;
            to : Principal;
            id : TokenId;
        };
        #EmotionUpdate : {
            id : TokenId;
            newState : EmotionalState;
        };
        #MemoryCreated : {
            id : TokenId;
            memory : MemoryEntry;
        };
    };
}