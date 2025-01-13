import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Array "mo:base/Array";

module {
    public type TokenId = Nat;

    // Use a more efficient metadata structure
    public type Metadata = {
        name : Text;
        description : Text;
        // Store image data as Blob for efficiency
        image : ?Blob;
        created_at : Time.Time;
        modified_at : Time.Time;
    };

    public type TraitRarity = {
        #Common;
        #Uncommon;
        #Rare;
        #Legendary;
        #Event : {
            name : Text;
            start_time : Time.Time;
            end_time : Time.Time;
        };
    };

    public type Trait = {
        id : Text;
        name : Text;
        rarity : TraitRarity;
        // Optional supply limit for rarity
        supply : ?{
            current : Nat;
            max : Nat;
        };
    };

    // Using compact emotional state representation
    public type EmotionalState = {
        base : Text;
        intensity : Nat8;  // 0-100 scale uses less memory than Nat
        modifiers : [Text];
        timestamp : Time.Time;
    };

    // Optimized memory entry structure
    public type MemoryEntry = {
        timestamp : Time.Time;
        content : Text;
        emotional_impact : ?{
            base : Text;
            intensity : Nat8;
        };
        // Use Array instead of Buffer for stable storage
        tags : [Text];
        // Using Blob for any additional data
        metadata : ?Blob;
    };

    // Main LNFT type with stable storage considerations
    public type LNFT = {
        id : TokenId;
        owner : Principal;
        metadata : Metadata;
        traits : [Trait];
        emotional_state : EmotionalState;
        // Store memory references instead of full entries
        memory_ids : [Nat];
        created : Time.Time;
        last_interaction : Time.Time;
    };

    // Event system for logging
    public type EventType = {
        #Mint : {
            to : Principal;
            id : TokenId;
            timestamp : Time.Time;
        };
        #Transfer : {
            from : Principal;
            to : Principal;
            id : TokenId;
            timestamp : Time.Time;
        };
        #EmotionUpdate : {
            id : TokenId;
            old_state : EmotionalState;
            new_state : EmotionalState;
            timestamp : Time.Time;
        };
        #MemoryCreated : {
            id : TokenId;
            memory_id : Nat;
            timestamp : Time.Time;
        };
    };

    // Stable storage helper types
    public type StableMemoryEntry = (Nat, MemoryEntry);
    public type StableEmotionalState = (TokenId, EmotionalState);
    public type StableLNFT = (TokenId, LNFT);

    // Helper functions for stable storage
    public func arrayToBuffer<T>(arr: [T]): Buffer.Buffer<T> {
        let buf = Buffer.Buffer<T>(arr.size());
        for (item in arr.vals()) {
            buf.add(item);
        };
        buf
    };

    public func bufferToArray<T>(buf: Buffer.Buffer<T>): [T] {
        Buffer.toArray(buf)
    };

    // Efficient hash function for TokenId
    public func tokenIdHash(id: TokenId): Hash.Hash {
        Hash.hash(Nat.toText(id))
    };

    // Memory optimization helper
    public func compressMemoryEntry(entry: MemoryEntry): MemoryEntry {
        {
            timestamp = entry.timestamp;
            content = entry.content;
            emotional_impact = entry.emotional_impact;
            tags = Array.filter<Text>(entry.tags, func(t: Text): Bool = t != "");
            metadata = entry.metadata;
        }
    };
}