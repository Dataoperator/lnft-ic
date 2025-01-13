/// Enhanced Minting System Types
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import FeeTypes "../fee_management/Types";
import TraitTypes "../traits/Types";

module {
    /// Minting request
    public type MintRequest = {
        quantity: Nat;
        recipient: Principal;
        paymentDetails: PaymentDetails;
        requestedTraits: ?[Text];  // Optional specific traits
        eventContext: ?Text;      // Special event context if any
    };

    /// Payment information
    public type PaymentDetails = {
        tokenType: FeeTypes.TokenType;
        blockIndex: Nat64;
        amount: Nat;
        timestamp: Time.Time;
    };

    /// Minting result
    public type MintResult = {
        #Success: {
            tokenIds: [Nat];
            traits: [TraitTypes.TraitGenerationResult];
            fees: FeeTypes.FeeQuote;
        };
        #Failure: MintError;
    };

    /// Possible minting errors
    public type MintError = {
        #PaymentVerificationFailed: Text;
        #InvalidQuantity: Text;
        #RateLimitExceeded: Text;
        #EventError: Text;
        #TraitGenerationFailed: Text;
        #QuotaExceeded: Text;
        #SystemError: Text;
    };

    /// Batch minting status
    public type BatchStatus = {
        batchId: Text;
        totalRequested: Nat;
        completed: Nat;
        failed: Nat;
        status: BatchState;
        tokenIds: [Nat];
        timestamp: Time.Time;
        retryCount: Nat;
    };

    /// Batch processing state
    public type BatchState = {
        #InProgress;
        #Completed;
        #Failed: Text;
        #PartiallyCompleted: {
            reason: Text;
            successCount: Nat;
        };
    };

    /// Minting configuration
    public type MintConfig = {
        batchSizeLimit: Nat;      // Maximum tokens per batch
        hourlyLimit: Nat;         // Rate limiting
        eventMultipliers: [(Text, Nat)];  // Event-based adjustments
        traitRequirements: TraitRequirements;
    };

    /// Trait generation requirements
    public type TraitRequirements = {
        minTraits: Nat;
        maxTraits: Nat;
        requiredCategories: [TraitTypes.TraitCategory];
        eventOverrides: [(Text, TraitTypes.TraitConfig)];
    };

    /// Minting metrics
    public type MintMetrics = {
        totalMinted: Nat;
        totalFees: [(FeeTypes.TokenType, Nat)];
        batchStats: {
            totalBatches: Nat;
            successfulBatches: Nat;
            failedBatches: Nat;
        };
        eventStats: [(Text, Nat)];  // Events and their mint counts
        timestamp: Time.Time;
    };
};