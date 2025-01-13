import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Types "../lnft_core/Types";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import IC "../ic.mo";

actor class Cronolink() {
    type HttpRequest = IC.HttpRequest;
    type HttpResponse = IC.HttpResponse;

    private let managementCanister = actor "aaaaa-aa" : actor {
        http_request : shared HttpRequest -> async HttpResponse;
    };

    // Structure for external API configurations
    private type ApiConfig = {
        endpoint: Text;
        apiKey: Text;
    };

    private var llmConfig : ApiConfig = {
        endpoint = "https://api.openai.com/v1/chat/completions";
        apiKey = "" // To be set by admin
    };

    private var voiceConfig : ApiConfig = {
        endpoint = "https://api.elevenlabs.io/v1/text-to-speech";
        apiKey = "" // To be set by admin
    };

    // Store conversation history
    private let conversations = HashMap.HashMap<Types.TokenId, Buffer.Buffer<(Text, Text)>>(0, Nat.equal, Hash.hash);

    // Initialize or get conversation buffer
    private func getConversationBuffer(tokenId: Types.TokenId) : Buffer.Buffer<(Text, Text)> {
        switch (conversations.get(tokenId)) {
            case (?buffer) { buffer };
            case null {
                let newBuffer = Buffer.Buffer<(Text, Text)>(0);
                conversations.put(tokenId, newBuffer);
                newBuffer
            };
        }
    };

    // Handle user message and generate response
    public shared({ caller }) func interact(
        tokenId: Types.TokenId,
        userMessage: Text,
        emotionalState: Types.EmotionalState
    ) : async Result.Result<Text, Text> {
        let conversationBuffer = getConversationBuffer(tokenId);
        
        // Prepare conversation history for context
        var context = "";
        for ((user, ai) in conversationBuffer.vals()) {
            context #= "User: " # user # "\nAssistant: " # ai # "\n";
        };

        // Prepare LLM request
        let prompt = "Current emotional state: " # emotionalState.base # 
                    " (intensity: " # Nat8.toText(emotionalState.intensity) # ")\n" #
                    "Conversation history:\n" # context # "\n" #
                    "User: " # userMessage;

        try {
            let response = await callLLM(prompt);
            conversationBuffer.add((userMessage, response));
            #ok(response)
        } catch (e) {
            #err("Failed to generate response: " # Error.message(e))
        }
    };

    // Call external LLM API
    private func callLLM(prompt: Text) : async Text {
        let requestBody = "{"
            # "\"model\": \"gpt-4\","
            # "\"messages\": [{\"role\": \"system\", \"content\": \"You are a living NFT with emotions and memories.\"}, "
            # "{\"role\": \"user\", \"content\": \"" # prompt # "\"}]"
            # "}";

        let request : HttpRequest = {
            url = llmConfig.endpoint;
            method = "POST";
            body = Text.encodeUtf8(requestBody);
            headers = [
                ("Content-Type", "application/json"),
                ("Authorization", "Bearer " # llmConfig.apiKey)
            ];
        };

        try {
            let response = await managementCanister.http_request(request);
            let responseText = Text.decodeUtf8(response.body);
            switch (responseText) {
                case (?text) { text };
                case null { "Error decoding response" };
            }
        } catch (e) {
            "Error calling LLM API: " # Error.message(e)
        }
    };

    // Get conversation history
    public query func getConversationHistory(tokenId: Types.TokenId) : async [(Text, Text)] {
        switch (conversations.get(tokenId)) {
            case (?buffer) { Buffer.toArray(buffer) };
            case null { [] };
        }
    };

    // Admin functions
    public shared({ caller }) func updateLLMConfig(newConfig: ApiConfig) : async Result.Result<(), Text> {
        // Add proper admin checks here
        llmConfig := newConfig;
        #ok(())
    };

    public shared({ caller }) func updateVoiceConfig(newConfig: ApiConfig) : async Result.Result<(), Text> {
        // Add proper admin checks here
        voiceConfig := newConfig;
        #ok(())
    };

    // Text to speech conversion
    public shared({ caller }) func generateSpeech(
        tokenId: Types.TokenId,
        text: Text
    ) : async Result.Result<Blob, Text> {
        let request : HttpRequest = {
            url = voiceConfig.endpoint;
            method = "POST";
            body = Text.encodeUtf8("{\"text\":\"" # text # "\"}");
            headers = [
                ("Content-Type", "application/json"),
                ("Authorization", "Bearer " # voiceConfig.apiKey)
            ];
        };

        try {
            let response = await managementCanister.http_request(request);
            #ok(response.body)
        } catch (e) {
            #err("Failed to generate speech: " # Error.message(e))
        }
    };

    // YouTube integration
    public func getYouTubeEmbed(videoId: Text) : Text {
        "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/" # 
        videoId # "\" frameborder=\"0\" allowfullscreen></iframe>"
    };

    // System settings and initialization
    private stable var isInitialized = false;
    
    private func initialize() : async () {
        if (not isInitialized) {
            // Initialize with default configurations
            isInitialized := true;
        };
    };

    system func preupgrade() {
        // Add state preservation logic here
    };

    system func postupgrade() {
        if (not isInitialized) {
            // Reinitialize if needed
            ignore initialize();
        };
    };
}