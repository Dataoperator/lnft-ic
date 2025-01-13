/// Enhanced Fee Management Types
import Time "mo:base/Time";
import Principal "mo:base/Principal";

module {
    /// Supported token types
    public type TokenType = {
        #ICP;
        #ICRC1: Principal;  // Token canister ID
        #ICRC2: Principal;  // Token canister ID
    };

    /// Fee configuration for a token
    public type TokenFeeConfig = {
        tokenType: TokenType;
        baseFee: Nat;
        minFee: Nat;
        maxFee: Nat;
        supplyMultiplier: Nat;    // Fee increases with supply
        volumeMultiplier: Nat;    // Fee adjusts based on minting volume
        eventMultiplier: Nat;     // Special event modifiers
        batchDiscountRate: Nat;   // Discount for batch minting (percentage)
        whitelistDiscount: Nat;   // Discount for whitelisted users
    };

    /// Market conditions affecting fees
    public type MarketConditions = {
        totalSupply: Nat;
        mintVolume24h: Nat;      // Minting volume in last 24h
        avgFee24h: Nat;          // Average fee in last 24h
        activeEvents: [Text];     // Active event IDs
        lastUpdate: Time.Time;
    };

    /// Fee calculation result
    public type FeeQuote = {
        tokenType: TokenType;
        baseAmount: Nat;
        adjustedAmount: Nat;
        breakdown: FeeBreakdown;
        validUntil: Time.Time;    // Quote expiration
        batchSize: Nat;          // For batch minting
        eventModifiers: [(Text, Nat)];
    };

    /// Detailed fee breakdown
    public type FeeBreakdown = {
        baseFee: Nat;
        supplyAdjustment: Nat;
        volumeAdjustment: Nat;
        eventAdjustment: Nat;
        batchDiscount: Nat;
        whitelistDiscount: Nat;
    };

    /// Payment verification
    public type PaymentVerification = {
        #Success: {
            blockIndex: Nat64;
            timestamp: Time.Time;
        };
        #Pending;
        #Failed: Text;
    };

    /// Batch minting request
    public type BatchMintRequest = {
        quantity: Nat;
        tokenType: TokenType;
        recipient: Principal;
        paymentBlockIndex: ?Nat64;
    };

    /// Fee history entry
    public type FeeHistoryEntry = {
        timestamp: Time.Time;
        tokenType: TokenType;
        amount: Nat;
        batchSize: Nat;
        eventIds: [Text];
    };
};