                getDimensionValue(dimensions[1]) + // trust
                getDimensionValue(dimensions[6]) - // anger
                getDimensionValue(dimensions[2]) - // fear
                getDimensionValue(dimensions[5])   // disgust
            ) / 4.0;

            {
                valence = Float.max(-1.0, Float.min(1.0, valence));
                arousal = Float.max(0.0, Float.min(1.0, arousal));
                dominance = Float.max(-1.0, Float.min(1.0, dominance));
            }
        };

        // System management functions
        public func reset(): async () {
            current_state := initializeEmotionalState();
            Buffer.clear(state_transitions);
            emotional_memory := TrieMap.TrieMap<Text, EmotionalMemory>(Text.equal, Text.hash);
            neural_weights := TrieMap.TrieMap<(Text, Text), NeuralWeight>(equal_tuple, hash_tuple);
        };

        public func adjustDecayRate(newRate: Float): async Result.Result<Float, Text> {
            if (newRate < 0.0 or newRate > 1.0) {
                return #err("Decay rate must be between 0 and 1");
            };

            current_state := {
                current_state with
                decay_rate = newRate;
            };

            #ok(newRate)
        };

        public func pruneOldMemories(age_threshold: Time.Time): async Nat {
            var pruned_count = 0;
            let current_time = Time.now();

            for ((id, memory) in emotional_memory.entries()) {
                if (memory.timestamp < age_threshold) {
                    emotional_memory.delete(id);
                    pruned_count += 1;
                };
            };

            pruned_count
        };

        // Advanced memory operations
        public func consolidateMemories(): async () {
            let memories = Buffer.Buffer<(Text, EmotionalMemory)>(0);
            
            // Collect all memories
            for ((id, memory) in emotional_memory.entries()) {
                memories.add((id, memory));
            };

            // Sort by intensity
            // Note: This is a simplified version. In practice, we would use a more sophisticated sorting algorithm
            let sorted_memories = Array.sort<(Text, EmotionalMemory)>(
                Buffer.toArray(memories),
                func(a, b) {
                    a.1.intensity > b.1.intensity
                }
            );

            // Consolidate similar memories
            for (i in Iter.range(0, sorted_memories.size() - 2)) {
                let (id1, mem1) = sorted_memories[i];
                let (id2, mem2) = sorted_memories[i + 1];

                if (areMemoriesSimilar(mem1, mem2)) {
                    // Merge memories
                    let merged = mergeMemories(mem1, mem2);
                    emotional_memory.put(id1, merged);
                    emotional_memory.delete(id2);
                };
            };
        };

        private func areMemoriesSimilar(mem1: EmotionalMemory, mem2: EmotionalMemory): Bool {
            let intensity_diff = Float.abs(mem1.intensity - mem2.intensity);
            let time_diff = Float.abs(Float.fromInt(mem1.timestamp - mem2.timestamp));
            
            // Memories are similar if their intensities are close and they occurred near each other in time
            intensity_diff < 0.2 and time_diff < 3600_000_000_000 // 1 hour in nanoseconds
        };

        private func mergeMemories(mem1: EmotionalMemory, mem2: EmotionalMemory): EmotionalMemory {
            let merged_associations = Array.append<AssociativeLink>(
                mem1.associations,
                mem2.associations
            );

            {
                timestamp = Time.now();
                intensity = (mem1.intensity + mem2.intensity) / 2.0;
                context = mem1.context;
                associations = merged_associations;
                decay_rate = Float.min(mem1.decay_rate, mem2.decay_rate);
            }
        };

        // Advanced query functions
        public query func getMostIntenseMemories(limit: Nat): async [EmotionalMemory] {
            let memories = Buffer.Buffer<EmotionalMemory>(0);
            
            for ((_, memory) in emotional_memory.entries()) {
                memories.add(memory);
            };

            let sorted = Array.sort<EmotionalMemory>(
                Buffer.toArray(memories),
                func(a, b) { a.intensity > b.intensity }
            );

            Array.subArray<EmotionalMemory>(sorted, 0, Nat.min(limit, sorted.size()))
        };

        public query func getAssociatedMemories(memory_id: Text): async [EmotionalMemory] {
            switch (emotional_memory.get(memory_id)) {
                case (null) [];
                case (?memory) {
                    let associated = Buffer.Buffer<EmotionalMemory>(0);
                    
                    for (link in memory.associations.vals()) {
                        switch (emotional_memory.get(link.target_id)) {
                            case (?target_memory) {
                                associated.add(target_memory);
                            };
                            case (null) {};
                        };
                    };
                    
                    Buffer.toArray(associated)
                };
            }
        };

        public query func getEmotionalStateAtTime(timestamp: Time.Time): async ?EmotionalState {
            for ((state_time, state) in state_transitions.vals()) {
                if (state_time == timestamp) {
                    return ?state;
                };
            };
            null
        };

        // Performance monitoring
        public query func getPerformanceMetrics(): async {
            memory_count: Nat;
            weight_count: Nat;
            state_count: Nat;
            oldest_memory: Time.Time;
            newest_memory: Time.Time;
        } {
            var oldest = Time.now();
            var newest = 0;
            
            for ((_, memory) in emotional_memory.entries()) {
                if (memory.timestamp < oldest) {
                    oldest := memory.timestamp;
                };
                if (memory.timestamp > newest) {
                    newest := memory.timestamp;
                };
            };

            {
                memory_count = emotional_memory.size();
                weight_count = neural_weights.size();
                state_count = state_transitions.size();
                oldest_memory = oldest;
                newest_memory = newest;
            }
        };
    };
};