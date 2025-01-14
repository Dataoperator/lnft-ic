import Types "./types";
import Hub "../../hub/types";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor TraitSystem {
    private type Trait = Types.Trait;
    private type TraitEvolutionEvent = Types.TraitEvolutionEvent;
    private type TraitActivation = Types.TraitActivation;

    // State
    private var traits = HashMap.HashMap<Hub.TraitId, Trait>(0, Text.equal, Text.hash);
    private var evolutions = Buffer.Buffer<TraitEvolutionEvent>(0);
    private var activeTraits = Buffer.Buffer<TraitActivation>(0);
    private var traitsByToken = HashMap.HashMap<Hub.TokenId, [Hub.TraitId]>(0, Text.equal, Text.hash);

    private let hub = actor("aaaaa-aa") : actor { 
        getToken : shared (Hub.TokenId) -> async ?Hub.LNFT;
        recordEvent : shared (Hub.EventType, Hub.EventData) -> async ();
    };

    private let memorySystem = actor("aaaaa-aa") : actor {
        createMemory : shared (Types.CreateMemoryRequest) -> async Hub.Result<Hub.MemoryId, Hub.Error>;
    };

    // Trait Management
    public shared({ caller }) func createTrait(trait: Trait) : async Hub.Result<(), Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        traits.put(trait.id, trait);
        #ok(())
    };

    public shared({ caller }) func evolveTrait(tokenId: Hub.TokenId, traitId: Hub.TraitId) : async Hub.Result<(), Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        switch (traits.get(traitId)) {
            case (null) { #err(#NotFound) };
            case (?trait) {
                let currentLevel = trait.level;
                let newLevel = currentLevel + 1;

                // Check evolution requirements
                switch (await _checkEvolutionRequirements(tokenId, trait)) {
                    case (#err(e)) { return #err(e) };
                    case (#ok(_)) {
                        // Create evolution event
                        let event : TraitEvolutionEvent = {
                            traitId = traitId;
                            tokenId = tokenId;
                            timestamp = Time.now();
                            previousLevel = currentLevel;
                            newLevel = newLevel;
                            catalyst = null;
                        };

                        evolutions.add(event);

                        // Update trait
                        let updatedTrait : Trait = {
                            trait with
                            level = newLevel;
                            experience = 0; // Reset experience for new level
                        };
                        traits.put(traitId, updatedTrait);

                        // Record memory of evolution
                        ignore await _recordEvolutionMemory(tokenId, event);

                        // Notify hub
                        await hub.recordEvent(
                            #TraitEvolution,
                            #TraitData({
                                traitId = traitId;
                                changeType = #Evolved;
                                newLevel = ?newLevel;
                            })
                        );

                        #ok(())
                    };
                }
            };
        }
    };

    public shared({ caller }) func activateTrait(tokenId: Hub.TokenId, traitId: Hub.TraitId, context: Text) : async Hub.Result<(), Hub.Error> {
        if (not _isAuthorized(caller)) {
            return #err(#Unauthorized);
        };

        switch (traits.get(traitId)) {
            case (null) { #err(#NotFound) };
            case (?trait) {
                let activation : TraitActivation = {
                    traitId = traitId;
                    tokenId = tokenId;
                    timestamp = Time.now();
                    duration = null;
                    context = context;
                };

                activeTraits.add(activation);
                #ok(())
            };
        }
    };

    // Query Methods
    public query func getTraitsByToken(tokenId: Hub.TokenId) : async [Trait] {
        switch (traitsByToken.get(tokenId)) {
            case (null) { [] };
            case (?traitIds) {
                Array.mapFilter<Hub.TraitId, Trait>(
                    traitIds,
                    func (id: Hub.TraitId) : ?Trait = traits.get(id)
                );
            };
        }
    };

    public query func getTraitEvolutions(tokenId: Hub.TokenId) : async [TraitEvolutionEvent] {
        Buffer.toArray(
            Buffer.mapFilter<TraitEvolutionEvent, TraitEvolutionEvent>(
                evolutions,
                func (event: TraitEvolutionEvent) : ?TraitEvolutionEvent {
                    if (event.tokenId == tokenId) { ?event } else { null }
                }
            )
        )
    };

    public query func getActivatedTraits(tokenId: Hub.TokenId) : async [TraitActivation] {
        Buffer.toArray(
            Buffer.mapFilter<TraitActivation, TraitActivation>(
                activeTraits,
                func (activation: TraitActivation) : ?TraitActivation {
                    if (activation.tokenId == tokenId) { ?activation } else { null }
                }
            )
        )
    };

    // Helper Methods
    private func _isAuthorized(caller: Principal) : Bool {
        Principal.equal(caller, Principal.fromActor(hub))
    };

    private func _checkEvolutionRequirements(tokenId: Hub.TokenId, trait: Trait) : async Hub.Result<(), Hub.Error> {
        switch (await hub.getToken(tokenId)) {
            case (null) { #err(#NotFound) };
            case (?token) {
                // Check level requirement
                if (trait.level < trait.requirements.level) {
                    return #err(#InvalidRequest);
                };

                // Check experience requirement
                if (trait.experience < trait.requirements.experience) {
                    return #err(#InvalidRequest);
                };

                // Check required traits
                let currentTraits = await getTraitsByToken(tokenId);
                let hasRequiredTraits = Array.all<Hub.TraitId>(
                    trait.requirements.traits,
                    func (requiredId: Hub.TraitId) : Bool {
                        Array.some<Trait>(
                            currentTraits,
                            func (t: Trait) : Bool = t.id == requiredId
                        )
                    }
                );

                if (not hasRequiredTraits) {
                    return #err(#InvalidRequest);
                };

                #ok(())
            };
        }
    };

    private func _recordEvolutionMemory(tokenId: Hub.TokenId, event: TraitEvolutionEvent) : async Hub.Result<Hub.MemoryId, Hub.Error> {
        let trait = switch (traits.get(event.traitId)) {
            case (null) { return #err(#NotFound) };
            case (?t) { t };
        };

        let content = "Evolved trait '" # trait.name # "' from level " # 
                     Int.toText(event.previousLevel) # " to " # 
                     Int.toText(event.newLevel);

        await memorySystem.createMemory({
            tokenId = tokenId;
            content = content;
            strength = 75; // Evolution memories are significant
            timestamp = event.timestamp;
            emotionalState = {
                joy = 80;
                sadness = 0;
                anger = 0;
                fear = 0;
                trust = 90;
            };
        })
    };

    // System Functions
    system func preupgrade() {
        // TODO: Implement stable storage
    };

    system func postupgrade() {
        // TODO: Implement stable storage restoration
    };
}