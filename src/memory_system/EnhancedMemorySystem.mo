                var hasTag = false;
                label tagSearch for (searchTag in tags.vals()) {
                    if (Array.find<Text>(memory.tags, func(t) = t == searchTag) != null) {
                        hasTag := true;
                        break tagSearch;
                    };
                };
                if (not hasTag) {
                    return false;
                };
            };
            case null {};
        };

        // Emotional states filter
        switch (filter.emotional_states) {
            case (?states) {
                switch (memory.emotional_impact) {
                    case (?impact) {
                        if (not Array.find<Text>(states, func(s) = s == impact.base)) {
                            return false;
                        };
                    };
                    case null return false;
                };
            };
            case null {};
        };

        // Importance threshold
        switch (filter.importance_threshold) {
            case (?threshold) {
                if (memory.importance < threshold) {
                    return false;
                };
            };
            case null {};
        };

        // Time range
        switch (filter.start_time) {
            case (?start) {
                if (memory.timestamp < start) {
                    return false;
                };
            };
            case null {};
        };

        switch (filter.end_time) {
            case (?end) {
                if (memory.timestamp > end) {
                    return false;
                };
            };
            case null {};
        };

        true;
    };

    // Get memory statistics
    public query func getMemoryStats(tokenId: TokenId) : async Result.Result<MemoryStats, Text> {
        switch (memories.get(tokenId)) {
            case (?memBuffer) {
                let categoryCount = HashMap.HashMap<MemoryCategory, Nat>(5, func(a: MemoryCategory, b: MemoryCategory) : Bool { a == b }, Hash.hash);
                let emotionCount = HashMap.HashMap<Text, Nat>(10, Text.equal, Text.hash);
                let tagCount = HashMap.HashMap<Text, Nat>(50, Text.equal, Text.hash);

                var totalMemories = memBuffer.size();
                var compressedCount = 0;

                for (memory in memBuffer.vals()) {
                    // Count by category
                    switch (categoryCount.get(memory.category)) {
                        case (?count) categoryCount.put(memory.category, count + 1);
                        case null categoryCount.put(memory.category, 1);
                    };

                    // Count emotions
                    switch (memory.emotional_impact) {
                        case (?impact) {
                            switch (emotionCount.get(impact.base)) {
                                case (?count) emotionCount.put(impact.base, count + 1);
                                case null emotionCount.put(impact.base, 1);
                            };
                        };
                        case null {};
                    };

                    // Count tags
                    for (tag in memory.tags.vals()) {
                        switch (tagCount.get(tag)) {
                            case (?count) tagCount.put(tag, count + 1);
                            case null tagCount.put(tag, 1);
                        };
                    };

                    // Count compressed memories
                    switch (memory.metadata) {
                        case (?_) compressedCount += 1;
                        case null {};
                    };
                };

                let stats : MemoryStats = {
                    total_memories = totalMemories;
                    compressed_memories = compressedCount;
                    memory_by_category = Iter.toArray(categoryCount.entries());
                    emotional_distribution = Iter.toArray(emotionCount.entries());
                    top_tags = Array.sort<(Text, Nat)>(
                        Iter.toArray(tagCount.entries()),
                        func(a: (Text, Nat), b: (Text, Nat)) : Bool { a.1 > b.1 }
                    );
                };

                #ok(stats);
            };
            case null #err("Memory system not initialized");
        };
    };

    // Upgrade capacity (e.g., when LNFT levels up)
    public shared({ caller }) func upgradeMemoryCapacity(
        tokenId: TokenId,
        increaseAmount: Nat
    ) : async Result.Result<MemoryCapacity, Text> {
        switch (memoryCapacities.get(tokenId)) {
            case (?capacity) {
                let updatedCapacity = {
                    capacity with
                    maximum = capacity.maximum + increaseAmount;
                    compression_threshold = (capacity.maximum + increaseAmount) / 2;
                };
                memoryCapacities.put(tokenId, updatedCapacity);
                #ok(updatedCapacity);
            };
            case null #err("Memory system not initialized");
        };
    };

    // System hooks for upgrade safety
    system func preupgrade() {
        stableMemories := Array.map<(TokenId, Buffer.Buffer<EnhancedMemoryEntry>), (TokenId, [EnhancedMemoryEntry])>(
            Iter.toArray(memories.entries()),
            func((id, buf)) = (id, Buffer.toArray(buf))
        );
        stableEmotionalStates := Iter.toArray(emotionalStates.entries());
        stableMemoryCapacities := Iter.toArray(memoryCapacities.entries());
        stableVersion += 1;
    };

    system func postupgrade() {
        // Initialize runtime data structures from stable storage
        for ((id, memArray) in stableMemories.vals()) {
            let buf = Buffer.fromArray<EnhancedMemoryEntry>(memArray);
            memories.put(id, buf);
        };
        
        for ((id, state) in stableEmotionalStates.vals()) {
            emotionalStates.put(id, state);
        };
        
        for ((id, capacity) in stableMemoryCapacities.vals()) {
            memoryCapacities.put(id, capacity);
        };

        // Clear stable storage
        stableMemories := [];
        stableEmotionalStates := [];
        stableMemoryCapacities := [];
    };
}
