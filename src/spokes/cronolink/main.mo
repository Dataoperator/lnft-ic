import Types "./types";
import Neural "./neural";
import Hub "../../hub/types";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor CronolinkSystem {
    private let neural = Neural.NeuralProcessor();
    
    // State
    private var profiles = HashMap.HashMap<Hub.TokenId, Types.PersonalityProfile>(0, Text.equal, Text.hash);
    private var conversationHistories = HashMap.HashMap<Hub.TokenId, Buffer.Buffer<Types.ConversationEntry>>(0, Text.equal, Text.hash);
    private stable var defaultConfig : Types.ProcessingConfig = {
        emotionalSensitivity = 70;
        memoryThreshold = 50;
        traitInfluence = 60;
        randomnessFactor = 20;
    };

    // External canister references
    private let hub = actor("aaaaa-aa") : actor { 
        getToken : shared (Hub.TokenId) -> async ?Hub.LNFT;
        recordEvent : shared (Hub.EventType, Hub.EventData) -> async ();
    };

    private let memory = actor("aaaaa-aa") : actor {
        createMemory : shared (request: {
            tokenId: Hub.TokenId;
            content: Text;
            strength: Nat;
            timestamp: Time.Time;
            emotionalState: Hub.EmotionalState;
        }) -> async Hub.Result<Hub.MemoryId, Hub.Error>;
        retrieveMemories : shared (tokenId: Hub.TokenId, filter: any) -> async [any];
    };

    private let traits = actor("aaaaa-aa") : actor {
        getTraitsByToken : shared (Hub.TokenId) -> async [any];
        evolveTrait : shared (Hub.TokenId, Hub.TraitId) -> async Hub.Result<(), Hub.Error>;
    };

    // Core Neural Processing
    public shared({ caller }) func process(request: Types.ProcessRequest) : async Hub.Result<Types.NeuralResponse, Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        // Get or create personality profile
        let profile = await _getOrCreateProfile(request.tokenId);

        // Enhance context with conversation history
        let enhancedContext = await _enhanceContext(request);

        // Process neural response
        let response = neural.processInput(
            { request with context = ?enhancedContext },
            profile,
            defaultConfig
        );

        // Record conversation entry
        _recordConversation(request.tokenId, #User, request.input, request.currentState);
        _recordConversation(request.tokenId, #Entity, response.response, response.emotionalImpact);

        // Process suggested actions
        await _processSuggestedActions(request.tokenId, response);

        #ok(response)
    };

    // Profile Management
    public shared({ caller }) func updateProfile(
        tokenId: Hub.TokenId,
        profile: Types.PersonalityProfile
    ) : async Hub.Result<(), Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        profiles.put(tokenId, profile);
        #ok(())
    };

    public shared({ caller }) func updateProcessingConfig(
        config: Types.ProcessingConfig
    ) : async Hub.Result<(), Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        defaultConfig := config;
        #ok(())
    };

    // Query Methods
    public query func getConversationHistory(
        tokenId: Hub.TokenId,
        limit: Nat
    ) : async [Types.ConversationEntry] {
        switch (conversationHistories.get(tokenId)) {
            case (null) { [] };
            case (?history) {
                let arr = Buffer.toArray(history);
                let start = if (arr.size() > limit) {
                    arr.size() - limit
                } else {
                    0
                };
                Array.tabulate<Types.ConversationEntry>(
                    Nat.min(limit, arr.size()),
                    func (i: Nat) : Types.ConversationEntry {
                        arr[start + i]
                    }
                )
            };
        }
    };

    public query func getProfile(tokenId: Hub.TokenId) : async ?Types.PersonalityProfile {
        profiles.get(tokenId)
    };

    // Helper Methods
    private func _isAuthorized(caller: Principal) : Bool {
        Principal.equal(caller, Principal.fromActor(hub))
    };

    private func _recordConversation(
        tokenId: Hub.TokenId,
        speaker: {#User; #Entity},
        content: Text,
        emotionalState: Hub.EmotionalState
    ) {
        let entry : Types.ConversationEntry = {
            timestamp = Time.now();
            speaker = speaker;
            content = content;
            emotionalState = emotionalState;
        };

        switch (conversationHistories.get(tokenId)) {
            case (null) {
                let newHistory = Buffer.Buffer<Types.ConversationEntry>(0);
                newHistory.add(entry);
                conversationHistories.put(tokenId, newHistory);
            };
            case (?history) {
                history.add(entry);
                // Keep only last 100 entries
                if (history.size() > 100) {
                    history.filterEntries(func(i: Nat, _: Types.ConversationEntry) : Bool {
                        i >= (history.size() - 100)
                    });
                };
            };
        };
    };

    private func _enhanceContext(request: Types.ProcessRequest) : async Types.InteractionContext {
        let history = switch (conversationHistories.get(request.tokenId)) {
            case (null) { [] };
            case (?buffer) { 
                Array.freeze(Buffer.toArray(buffer)) 
            };
        };

        {
            recentMemories = switch (request.context) {
                case (null) { [] };
                case (?ctx) { ctx.recentMemories };
            };
            activeTraits = switch (request.context) {
                case (null) { [] };
                case (?ctx) { ctx.activeTraits };
            };
            conversationHistory = history;
            environmentalFactors = [];  // TODO: Implement environmental factors
        }
    };

    private func _getOrCreateProfile(tokenId: Hub.TokenId) : async Types.PersonalityProfile {
        switch (profiles.get(tokenId)) {
            case (?profile) { profile };
            case (null) {
                let token = switch (await hub.getToken(tokenId)) {
                    case (null) {
                        return _createDefaultProfile()
                    };
                    case (?t) { t };
                };

                let profile = {
                    dominantTraits = token.traits;
                    emotionalBaseline = token.emotionalState;
                    responsePatterns = [];
                    learningPreferences = [];
                };

                profiles.put(tokenId, profile);
                profile
            };
        }
    };

    private func _createDefaultProfile() : Types.PersonalityProfile {
        {
            dominantTraits = [];
            emotionalBaseline = {
                joy = 50;
                sadness = 50;
                anger = 50;
                fear = 50;
                trust = 50;
            };
            responsePatterns = [];
            learningPreferences = [];
        }
    };

    private func _processSuggestedActions(
        tokenId: Hub.TokenId,
        response: Types.NeuralResponse
    ) : async () {
        for (action in response.suggestedActions.vals()) {
            switch (action.actionType) {
                case (#FormMemory(data)) {
                    ignore await memory.createMemory({
                        tokenId = tokenId;
                        content = data.content;
                        strength = data.suggestedStrength;
                        timestamp = Time.now();
                        emotionalState = response.emotionalImpact;
                    });
                };
                case (#EvolveTrait(data)) {
                    ignore await traits.evolveTrait(tokenId, data.traitId);
                };
                case (#EmotionalResponse(data)) {
                    // TODO: Implement emotional response processing
                };
                case (#LearnSkill(data)) {
                    // TODO: Implement skill learning
                };
                case (#Custom(data)) {
                    // TODO: Implement custom action processing
                };
            };
        };
    };

    // System Functions
    system func preupgrade() {
        // TODO: Implement stable storage
    };

    system func postupgrade() {
        // TODO: Restore from stable storage
    };
};