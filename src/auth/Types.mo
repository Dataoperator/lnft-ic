/// Enhanced Authentication System Types
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import IC "./ic";

module {
    /// Detailed session information
    public type Session = {
        userId: Principal;
        createdAt: Time.Time;
        lastActive: Time.Time;
        isAuthenticated: Bool;
    };

    /// Session data with delegation
    public type SessionData = {
        sessionKey: [Nat8];
        created: Time.Time;
        expiration: Time.Time;
        delegation: IC.SignedDelegation;
        lastActive: ?Time.Time;
    };

    /// Delegation chain entry
    public type DelegationType = {
        delegation: IC.SignedDelegation;
        timestamp: Time.Time;
    };

    /// Authentication response
    public type AuthResponse = {
        #Success: Session;
        #Failure: Text;
        #AlreadyAuthenticated;
    };

    /// Enhanced user profile
    public type UserProfile = {
        principal: Principal;
        registeredAt: Time.Time;
        lastLogin: Time.Time;
        ownedTokens: [Nat];  // LNFT token IDs
        activeSession: ?Session;
        preferredIdp: ?Text;  // Preferred identity provider
        metadata: [(Text, Text)];  // Additional user metadata
    };

    /// Session verification result
    public type SessionVerification = {
        #Valid: SessionData;
        #Expired;
        #Invalid;
    };
};