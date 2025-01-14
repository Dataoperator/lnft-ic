import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Blob "mo:base/Blob";

module {
    public type Account = { owner : Principal; subaccount : ?[Nat8] };
    public type Memo = Blob;
    public type TransactionId = Nat;
    public type TokenId = Nat;
    public type Timestamp = Int;

    public type MetadataContainer = {
        #Metadata : [(Text, MetadataValue)];
        #Blob : Blob;
    };

    public type MetadataValue = {
        #Nat : Nat;
        #Int : Int;
        #Text : Text;
        #Blob : Blob;
        #Array : [MetadataValue];
    };

    public type MintArgs = {
        to : Account;
        metadata : ?MetadataContainer;
    };

    public type BurnArgs = {
        token_id : TokenId;
    };

    public type Result_1 = {
        #Ok : TokenId;
        #Err : Error;
    };

    public type Error = {
        #GenericError;
        #Unauthorized;
        #InvalidTokenId;
        #AlreadyExistTokenId;
        #InvalidRequest;
    };

    public type TransferArgs = {
        to : Account;
        token_id : TokenId;
        memo : ?Memo;
    };

    public type TransferError = {
        #Unauthorized;
        #InvalidTokenId;
        #InvalidRequest;
    };

    public type ApprovalArgs = {
        from_subaccount : ?[Nat8];
        spender : Principal;
        token_id : TokenId;
        expires_at : ?Timestamp;
    };

    public type ApprovalError = {
        #Unauthorized;
        #InvalidTokenId;
        #InvalidRequest;
    };

    public type EmotionalState = {
        joy: Nat;
        sadness: Nat;
        anger: Nat;
        fear: Nat;
        trust: Nat;
    };

    public type Memory = {
        timestamp: Time.Time;
        content: Text;
        emotionalImpact: EmotionalState;
    };

    public type Trait = {
        name: Text;
        value: Nat;
        rarity: Nat;
    };
};