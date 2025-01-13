/// ICRC Ledger Interface Types
import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
    public type Account = {
        owner : Principal;
        subaccount : ?[Nat8];
    };

    public type TransferArg = {
        from_subaccount : ?[Nat8];
        to : Account;
        amount : Nat;
        fee : ?Nat;
        memo : ?[Nat8];
        created_at_time : ?Nat64;
    };

    public type TransferError = {
        #BadFee : { expected_fee : Nat };
        #BadBurn : { min_burn_amount : Nat };
        #InsufficientFunds : { balance : Nat };
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 };
        #Duplicate : { duplicate_of : Nat };
        #TemporarilyUnavailable;
        #GenericError : { error_code : Nat; message : Text };
    };

    public type TransferResult = {
        #Ok : Nat;
        #Err : TransferError;
    };

    public type Balance = {
        owner : Principal;
        token : Principal;
        amount : Nat;
        subaccount : ?[Nat8];
    };

    public type AllowanceArg = {
        account : Account;
        spender : Principal;
    };

    public type Allowance = {
        allowance : Nat;
        expires_at : ?Nat64;
    };

    public type ApproveArg = {
        account : Account;
        spender : Principal;
        allowance : Nat;
        expires_at : ?Nat64;
        memo : ?[Nat8];
        fee : ?Nat;
        created_at_time : ?Nat64;
    };

    public type ApproveError = {
        #BadFee : { expected_fee : Nat };
        #InsufficientFunds : { balance : Nat };
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 };
        #Duplicate : { duplicate_of : Nat };
        #TemporarilyUnavailable;
        #GenericError : { error_code : Nat; message : Text };
    };

    public type ApproveResult = {
        #Ok : Nat;
        #Err : ApproveError;
    };
};