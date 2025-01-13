import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Types "../lnft_core/Types";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";

actor class MemorySystem() {
    // Stable storage
    private stable var stableMemories : [(Types.TokenId, [Types.MemoryEntry])] = [];
    private stable var stableEmotionalStates : [(Types.TokenId, Types.EmotionalState)] = [];
    private stable var stableMemoryCount : Nat = 0;
    private stable var stableVersion : Nat = 0;

    // Runtime storage with efficient data structures
    private let memories = HashMap.fromIter<Types.TokenId, Buffer.Buffer<Types.MemoryEntry>>(
        Array.map<(Types.TokenId, [Types.MemoryEntry]), (Types.TokenId, Buffer.Buffer<Types.MemoryEntry>)>(
            stableMemories,
            func(entry) {
                (entry.0, Types.arrayToBuffer(entry.1))
            }
        ).vals(),
        stableMemories.size(),
        Nat.equal,
        Types.tokenIdHash
    );

    private let emotionalStates = HashMap.fromIter<Types.TokenId, Types.EmotionalState>(
        stableEmotionalStates.vals(),
        stableEmotionalStates.size(),
        Nat.equal,
        Types.tokenIdHash
    );

    // Memory compression threshold
    private let COMPRESSION_THRESHOLD = 100; // Number of memories before compression
    private let MAX_MEMORY_SIZE = 1000; // Maximum memories per token

    // Add new memory with optimization
    public shared({ caller }) func addMemory(
        tokenId: Types.TokenId,
        content: Text,
        emotionalImpact: ?Types.EmotionalState,
        tags: [Text]
    ) : async Result.Result<(), Text> {
        let memory : Types.MemoryEntry = {
            timestamp = Time.now();
            content;
            emotional_impact = Option.map(
                emotionalImpact,
                func(e: Types.EmotionalState) : { base: Text; intensity: Nat8 } {
                    { base = e.base; intensity = e.intensity }
                }
            );
            tags = Array.filter(tags, func(t: Text) : Bool = t != "");
            metadata = null;
        };

        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                if (memBuffer.size() >= MAX_MEMORY_SIZE) {
                    // Compress old memories if threshold reached
                    if (memBuffer.size() >= COMPRESSION_THRESHOLD) {
                        ignore compressMemories(tokenId);
                    };
                    // Remove oldest memory if at capacity
                    memBuffer.remove(0);
                };
                memBuffer.add(memory);
                #ok(())
            };
            case null {
                let newBuffer = Buffer.Buffer<Types.MemoryEntry>(1);
                newBuffer.add(memory);
                memories.put(tokenId, newBuffer);
                #ok(())
            };
        }
    };

    // Compress memories for storage efficiency
    private func compressMemories(tokenId: Types.TokenId) : async () {
        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                if (memBuffer.size() >= COMPRESSION_THRESHOLD) {
                    let oldMemories = Buffer.Buffer<Types.MemoryEntry>(COMPRESSION_THRESHOLD / 2);
                    // Combine old memories into summary entries
                    var i = 0;
                    while (i < COMPRESSION_THRESHOLD / 2) {
                        let memory = memBuffer.remove(0);
                        oldMemories.add(memory);
                        i += 1;
                    };
                    // Create summary memory
                    let summary : Types.MemoryEntry = {
                        timestamp = Time.now();
                        content = "Memory Summary: " # Nat.toText(oldMemories.size()) # " memories compressed";
                        emotional_impact = null;
                        tags = ["summary"];
                        metadata = ?Text.encodeUtf8(
                            "Compressed memories from " # 
                            Int.toText(oldMemories.get(0).timestamp) # 
                            " to " # 
                            Int.toText(oldMemories.get(oldMemories.size() - 1).timestamp)
                        );
                    };
                    memBuffer.insert(0, summary);
                };
            };
            case null {};
        };
    };

    // Update emotional state with validation
    public shared({ caller }) func updateEmotionalState(
        tokenId: Types.TokenId,
        newState: Types.EmotionalState
    ) : async Result.Result<(), Text> {
        // Validate intensity range
        if (newState.intensity > 100) {
            return #err("Intensity must be between 0 and 100");
        };
        
        emotionalStates.put(tokenId, newState);
        #ok(())
    };

    // Query functions with pagination for efficiency
    public query func getMemories(
        tokenId: Types.TokenId,
        start: Nat,
        limit: Nat
    ) : async [Types.MemoryEntry] {
        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                let size = memBuffer.size();
                if (start >= size) {
                    return [];
                };
                let end = Nat.min(start + limit, size);
                let result = Buffer.Buffer<Types.MemoryEntry>(end - start);
                var i = start;
                while (i < end) {
                    result.add(memBuffer.get(i));
                    i += 1;
                };
                Buffer.toArray(result)
            };
            case null { [] };
        }
    };

    public query func getEmotionalState(tokenId: Types.TokenId) : async ?Types.EmotionalState {
        emotionalStates.get(tokenId)
    };

    // Efficient memory search with index support
    public query func searchMemoriesByTags(
        tokenId: Types.TokenId,
        searchTags: [Text]
    ) : async [Types.MemoryEntry] {
        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                let matches = Buffer.Buffer<Types.MemoryEntry>(0);
                for (memory in memBuffer.vals()) {
                    label matching for (searchTag in searchTags.vals()) {
                        if (Array.find<Text>(memory.tags, func(t) = t == searchTag) != null) {
                            matches.add(memory);
                            break matching;
                        };
                    };
                };
                Buffer.toArray(matches)
            };
            case null { [] };
        }
    };

    // System functions for upgrade safety
    system func preupgrade() {
        stableMemories := Array.map<(Types.TokenId, Buffer.Buffer<Types.MemoryEntry>), (Types.TokenId, [Types.MemoryEntry])>(
            Iter.toArray(memories.entries()),
            func((id, buf)) = (id, Buffer.toArray(buf))
        );
        stableEmotionalStates := Iter.toArray(emotionalStates.entries());
        stableVersion += 1;
    };

    system func postupgrade() {
        stableMemories := [];
        stableEmotionalStates := [];
    };
}