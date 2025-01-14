import Types "../types";
import Storage "./storage";
import Hub "../../../hub/types";
import Utils "../../../shared/utils";
import Validation "../../../shared/validation";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import UUID "mo:uuid";

actor EnhancedMemorySystem {
    private let storage = Storage.EnhancedMemoryStorage();
    private stable var nextMemoryId: Nat = 0;

    // External canister references
    private let hub = actor("aaaaa-aa") : actor { 
        getToken : shared (Hub.TokenId) -> async ?Hub.LNFT;
        recordEvent : shared (Hub.EventType, Hub.EventData) -> async ();
    };

    // Rate limiting
    private let rateLimiter = Utils.RateLimiter({
        windowMs = 60_000_000_000; // 1 minute
        maxRequests = 100;
    });

    // Memory Creation with Enhanced Validation and Processing
    public shared({ caller }) func createMemory(request: Types.CreateMemoryRequest) : async Hub.Result<Hub.MemoryId, Hub.Error> {
        // Rate limiting check
        if (not rateLimiter.checkLimit()) {
            Utils.logError("Rate limit exceeded", [("caller", Principal.toText(caller))]);
            return #err(#SystemError);
        };

        // Authorization check
        if (not _isAuthorized(caller)) {
            Utils.logError("Unauthorized access", [("caller", Principal.toText(caller))]);
            return #err(#Unauthorized);
        };

        // Input validation
        switch (Validation.validateMemoryContent(request.content)) {
            case (#err(e)) { return #err(#InvalidRequest) };
            case (#ok(_)) {};
        };

        switch (Validation.validateMemoryStrength(request.strength)) {
            case (#err(e)) { return #err(#InvalidRequest) };
            case (#ok(_)) {};
        };

        // Generate unique memory ID
        let memoryId = await _generateMemoryId();

        // Process and enrich memory content
        let (enrichedContent, tags) = await _processMemoryContent(request.content);

        // Create memory object with processed data
        let memory: Types.Memory = {
            id = memoryId;
            tokenId = request.tokenId;
            content = enrichedContent;
            timestamp = request.timestamp;
            emotionalState = request.emotionalState;
            strength = request.strength;
            tags = tags;
            associations = await _findRelevantAssociations(enrichedContent, request.tokenId);
            memoryType = await _determineMemoryType(enrichedContent);
        };

        // Store memory with error handling
        switch (storage.storeMemory(memory)) {
            case (#err(e)) {
                Utils.logError("Failed to store memory", [("error", e)]);
                return #err(#SystemError);
            };
            case (#ok(_)) {
                // Record event
                await _recordMemoryEvent(memory);
                #ok(memory.id)
            };
        }
    };

    // Enhanced Memory Retrieval with Context Awareness
    public shared({ caller }) func retrieveMemoriesWithContext(
        tokenId: Hub.TokenId,
        filter: Types.MemoryFilter,
        context: Types.RetrievalContext
    ) : async [Types.Memory] {
        if (not _isAuthorized(caller)) {
            return [];
        };

        let baseMemories = storage.findMemories(filter);
        await _rankAndFilterMemories(baseMemories, context)
    };

    // Memory Context Understanding
    public shared({ caller }) func getRelevantMemories(
        context: Types.RetrievalContext
    ) : async [Types.Memory] {
        if (not _isAuthorized(caller)) {
            return [];
        };

        let emotionalMemories = storage.findMemories(#ByEmotion(context.currentState));
        let rankedMemories = await _rankAndFilterMemories(emotionalMemories, context);
        
        // Apply semantic relevance filtering
        Array.filter<Types.Memory>(
            rankedMemories,
            func(memory: Types.Memory) : Bool {
                _calculateContextRelevance(memory, context) >= 0.7
            }
        )
    };

    // Memory Search and Analytics
    public query func searchMemories(
        query: Text,
        options: ?{
            limit: Nat;
            offset: Nat;
            sortBy: {#Relevance; #Time; #Strength};
        }
    ) : async [Types.Memory] {
        let searchResults = _searchMemoriesByContent(query);
        
        switch(options) {
            case (null) { searchResults };
            case (?opts) {
                let sorted = switch(opts.sortBy) {
                    case (#Relevance) { searchResults };
                    case (#Time) {
                        Array.sort<Types.Memory>(
                            searchResults,
                            func(a: Types.Memory, b: Types.Memory) : Int {
                                Int.compare(a.timestamp, b.timestamp)
                            }
                        )
                    };
                    case (#Strength) {
                        Array.sort<Types.Memory>(
                            searchResults,
                            func(a: Types.Memory, b: Types.Memory) : Int {
                                Int.compare(a.strength, b.strength)
                            }
                        )
                    };
                };
                Utils.paginate<Types.Memory>(sorted, opts.offset, opts.limit)
            };
        }
    };

    // Enhanced Helper Functions
    private func _generateMemoryId() : async Text {
        let uuid = await UUID.make();
        nextMemoryId += 1;
        UUID.toText(uuid)
    };

    private func _processMemoryContent(content: Text) : async (Text, [Text]) {
        let sanitizedContent = Utils.sanitizeText(content);
        let extractedTags = _extractRelevantTags(sanitizedContent);
        (sanitizedContent, extractedTags)
    };

    private func _extractRelevantTags(content: Text) : [Text] {
        // TODO: Implement more sophisticated NLP-based tag extraction
        let words = Text.split(content, #text(" "));
        let commonTags = ["important", "urgent", "memory", "experience", "learning"];
        
        Array.filter<Text>(
            commonTags,
            func(tag: Text) : Bool {
                Text.contains(Text.toLower(content), #text(tag))
            }
        )
    };

    private func _findRelevantAssociations(
        content: Text,
        tokenId: Hub.TokenId
    ) : async [Hub.MemoryId] {
        let recentMemories = storage.findMemories(
            #ByTimeRange(Time.now() - 7 * 24 * 3600 * 1000_000_000, Time.now())
        );

        Array.mapFilter<Types.Memory, Hub.MemoryId>(
            recentMemories,
            func(memory: Types.Memory) : ?Hub.MemoryId {
                if (_calculateContentSimilarity(content, memory.content) > 0.7) {
                    ?memory.id
                } else {
                    null
                }
            }
        )
    };

    private func _determineMemoryType(content: Text) : async Types.MemoryType {
        // TODO: Implement more sophisticated content analysis
        if (Text.contains(content, #text("learned")) or 
            Text.contains(content, #text("studied"))) {
            #Learning
        } else if (Text.contains(content, #text("met")) or 
                  Text.contains(content, #text("talked"))) {
            #Interaction
        } else if (Text.contains(content, #text("thought")) or 
                  Text.contains(content, #text("realized"))) {
            #Reflection
        } else if (Text.contains(content, #text("dreamed")) or 
                  Text.contains(content, #text("dreamt"))) {
            #Dream
        } else {
            #Experience
        }
    };

    private func _rankAndFilterMemories(
        memories: [Types.Memory],
        context: Types.RetrievalContext
    ) : async [Types.Memory] {
        let rankedMemories = Array.map<Types.Memory, (Types.Memory, Float)>(
            memories,
            func(memory: Types.Memory) : (Types.Memory, Float) {
                (memory, _calculateContextRelevance(memory, context))
            }
        );

        let sortedMemories = Array.sort<(Types.Memory, Float)>(
            rankedMemories,
            func(a: (Types.Memory, Float), b: (Types.Memory, Float)) : Int {
                if (a.1 > b.1) { -1 }
                else if (a.1 < b.1) { 1 }
                else { 0 }
            }
        );

        Array.map<(Types.Memory, Float), Types.Memory>(
            sortedMemories,
            func(pair: (Types.Memory, Float)) : Types.Memory {
                pair.0
            }
        )
    };

    private func _calculateContextRelevance(
        memory: Types.Memory,
        context: Types.RetrievalContext
    ) : Float {
        let emotionalRelevance = _calculateEmotionalRelevance(
            memory.emotionalState,
            context.currentState
        );

        let temporalRelevance = _calculateTemporalRelevance(
            memory.timestamp,
            Time.now()
        );

        let contentRelevance = _calculateContentSimilarity(
            memory.content,
            context.trigger
        );

        // Weighted combination of relevance factors
        (emotionalRelevance * 0.4) +
        (temporalRelevance * 0.3) +
        (contentRelevance * 0.3)
    };

    private func _calculateEmotionalRelevance(
        memoryState: Hub.EmotionalState,
        currentState: Hub.EmotionalState
    ) : Float {
        let diff = Float.abs(
            Float.fromInt(memoryState.joy - currentState.joy) +
            Float.fromInt(memoryState.sadness - currentState.sadness) +
            Float.fromInt(memoryState.anger - currentState.anger) +
            Float.fromInt(memoryState.fear - currentState.fear) +
            Float.fromInt(memoryState.trust - currentState.trust)
        );
        
        1.0 - (diff / 500.0) // Normalize to 0-1 range
    };

    private func _calculateTemporalRelevance(
        memoryTime: Time.Time,
        currentTime: Time.Time
    ) : Float {
        let timeDiff = Float.abs(Float.fromInt(currentTime - memoryTime));
        let maxDiff = Float.fromInt(30 * 24 * 3600 * 1000_000_000); // 30 days
        1.0 - Float.min(1.0, timeDiff / maxDiff)
    };

    private func _calculateContentSimilarity(text1: Text, text2: Text) : Float {
        // TODO: Implement more sophisticated content similarity
        let words1 = Text.split(Text.toLower(text1), #text(" "));
        let words2 = Text.split(Text.toLower(text2), #text(" "));
        
        let commonWords = Array.filter<Text>(
            words1,
            func(word: Text) : Bool {
                Array.find<Text>(words2, func(w: Text) : Bool = w == word) != null
            }
        );

        Float.fromInt(commonWords.size() * 2) /
        Float.fromInt(words1.size() + words2.size())
    };

    private func _searchMemoriesByContent(query: Text) : [Types.Memory] {
        let allMemories = storage.findMemories(
            #ByTimeRange(0, Time.now())
        );

        Array.mapFilter<Types.Memory, Types.Memory>(
            allMemories,
            func(memory: Types.Memory) : ?Types.Memory {
                if (_calculateContentSimilarity(query, memory.content) > 0.3) {
                    ?memory
                } else {
                    null
                }
            }
        )
    };

    private func _recordMemoryEvent(memory: Types.Memory) : async () {
        await hub.recordEvent(
            #MemoryFormed,
            #MemoryData({
                memoryId = memory.id;
                type = memory.memoryType;
                strength = memory.strength;
            })
        );
    };

    private func _isAuthorized(caller: Principal) : Bool {
        Principal.equal(caller, Principal.fromActor(hub))
    };

    // System Functions
    private stable var stableStorage = {
        memories = [] : [(Hub.MemoryId, Types.Memory)];
        indices = {
            emotionalIndex = [];
            temporalIndex = [];
            associativeIndex = [];
            tagIndex = [];
        };
    };

    system func preupgrade() {
        stableStorage := storage.toStable();
    };

    system func postupgrade() {
        storage.loadStable(stableStorage);
    };
};