import Types "./Types";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Time "mo:base/Time";

module {
    // Stable storage variables
    private stable var stableTokens : [(Types.TokenId, Types.LNFT)] = [];
    private stable var stableMemories : [(Nat, Types.MemoryEntry)] = [];
    private stable var stableEmotionalStates : [(Types.TokenId, Types.EmotionalState)] = [];
    private stable var stableOwnership : [(Principal, [Types.TokenId])] = [];
    private stable var stableVersion : Nat = 0;

    // In-memory data structures
    public type Storage = {
        tokens : HashMap.HashMap<Types.TokenId, Types.LNFT>;
        memories : HashMap.HashMap<Nat, Types.MemoryEntry>;
        emotionalStates : HashMap.HashMap<Types.TokenId, Types.EmotionalState>;
        ownership : HashMap.HashMap<Principal, Buffer.Buffer<Types.TokenId>>;
    };

    // Initialize storage from stable variables
    public func init() : Storage {
        let storage = {
            tokens = HashMap.fromIter<Types.TokenId, Types.LNFT>(
                stableTokens.vals(),
                stableTokens.size(),
                Nat.equal,
                Types.tokenIdHash
            );
            memories = HashMap.fromIter<Nat, Types.MemoryEntry>(
                stableMemories.vals(),
                stableMemories.size(),
                Nat.equal,
                func(x) = x
            );
            emotionalStates = HashMap.fromIter<Types.TokenId, Types.EmotionalState>(
                stableEmotionalStates.vals(),
                stableEmotionalStates.size(),
                Nat.equal,
                Types.tokenIdHash
            );
            ownership = HashMap.HashMap<Principal, Buffer.Buffer<Types.TokenId>>(
                10,
                Principal.equal,
                Principal.hash
            );
        };

        // Initialize ownership map from stable array
        for ((owner, tokens) in stableOwnership.vals()) {
            let tokenBuffer = Buffer.Buffer<Types.TokenId>(tokens.size());
            for (token in tokens.vals()) {
                tokenBuffer.add(token);
            };
            storage.ownership.put(owner, tokenBuffer);
        };

        storage
    };

    // Prepare for upgrade
    public func preupgrade(storage: Storage) {
        stableTokens := Iter.toArray(storage.tokens.entries());
        stableMemories := Iter.toArray(storage.memories.entries());
        stableEmotionalStates := Iter.toArray(storage.emotionalStates.entries());
        
        // Convert ownership map to stable format
        stableOwnership := Array.mapEntries<Principal, Buffer.Buffer<Types.TokenId>, (Principal, [Types.TokenId])>(
            Iter.toArray(storage.ownership.entries()),
            func(owner, tokens, _) = (owner, Buffer.toArray(tokens))
        );
        
        stableVersion += 1;
    };

    // Handle post-upgrade tasks
    public func postupgrade(storage: Storage) {
        stableTokens := [];
        stableMemories := [];
        stableEmotionalStates := [];
        stableOwnership := [];
    };

    // Memory optimization helpers
    public func compressStorage(storage: Storage) {
        for ((id, entry) in storage.memories.entries()) {
            storage.memories.put(id, Types.compressMemoryEntry(entry));
        };
    };

    // Version management
    public func getVersion() : Nat {
        stableVersion
    };

    // Migration helpers for future upgrades
    public func migrateIfNeeded(storage: Storage) {
        if (stableVersion < 1) {
            // Add migration logic here when needed
            stableVersion := 1;
        };
    };
}