    private func generateBatchId() : Text {
        let timestamp = Int.toText(Time.now());
        let randomSuffix = Nat.toText(generateRandomNat());
        timestamp # "-" # randomSuffix;
    };

    private func generateRandomNat() : Nat {
        // TODO: Implement secure random number generation
        let now = Int.abs(Time.now());
        now % 10000;  // 4-digit random number for now
    };

    private func generateRandomSeed() : async Blob {
        // TODO: Implement secure random seed generation
        // For now, using time-based seed
        let now = Int.abs(Time.now());
        Text.encodeUtf8(Int.toText(now));
    };

    // System management functions
    public shared({ caller }) func updateConfig(
        newConfig: MintConfig
    ) : async Result.Result<(), Text> {
        // TODO: Add proper access control
        if (not validateConfig(newConfig)) {
            return #err("Invalid configuration");
        };

        config := newConfig;
        #ok();
    };

    private func validateConfig(newConfig: MintConfig) : Bool {
        if (newConfig.batchSizeLimit == 0) {
            return false;
        };

        if (newConfig.hourlyLimit == 0) {
            return false;
        };

        if (newConfig.traitRequirements.minTraits > newConfig.traitRequirements.maxTraits) {
            return false;
        };

        true;
    };

    // Query functions
    public query func getMetrics() : async MintMetrics {
        mintMetrics;
    };

    public query func getConfig() : async MintConfig {
        config;
    };

    public query func getBatchStatuses(
        startTime: Time.Time,
        endTime: Time.Time
    ) : async [BatchStatus] {
        Array.filter<BatchStatus>(
            Iter.toArray(batchStatuses.vals()),
            func(status: BatchStatus) : Bool {
                status.timestamp >= startTime and status.timestamp <= endTime
            }
        );
    };

    // Integration with rate limiting
    private stable var hourlyMints : [(Principal, (Nat, Time.Time))] = [];
    private let userMints = HashMap.fromIter<Principal, (Nat, Time.Time)>(
        hourlyMints.vals(),
        10,
        Principal.equal,
        Principal.hash
    );

    private func updateRateLimit(user: Principal, quantity: Nat) : Bool {
        let currentTime = Time.now();
        
        switch (userMints.get(user)) {
            case (?record) {
                let (count, timestamp) = record;
                
                // Reset if more than an hour has passed
                if (currentTime - timestamp > 3600_000_000_000) {
                    userMints.put(user, (quantity, currentTime));
                    true;
                } else {
                    // Check if new quantity would exceed limit
                    if (count + quantity > config.hourlyLimit) {
                        false;
                    } else {
                        userMints.put(user, (count + quantity, timestamp));
                        true;
                    };
                };
            };
            case null {
                userMints.put(user, (quantity, currentTime));
                true;
            };
        };
    };

    // Event management
    public shared({ caller }) func addEvent(
        eventId: Text,
        multiplier: Nat
    ) : async Result.Result<(), Text> {
        // TODO: Add proper access control
        config := {
            config with
            eventMultipliers = Array.append(
                config.eventMultipliers,
                [(eventId, multiplier)]
            );
        };
        #ok();
    };

    public shared({ caller }) func removeEvent(
        eventId: Text
    ) : async Result.Result<(), Text> {
        // TODO: Add proper access control
        config := {
            config with
            eventMultipliers = Array.filter<(Text, Nat)>(
                config.eventMultipliers,
                func((id, _)) : Bool { id != eventId }
            );
        };
        #ok();
    };

    // Cleanup old batch statuses
    public shared({ caller }) func cleanupOldBatches(
        maxAge: Nat  // in seconds
    ) : async Nat {
        let currentTime = Time.now();
        let cutoffTime = currentTime - (maxAge * 1_000_000_000);
        let oldBatches = Buffer.Buffer<Text>(0);

        for ((id, status) in batchStatuses.entries()) {
            if (status.timestamp < cutoffTime) {
                oldBatches.add(id);
            };
        };

        for (id in oldBatches.vals()) {
            batchStatuses.delete(id);
        };

        oldBatches.size();
    };

    // System functions
    system func preupgrade() {
        hourlyMints := Iter.toArray(userMints.entries());
    };

    system func postupgrade() {
        hourlyMints := [];
    };
};