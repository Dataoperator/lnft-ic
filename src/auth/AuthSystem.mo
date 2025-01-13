/// Enhanced Authentication System with II Best Practices
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import IC "./ic";
import Types "./Types";
import CertifiedData "mo:base/CertifiedData";
import Hash "mo:base/Hash";

actor class AuthSystem() {
    type Session = Types.Session;
    type AuthResponse = Types.AuthResponse;
    type UserProfile = Types.UserProfile;
    type SessionData = Types.SessionData;
    type DelegationType = Types.DelegationType;

    // Stable storage
    private stable var sessionEntries : [(Principal, SessionData)] = [];
    private stable var delegationEntries : [(Text, [DelegationType])] = [];
    private stable var userProfileEntries : [(Principal, UserProfile)] = [];

    // Runtime storage
    private let sessions = HashMap.fromIter<Principal, SessionData>(
        sessionEntries.vals(),
        1,
        Principal.equal,
        Principal.hash
    );

    private let delegations = HashMap.fromIter<Text, [DelegationType]>(
        delegationEntries.vals(),
        1,
        Text.equal,
        Text.hash
    );

    private let userProfiles = HashMap.fromIter<Principal, UserProfile>(
        userProfileEntries.vals(),
        1,
        Principal.equal,
        Principal.hash
    );

    // Internet Identity interface
    private let ii_canister = actor "rwlgt-iiaaa-aaaaa-aaaaa-cai" : actor {
        prepare_delegation : shared (
            Principal,
            Time.Time,
            ?[Blob],  // Optional session key
        ) -> async IC.GetDelegationResponse;
        get_delegation : shared (
            Principal,
            Time.Time,
            [Blob],
        ) -> async IC.GetDelegationResponse;
    };

    // Initialize a new session
    public shared({ caller }) func initSession(
        sessionKey: [Nat8],
        maxTimeToLive: Nat64
    ) : async Result.Result<SessionData, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous principals not allowed");
        };

        switch (sessions.get(caller)) {
            case (?session) {
                if (isSessionValid(session)) {
                    return #err("Active session already exists");
                };
            };
            case null {};
        };

        try {
            // Prepare delegation with II
            let prepareDelegation = await ii_canister.prepare_delegation(
                caller,
                Time.now(),
                ?[Blob.fromArray(sessionKey)]
            );

            switch (prepareDelegation) {
                case (#ok(delegation)) {
                    let sessionData : SessionData = {
                        sessionKey = sessionKey;
                        created = Time.now();
                        expiration = Time.now() + Int.abs(Int64.toInt(maxTimeToLive));
                        delegation = delegation;
                    };

                    sessions.put(caller, sessionData);
                    await updateUserProfile(caller);
                    #ok(sessionData);
                };
                case (#err(error)) {
                    #err("Failed to prepare delegation: " # debug_show(error));
                };
            };
        }
        catch (error) {
            #err("Error initializing session: " # Error.message(error));
        };
    };

    // Verify delegation chain
    public shared({ caller }) func verifyDelegation(
        delegation: IC.SignedDelegation,
        sessionKeyId: Text
    ) : async Bool {
        if (Principal.isAnonymous(caller)) {
            return false;
        };

        switch (sessions.get(caller)) {
            case (?session) {
                if (not isSessionValid(session)) {
                    return false;
                };

                try {
                    let verification = await ii_canister.get_delegation(
                        caller,
                        delegation.delegation.expiration,
                        [Blob.fromArray(session.sessionKey)]
                    );

                    switch (verification) {
                        case (#ok(verifiedDelegation)) {
                            // Store delegation chain
                            switch (delegations.get(sessionKeyId)) {
                                case (?chain) {
                                    let newChain = Array.append(
                                        chain,
                                        [{ delegation = delegation; timestamp = Time.now(); }]
                                    );
                                    delegations.put(sessionKeyId, newChain);
                                };
                                case null {
                                    delegations.put(
                                        sessionKeyId,
                                        [{ delegation = delegation; timestamp = Time.now(); }]
                                    );
                                };
                            };
                            true;
                        };
                        case (#err(_)) {
                            false;
                        };
                    };
                }
                catch (error) {
                    false;
                };
            };
            case null {
                false;
            };
        };
    };

    // Get user profile with session status
    public query({ caller }) func getProfile() : async Result.Result<UserProfile, Text> {
        switch (userProfiles.get(caller)) {
            case (?profile) {
                switch (sessions.get(caller)) {
                    case (?session) {
                        if (isSessionValid(session)) {
                            #ok({ profile with activeSession = ?{
                                userId = caller;
                                createdAt = session.created;
                                lastActive = Time.now();
                                isAuthenticated = true;
                            }});
                        } else {
                            #ok({ profile with activeSession = null });
                        };
                    };
                    case null {
                        #ok({ profile with activeSession = null });
                    };
                };
            };
            case null {
                #err("Profile not found");
            };
        };
    };

    // Update session activity
    public shared({ caller }) func updateActivity() : async Result.Result<(), Text> {
        switch (sessions.get(caller)) {
            case (?session) {
                if (not isSessionValid(session)) {
                    return #err("Session expired");
                };

                let updatedSession : SessionData = {
                    session with
                    lastActive = Time.now();
                };
                sessions.put(caller, updatedSession);
                #ok();
            };
            case null {
                #err("No active session");
            };
        };
    };

    // End session (logout)
    public shared({ caller }) func endSession() : async Result.Result<(), Text> {
        switch (sessions.get(caller)) {
            case (?_) {
                sessions.delete(caller);
                
                switch (userProfiles.get(caller)) {
                    case (?profile) {
                        userProfiles.put(
                            caller,
                            { profile with activeSession = null }
                        );
                    };
                    case null {};
                };
                
                #ok();
            };
            case null {
                #err("No active session");
            };
        };
    };

    // Helper functions
    private func isSessionValid(session: SessionData) : Bool {
        let currentTime = Time.now();
        currentTime < session.expiration;
    };

    private func updateUserProfile(principal: Principal) : async () {
        switch (userProfiles.get(principal)) {
            case (?profile) {
                let updatedProfile : UserProfile = {
                    profile with
                    lastLogin = Time.now();
                };
                userProfiles.put(principal, updatedProfile);
            };
            case null {
                let newProfile : UserProfile = {
                    principal = principal;
                    registeredAt = Time.now();
                    lastLogin = Time.now();
                    ownedTokens = [];
                    activeSession = null;
                };
                userProfiles.put(principal, newProfile);
            };
        };
    };

    // System functions
    system func preupgrade() {
        sessionEntries := Iter.toArray(sessions.entries());
        delegationEntries := Iter.toArray(delegations.entries());
        userProfileEntries := Iter.toArray(userProfiles.entries());
    };

    system func postupgrade() {
        sessionEntries := [];
        delegationEntries := [];
        userProfileEntries := [];
    };
}