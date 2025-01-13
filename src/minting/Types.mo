/// Dynamic Fee and Minting Types
import Time "mo:base/Time";

module {
    /// Fee calculation configuration
    public type FeeConfig = {
        baseFee: Nat;
        supplyMultiplier: Nat;  // Fee increases with supply
        eventMultiplier: Nat;   // Special event modifiers
        maxFee: Nat;           // Upper limit
        minFee: Nat;           // Lower limit
    };

    /// Special minting events
    public type MintingEvent = {
        id: Text;
        name: Text;
        startTime: Time.Time;
        endTime: Time.Time;
        feeModifier: Nat;     // Percentage modifier (100 = normal)
        traitModifiers: [(Text, Nat)];  // Trait probabilities during event
        maxMints: ?Nat;       // Optional cap on mints during event
        currentMints: Nat;    // Number of mints during this event
    };

    /// Market conditions that affect fees
    public type MarketConditions = {
        totalSupply: Nat;
        recentMints: Nat;    // Mints in last time period
        avgFee: Nat;         // Average fee paid
        activeEvents: [MintingEvent];
    };

    /// Fee calculation result
    public type FeeResult = {
        amount: Nat;
        breakdown: {
            baseFee: Nat;
            supplyFee: Nat;
            eventFee: Nat;
            discount: Nat;
        };
        applicableEvents: [Text];  // Active event IDs
    };
};