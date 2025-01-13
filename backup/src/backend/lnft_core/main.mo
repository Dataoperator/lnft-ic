import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import ICRC7 "./ICRC7";
import Types "./Types";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";

actor class LNFTCore(owner: Principal) {
    private let icrc7 = ICRC7.ICRC7(owner);
    private stable var initialized = false;

    // Minting configuration
    private stable var mintingFee : Nat = 1_000_000_000; // 1 ICP
    private stable var specialMintWindowActive = false;
    
    // Trait probability configuration
    private type TraitProbability = {
        trait: Types.Trait;
        probability: Nat; // 0-100
    };
    
    private var traitProbabilities = Buffer.Buffer<TraitProbability>(0);

    // Initialize the canister
    private func initialize() : async () {
        if (not initialized) {
            // Set up initial trait probabilities
            let initialTraits : [TraitProbability] = [
                {
                    trait = {
                        id = "wisdom";
                        name = "Wisdom";
                        rarity = #Common;
                        supply = null;
                    };
                    probability = 70;
                },
                {
                    trait = {
                        id = "creativity";
                        name = "Creativity";
                        rarity = #Uncommon;
                        supply = null;
                    };
                    probability = 40;
                },
                {
                    trait = {
                        id = "insight";
                        name = "Deep Insight";
                        rarity = #Rare;
                        supply = ?100;
                    };
                    probability = 10;
                }
            ];

            for (trait in initialTraits.vals()) {
                traitProbabilities.add(trait);
            };

            initialized := true;
        };
    };

    // Mint a new LNFT
    public shared({ caller }) func mintLNFT() : async Result.Result<Types.TokenId, Text> {
        // Check minting fee (implement ICP transfer check)
        
        // Generate random traits based on probabilities
        let selectedTraits = Buffer.Buffer<Types.Trait>(0);
        for (traitProb in traitProbabilities.vals()) {
            let random = await Random.blob(); // You'll need to implement proper randomization
            let value = Nat8.toNat(random[0]) % 100;
            
            if (value < traitProb.probability) {
                selectedTraits.add(traitProb.trait);
            };
        };

        // Create initial emotional state
        let initialEmotionalState : Types.EmotionalState = {
            base = "curious";
            intensity = 50;
            modifiers = ["new", "eager"];
            lastUpdate = Time.now();
        };

        // Create LNFT metadata
        let metadata : Types.Metadata = {
            name = "LNFT #" # Nat.toText(icrc7.icrc7_total_supply());
            description = "A living NFT with unique traits and emotions";
            image = null; // Add image generation later
        };

        // Mint the token
        let result = icrc7.mint({
            to = { owner = caller; subaccount = null };
            metadata = metadata;
        });

        switch (result) {
            case (#ok(tokenId)) {
                // Initialize memory and emotional state
                try {
                    let memorySystem = actor("memory-canister-id") : actor {
                        updateEmotionalState : shared(Types.TokenId, Types.EmotionalState) -> async Result.Result<(), Text>;
                    };
                    
                    await memorySystem.updateEmotionalState(tokenId, initialEmotionalState);
                    #ok(tokenId)
                } catch (e) {
                    #err("Failed to initialize LNFT state: " # Error.message(e))
                }
            };
            case (#err(e)) {
                #err("Minting failed: " # e)
            };
        }
    };

    // Get LNFT details
    public query func getLNFT(tokenId: Types.TokenId) : async Result.Result<Types.LNFT, Text> {
        switch (icrc7.icrc7_owner_of(tokenId)) {
            case (?account) {
                switch (icrc7.get_metadata(tokenId)) {
                    case (?metadata) {
                        let memorySystem = actor("memory-canister-id") : actor {
                            getEmotionalState : query (Types.TokenId) -> async ?Types.EmotionalState;
                            getMemories : query (Types.TokenId) -> async [Types.MemoryEntry];
                        };
                        
                        let emotionalState = await memorySystem.getEmotionalState(tokenId);
                        let memories = await memorySystem.getMemories(tokenId);
                        
                        switch (emotionalState) {
                            case (?state) {
                                let memoryBuffer = Buffer.Buffer<Types.MemoryEntry>(0);
                                for (memory in memories.vals()) {
                                    memoryBuffer.add(memory);
                                };

                                #ok({
                                    id = tokenId;
                                    owner = account.owner;
                                    metadata = metadata;
                                    traits = Buffer.toArray(selectedTraits);
                                    emotionalState = state;
                                    memories = memoryBuffer;
                                    created = Time.now(); // You'll need to store this separately
                                    lastInteraction = Time.now(); // You'll need to track this
                                })
                            };
                            case null {
                                #err("Failed to get emotional state")
                            };
                        }
                    };
                    case null {
                        #err("Token metadata not found")
                    };
                }
            };
            case null {
                #err("Token not found")
            };
        }
    };

    // Admin functions
    public shared({ caller }) func updateMintingFee(newFee: Nat) : async Result.Result<(), Text> {
        if (caller != owner) {
            return #err("Unauthorized");
        };
        mintingFee := newFee;
        #ok(())
    };

    public shared({ caller }) func setSpecialMintWindow(active: Bool) : async Result.Result<(), Text> {
        if (caller != owner) {
            return #err("Unauthorized");
        };
        specialMintWindowActive := active;
        #ok(())
    };

    // System functions
    system func preupgrade() {
        // Add state preservation logic
    };

    system func postupgrade() {
        if (not initialized) {
            ignore initialize();
        };
    };
}