import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Types "../lnft_core/Types";
import Array "mo:base/Array";
import Text "mo:base/Text";

actor class MemorySystem() {
    private let memories = HashMap.HashMap<Types.TokenId, Buffer.Buffer<Types.MemoryEntry>>(0, Nat.equal, Hash.hash);
    private let emotionalStates = HashMap.HashMap<Types.TokenId, Types.EmotionalState>(0, Nat.equal, Hash.hash);
    
    // Add new memory to an LNFT
    public shared({ caller }) func addMemory(
        tokenId: Types.TokenId,
        content: Text,
        emotionalImpact: ?Types.EmotionalState,
        tags: [Text]
    ) : async Result.Result<(), Text> {
        let memory : Types.MemoryEntry = {
            timestamp = Time.now();
            content;
            emotionalImpact;
            tags;
        };

        switch (memories.get(tokenId)) {
            case (?memBuffer) {
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

    // Update emotional state
    public shared({ caller }) func updateEmotionalState(
        tokenId: Types.TokenId,
        newState: Types.EmotionalState
    ) : async Result.Result<(), Text> {
        emotionalStates.put(tokenId, newState);
        #ok(())
    };

    // Get all memories for an LNFT
    public query func getMemories(tokenId: Types.TokenId) : async [Types.MemoryEntry] {
        switch (memories.get(tokenId)) {
            case (?memBuffer) { Buffer.toArray(memBuffer) };
            case null { [] };
        }
    };

    // Get current emotional state
    public query func getEmotionalState(tokenId: Types.TokenId) : async ?Types.EmotionalState {
        emotionalStates.get(tokenId)
    };

    // Search memories by tags
    public query func searchMemoriesByTags(tokenId: Types.TokenId, searchTags: [Text]) : async [Types.MemoryEntry] {
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

    // Analyze emotional trends
    public query func analyzeEmotionalTrends(tokenId: Types.TokenId) : async {
        dominantEmotion: Text;
        averageIntensity: Nat8;
    } {
        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                var totalIntensity : Nat = 0;
                var emotionCounts = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
                var count : Nat = 0;

                for (memory in memBuffer.vals()) {
                    switch (memory.emotionalImpact) {
                        case (?impact) {
                            totalIntensity += Nat8.toNat(impact.intensity);
                            let currentCount = Option.get(emotionCounts.get(impact.base), 0);
                            emotionCounts.put(impact.base, currentCount + 1);
                            count += 1;
                        };
                        case null {};
                    };
                };

                var maxEmotion = "neutral";
                var maxCount = 0;
                for ((emotion, emotionCount) in emotionCounts.entries()) {
                    if (emotionCount > maxCount) {
                        maxCount := emotionCount;
                        maxEmotion := emotion;
                    };
                };

                {
                    dominantEmotion = maxEmotion;
                    averageIntensity = 
                        if (count > 0) Nat8.fromNat(totalIntensity / count)
                        else 0;
                }
            };
            case null {
                {
                    dominantEmotion = "neutral";
                    averageIntensity = 0;
                }
            };
        }
    };
}