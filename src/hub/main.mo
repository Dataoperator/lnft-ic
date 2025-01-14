import Types "./types";
import State "./state";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";
import NeuralCore "../lib/neural_core";
import Buffer "mo:base/Buffer";

actor class Hub() = this {
    private stable var stableState = {
        lnfts = [] : [(Types.TokenId, Types.LNFT)];
        events = [] : [Types.Event];
        neuralStates = [] : [(Types.TokenId, Types.NeuralState)];
        nextTokenId = 0 : Nat;
    };

    private let state = State.State();
    private let neuralCore = NeuralCore.NeuralCore();

    // Neural Mesh Integration
    public shared({ caller }) func processNeural(tokenId: Types.TokenId, input: Types.NeuralInput) : async Types.Result<Types.NeuralResponse, Types.Error> {
        switch (state.getToken(tokenId)) {
            case (null) { #err(#NotFound) };
            case (?token) {
                if (not Principal.equal(token.owner, caller)) {
                    return #err(#Unauthorized);
                };

                // Process through neural mesh
                let neuralState = await neuralCore.processStimulus({
                    tokenId = tokenId;
                    input = input;
                    currentState = token.neuralState;
                    emotionalContext = token.emotionalState;
                    traits = token.traits;
                    memories = token.memories;
                });

                // Update token state
                let updatedToken = {
                    token with
                    neuralState = neuralState.newState;
                    emotionalState = neuralState.emotionalImpact;
                };
                state.updateToken(tokenId, updatedToken);

                // Trigger neural propagation across mesh
                await propagateNeuralActivity(tokenId, neuralState);

                #ok({
                    response = neuralState.response;
                    emotionalImpact = neuralState.emotionalImpact;
                    memoryFormation = neuralState.memoryFormation;
                    traitEvolution = neuralState.traitEvolution;
                })
            };
        }
    };

    // Memory Formation with Neural Context
    public shared({ caller }) func formMemory(tokenId: Types.TokenId, input: Types.MemoryInput) : async Types.Result<Types.MemoryId, Types.Error> {
        switch (state.getToken(tokenId)) {
            case (null) { #err(#NotFound) };
            case (?token) {
                if (not Principal.equal(token.owner, caller)) {
                    return #err(#Unauthorized);
                };

                // Process memory through neural core
                let memoryResult = await neuralCore.processMemoryFormation({
                    tokenId = tokenId;
                    input = input;
                    neuralState = token.neuralState;
                    emotionalContext = token.emotionalState;
                    existingMemories = token.memories;
                });

                // Update token state
                let updatedToken = {
                    token with
                    memories = Array.append(token.memories, [memoryResult.memoryId]);
                    neuralState = memoryResult.newNeuralState;
                };
                state.updateToken(tokenId, updatedToken);

                // Trigger memory consolidation
                await consolidateMemories(tokenId);

                #ok(memoryResult.memoryId)
            };
        }
    };

    // Trait Evolution with Neural Influence
    public shared({ caller }) func evolveTrait(tokenId: Types.TokenId, input: Types.TraitInput) : async Types.Result<Types.TraitEvolution, Types.Error> {
        switch (state.getToken(tokenId)) {
            case (null) { #err(#NotFound) };
            case (?token) {
                if (not Principal.equal(token.owner, caller)) {
                    return #err(#Unauthorized);
                };

                // Process trait evolution through neural core
                let evolutionResult = await neuralCore.processTraitEvolution({
                    tokenId = tokenId;
                    input = input;
                    currentTraits = token.traits;
                    neuralState = token.neuralState;
                    emotionalContext = token.emotionalState;
                });

                // Update token state
                let updatedToken = {
                    token with
                    traits = evolutionResult.newTraits;
                    neuralState = evolutionResult.newNeuralState;
                };
                state.updateToken(tokenId, updatedToken);

                // Trigger trait propagation
                await propagateTraitEvolution(tokenId, evolutionResult);

                #ok(evolutionResult)
            };
        }
    };

    // Social Interaction Processing
    public shared({ caller }) func processSocialInteraction(
        tokenId: Types.TokenId, 
        targetId: Types.TokenId,
        interaction: Types.SocialInteraction
    ) : async Types.Result<Types.SocialResponse, Types.Error> {
        switch (state.getToken(tokenId)) {
            case (null) { #err(#NotFound) };
            case (?initiator) {
                switch (state.getToken(targetId)) {
                    case (null) { #err(#NotFound) };
                    case (?target) {
                        if (not Principal.equal(initiator.owner, caller)) {
                            return #err(#Unauthorized);
                        };

                        // Process social interaction through neural core
                        let interactionResult = await neuralCore.processSocialInteraction({
                            initiatorId = tokenId;
                            targetId = targetId;
                            interaction = interaction;
                            initiatorState = initiator.neuralState;
                            targetState = target.neuralState;
                        });

                        // Update both tokens
                        let updatedInitiator = {
                            initiator with
                            neuralState = interactionResult.initiatorState;
                            emotionalState = interactionResult.initiatorEmotion;
                        };
                        let updatedTarget = {
                            target with
                            neuralState = interactionResult.targetState;
                            emotionalState = interactionResult.targetEmotion;
                        };

                        state.updateToken(tokenId, updatedInitiator);
                        state.updateToken(targetId, updatedTarget);

                        // Trigger social propagation
                        await propagateSocialInteraction(tokenId, targetId, interactionResult);

                        #ok(interactionResult)
                    };
                }
            };
        }
    };

    // Neural Propagation Helpers
    private func propagateNeuralActivity(tokenId: Types.TokenId, neuralState: Types.NeuralState) : async () {
        let connectedTokens = await state.getConnectedTokens(tokenId);
        for (targetId in connectedTokens.vals()) {
            await processNeuralPropagation(tokenId, targetId, neuralState);
        };
    };

    private func consolidateMemories(tokenId: Types.TokenId) : async () {
        let token = switch (state.getToken(tokenId)) {
            case (null) { return };
            case (?t) { t };
        };

        let consolidationResult = await neuralCore.consolidateMemories({
            tokenId = tokenId;
            memories = token.memories;
            neuralState = token.neuralState;
            emotionalContext = token.emotionalState;
        });

        let updatedToken = {
            token with
            memories = consolidationResult.memories;
            neuralState = consolidationResult.newNeuralState;
        };
        state.updateToken(tokenId, updatedToken);
    };

    // System Upgrade Hooks
    system func preupgrade() {
        stableState := state.toStable();
    };

    system func postupgrade() {
        state.loadStable(stableState);
    };
};