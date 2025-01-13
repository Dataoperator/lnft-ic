import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";

module {
    public type TokenId = Nat;

    // Metadata structure
    public type Metadata = {
        name : Text;
        description : Text;
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
        supply : ?{
            current : Nat;
            max : Nat;
        };
    };

    public type EmotionalState = {
        base : Text;
        intensity : Nat8;  // 0-100 scale
        modifiers : [Text];
        timestamp : Time.Time;
    };

    public type MemoryEntry = {
        timestamp : Time.Time;
        content : Text;
        emotional_impact : ?{
            base : Text;
            intensity : Nat8;
        };
        tags : [Text];
        metadata : ?Blob;
    };

    public type LNFT = {
        id : TokenId;
        owner : Principal;
        metadata : Metadata;
        traits : [Trait];
        emotional_state : EmotionalState;
        memory_ids : [Nat];
        created : Time.Time;
        last_interaction : Time.Time;
    };

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

    public type StableMemoryEntry = (Nat, MemoryEntry);
    public type StableEmotionalState = (TokenId, EmotionalState);
    public type StableLNFT = (TokenId, LNFT);

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

    public func tokenIdEqual(x: TokenId, y: TokenId): Bool {
        x == y
    };

    // Improved hash function for TokenId using Nat32 hash
    public func tokenIdHash(id: TokenId): Hash.Hash {
        let n32 = Nat32.fromNat(id);
        // Use FNV-1a hash
        var hash: Nat32 = 2_166_136_261; // FNV offset basis
        hash := (hash ^ n32) *% 16_777_619; // FNV prime
        hash
    };

    public func compressMemoryEntry(entry: MemoryEntry): MemoryEntry {
        {
            timestamp = entry.timestamp;
            content = entry.content;
            emotional_impact = entry.emotional_impact;
            tags = Array.filter<Text>(entry.tags, func(t: Text): Bool = t != "");
            metadata = entry.metadata;
        }
    };

    // Add equality function for TokenId (required by ICRC-7)
    public func equal(x: TokenId, y: TokenId): Bool {
        x == y
    };
}