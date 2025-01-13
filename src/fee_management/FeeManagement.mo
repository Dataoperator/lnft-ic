    private func createFeeBreakdown(
        baseAmount: Nat,
        finalAmount: Nat,
        config: TokenFeeConfig,
        batchSize: Nat,
        isWhitelisted: Bool
    ) : Types.FeeBreakdown {
        let supplyAdjustment = (baseAmount * config.supplyMultiplier * (marketState.totalSupply / 1000)) / 100;
        let volumeAdjustment = (baseAmount * config.volumeMultiplier * (marketState.mintVolume24h / 100)) / 100;
        let eventAdjustment = Array.foldLeft<Text, Nat>(
            marketState.activeEvents,
            0,
            func(acc: Nat, _: Text) : Nat {
                acc + (baseAmount * config.eventMultiplier) / 100
            }
        );
        let batchDiscount = if (batchSize > 1) {
            (baseAmount * config.batchDiscountRate) / 100
        } else {
            0
        };
        let whitelistDiscount = if (isWhitelisted) {
            (baseAmount * config.whitelistDiscount) / 100
        } else {
            0
        };

        {
            baseFee = baseAmount;
            supplyAdjustment = supplyAdjustment;
            volumeAdjustment = volumeAdjustment;
            eventAdjustment = eventAdjustment;
            batchDiscount = batchDiscount;
            whitelistDiscount = whitelistDiscount;
        };
    };

    private func updateMarketConditions(
        mintQuantity: Nat,
        feeAmount: Nat
    ) : async () {
        let currentTime = Time.now();
        
        // Update 24h metrics
        if (currentTime - marketState.lastUpdate > 24 * 60 * 60 * 1_000_000_000) {
            // Reset 24h metrics if more than 24h has passed
            marketState := {
                marketState with
                mintVolume24h = mintQuantity;
                avgFee24h = feeAmount;
                lastUpdate = currentTime;
            };
        } else {
            // Update rolling 24h metrics
            marketState := {
                marketState with
                mintVolume24h = marketState.mintVolume24h + mintQuantity;
                avgFee24h = (marketState.avgFee24h + feeAmount) / 2;
                totalSupply = marketState.totalSupply + mintQuantity;
                lastUpdate = currentTime;
            };
        };
    };

    private func recordFeeHistory(
        tokenType: TokenType,
        amount: Nat,
        batchSize: Nat
    ) {
        let entry : FeeHistoryEntry = {
            timestamp = Time.now();
            tokenType = tokenType;
            amount = amount;
            batchSize = batchSize;
            eventIds = marketState.activeEvents;
        };

        // Keep only last 1000 entries
        if (feeHistory.size() >= 1000) {
            feeHistory := Array.tabulate<FeeHistoryEntry>(
                1000,
                func(i: Nat) : FeeHistoryEntry {
                    if (i == 999) {
                        entry
                    } else {
                        feeHistory[i + 1]
                    }
                }
            );
        } else {
            feeHistory := Array.append(feeHistory, [entry]);
        };
    };

    private func getActiveEventModifiers() : [(Text, Nat)] {
        Array.map<Text, (Text, Nat)>(
            marketState.activeEvents,
            func(eventId: Text) : (Text, Nat) {
                (eventId, 100) // Default modifier of 100%
            }
        );
    };

    private func validateFeeConfig(config: TokenFeeConfig) : Bool {
        if (config.baseFee == 0) {
            return false;
        };

        if (config.maxFee < config.minFee) {
            return false;
        };

        if (config.batchDiscountRate > 100) {
            return false;
        };

        if (config.whitelistDiscount > 100) {
            return false;
        };

        true;
    };

    private func isWhitelisted(user: Principal) : Bool {
        Array.find<Principal>(
            whitelistedUsers,
            func(p: Principal) : Bool { p == user }
        ) != null;
    };

    private func getTokenCanisterId(tokenType: TokenType) : Text {
        switch(tokenType) {
            case (#ICP) { "ryjl3-tyaaa-aaaaa-aaaba-cai" };
            case (#ICRC1(canisterId)) { Principal.toText(canisterId) };
            case (#ICRC2(canisterId)) { Principal.toText(canisterId) };
        };
    };

    // Add multi-token ledger management
    private func getTokenLedger(tokenType: TokenType) : actor {
        transfer : shared ICRCTypes.TransferArg -> async ICRCTypes.TransferResult;
        icrc1_balance_of : shared query ICRCTypes.Account -> async Nat;
    } {
        switch(tokenType) {
            case (#ICP) {
                actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
            };
            case (#ICRC1(canisterId)) {
                actor(Principal.toText(canisterId));
            };
            case (#ICRC2(canisterId)) {
                actor(Principal.toText(canisterId));
            };
        };
    };

    // System functions
    system func preupgrade() {
        feeConfigs := Iter.toArray(tokenConfigs.entries());
    };

    system func postupgrade() {
        feeConfigs := [];
    };

    // Query functions
    public query func getMarketConditions() : async MarketConditions {
        marketState;
    };

    public query func getFeeHistory(
        startTime: Time.Time,
        endTime: Time.Time
    ) : async [FeeHistoryEntry] {
        Array.filter<FeeHistoryEntry>(
            feeHistory,
            func(entry: FeeHistoryEntry) : Bool {
                entry.timestamp >= startTime and entry.timestamp <= endTime
            }
        );
    };

    public query func isUserWhitelisted(user: Principal) : async Bool {
        isWhitelisted(user);
    };

    public query func getSupportedTokens() : async [TokenType] {
        Iter.toArray(tokenConfigs.keys());
    };
};