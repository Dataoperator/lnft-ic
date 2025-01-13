module {
    public type CanisterId = Principal;
    public type UserId = Principal;
    
    public type HeaderField = (Text, Text);

    public type HttpRequest = {
        url : Text;
        method : Text;
        body : [Nat8];
        headers : [HeaderField];
    };

    public type HttpResponse = {
        body : [Nat8];
        headers : [HeaderField];
        status_code : Nat16;
    };

    public type TransformArgs = {
        context : [Nat8];
        response : HttpResponse;
    };

    public type CallError = {
        #SystemError : { code : Text; message : Text };
        #CanisterError : { code : Text; message : Text };
    };

    public type ManagementCanister = actor {
        http_request : shared query HttpRequest -> async HttpResponse;
        create_canister : shared { settings : ?{ controllers : ?[Principal] } } -> async { canister_id : Principal };
    };
}