/// Internet Computer and Internet Identity Types
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";

module {
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

    // Internet Identity Types
    public type UserNumber = Nat64;
    
    public type PublicKey = [Nat8];
    
    public type CredentialId = [Nat8];
    
    public type DeviceKey = PublicKey;
    
    public type UserKey = PublicKey;
    
    public type SessionKey = PublicKey;
    
    public type FrontendHostname = Text;
    
    public type Timestamp = Nat64;

    public type Delegation = {
        pubkey : PublicKey;
        expiration : Timestamp;
        targets : ?[Principal];
    };

    public type SignedDelegation = {
        delegation : Delegation;
        signature : [Nat8];
    };

    public type GetDelegationResponse = {
        #ok : SignedDelegation;
        #err : {
            #NoSuchDelegation;
            #ExpiredDelegation;
        };
    };

    public type InternetIdentityStats = {
        users_registered : Nat64;
        storage_layout_version : Nat8;
    };
};