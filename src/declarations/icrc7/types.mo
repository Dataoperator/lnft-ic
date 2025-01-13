module {
  public type TokenId = Nat;
  public type Account = {
    owner : Principal;
    subaccount : ?[Nat8];
  };
  
  public type Metadata = {
    name : Text;
    description : ?Text;
    image : ?Text;
    attributes : [(Text, Text)];
  };
  
  public type TransferArgs = {
    from_subaccount : ?[Nat8];
    to : Account;
    token_ids : [TokenId];
    #fee : ?Nat;
    memo : ?[Nat8];
    #created_at_time : ?Nat64;
  };
  
  public type TransferError = {
    #Unauthorized;
    #InvalidTokenId;
    #InsufficientBalance;
    #Duplicate;
    #CreatedInFuture;
    #TooOld;
    #GenericError;
  };
}