            func(trait: Trait) : Bool {
                isTraitAvailable(trait) and
                isCompatibleWithExisting(trait, existingTraits) and
                not traitCategoryExists(trait.category, existingTraits);
            }
        );

        if (availableTraits.size() == 0) {
            return null;
        };

        selectTraitByRarity(availableTraits, distribution);
    };

    private func selectTraitByRarity(
        availableTraits: [Trait],
        distribution: [(RarityLevel, Nat)]
    ) : ?Trait {
        // Generate random number between 0 and 100
        let rand = generateRandomNumber(100);
        var currentProb = 0;

        // Find appropriate rarity level based on random number
        for ((level, prob) in distribution.vals()) {
            currentProb += prob;
            if (rand < currentProb) {
                // Filter traits by selected rarity
                let rarityTraits = Array.filter<Trait>(
                    availableTraits,
                    func(trait: Trait) : Bool { trait.rarity == level }
                );

                if (rarityTraits.size() > 0) {
                    // Select random trait from filtered list
                    let traitIndex = generateRandomNumber(rarityTraits.size());
                    return ?rarityTraits[traitIndex];
                };
            };
        };

        // Fallback to first available trait if distribution selection fails
        if (availableTraits.size() > 0) {
            ?availableTraits[0];
        } else {
            null;
        };
    };

    private func isTraitAvailable(trait: Trait) : Bool {
        switch (trait.maxSupply) {
            case (?max) {
                trait.currentSupply < max;
            };
            case null {
                true;
            };
        };
    };

    private func isCompatibleWithExisting(trait: Trait, existingTraits: [Trait]) : Bool {
        // Check for conflicts
        for (existing in existingTraits.vals()) {
            if (Array.find<Text>(trait.conflicts, func(id: Text) : Bool { id == existing.id }) != null) {
                return false;
            };
        };

        // If trait requires specific compatibilities, check them
        if (trait.compatibility.size() > 0) {
            var hasCompatible = false;
            for (existing in existingTraits.vals()) {
                if (Array.find<Text>(trait.compatibility, func(id: Text) : Bool { id == existing.id }) != null) {
                    hasCompatible := true;
                    break;
                };
            };
            if (not hasCompatible) {
                return false;
            };
        };

        true;
    };

    private func traitCategoryExists(category: TraitCategory, traits: [Trait]) : Bool {
        Array.find<Trait>(traits, func(t: Trait) : Bool { t.category == category }) != null;
    };

    private func calculateTraitRarityScore(trait: Trait) : Nat {
        let baseScore = switch(trait.rarity) {
            case (#Common) 1;
            case (#Uncommon) 2;
            case (#Rare) 5;
            case (#Legendary) 10;
            case (#Mythic) 20;
            case (#Event) 15;
        };

        // Adjust score based on supply if applicable
        switch(trait.maxSupply) {
            case (?max) {
                if (max > 0) {
                    baseScore * (100 - ((trait.currentSupply * 100) / max)) / 100;
                } else {
                    baseScore;
                };
            };
            case null {
                baseScore;
            };
        };
    };

    private func calculateOverallRarity(score: Nat) : Types.RarityLevel {
        if (score >= 50) { #Mythic; }
        else if (score >= 30) { #Legendary; }
        else if (score >= 15) { #Rare; }
        else if (score >= 5) { #Uncommon; }
        else { #Common; };
    };

    private func checkTraitCombinations(traits: [Trait]) : [Text] {
        let effects = Buffer.Buffer<Text>(0);
        let combinations = generateTraitCombinations(traits);

        for (combo in combinations.vals()) {
            let comboEffects = checkSpecificCombination(combo);
            for (effect in comboEffects.vals()) {
                effects.add(effect);
            };
        };

        Buffer.toArray(effects);
    };

    private func generateTraitCombinations(traits: [Trait]) : [[Trait]] {
        let combinations = Buffer.Buffer<[Trait]>(0);
        
        // Generate all possible pairs
        for (i in Iter.range(0, traits.size() - 2)) {
            for (j in Iter.range(i + 1, traits.size() - 1)) {
                combinations.add([traits[i], traits[j]]);
            };
        };

        // Generate all possible triplets if beneficial
        if (traits.size() >= 3) {
            for (i in Iter.range(0, traits.size() - 3)) {
                for (j in Iter.range(i + 1, traits.size() - 2)) {
                    for (k in Iter.range(j + 1, traits.size() - 1)) {
                        combinations.add([traits[i], traits[j], traits[k]]);
                    };
                };
            };
        };

        Buffer.toArray(combinations);
    };

    private func checkSpecificCombination(traits: [Trait]) : [Text] {
        let effects = Buffer.Buffer<Text>(0);

        // Example combination checks (to be expanded based on game design)
        if (traits.size() >= 2) {
            // Check for personality + ability synergies
            let hasPersonality = Array.find<Trait>(traits, func(t) { t.category == #Personality }) != null;
            let hasAbility = Array.find<Trait>(traits, func(t) { t.category == #Ability }) != null;
            
            if (hasPersonality and hasAbility) {
                effects.add("personality_ability_synergy");
            };

            // Check for special background combinations
            let backgrounds = Array.filter<Trait>(traits, func(t) { t.category == #Background });
            if (backgrounds.size() >= 2) {
                effects.add("complex_background");
            };
        };

        if (traits.size() >= 3) {
            // Check for legendary combinations
            let legendaryCount = Array.filter<Trait>(
                traits,
                func(t) { t.rarity == #Legendary or t.rarity == #Mythic }
            ).size();

            if (legendaryCount >= 2) {
                effects.add("legendary_synergy");
            };
        };

        Buffer.toArray(effects);
    };

    private func generateFallbackTrait(category: TraitCategory) : Trait {
        {
            id = "fallback_" # debug_show(category);
            name = "Basic " # debug_show(category);
            description = "A basic trait for " # debug_show(category);
            category = category;
            rarity = #Common;
            maxSupply = null;
            currentSupply = 0;
            modifiers = {
                emotional = [];
                learning = [];
                memory = [];
                special = [];
            };
            compatibility = [];
            conflicts = [];
            metadata = [];
        };
    };

    private func validateTrait(trait: Trait) : Bool {
        if (Text.size(trait.id) == 0) {
            return false;
        };

        if (Text.size(trait.name) == 0) {
            return false;
        };

        switch (trait.maxSupply) {
            case (?max) {
                if (max == 0) {
                    return false;
                };
            };
            case null {};
        };

        true;
    };

    private func generateRandomNumber(max: Nat) : Nat {
        // TODO: Implement secure random number generation
        // For now, using a simple timestamp-based approach
        let now = Int.abs(Time.now());
        now % max;
    };

    // System functions
    system func preupgrade() {
        // Implementation for stable storage
    };

    system func postupgrade() {
        // Implementation for stable storage restoration
    };
};