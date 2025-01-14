import Types "./types";
import Storage "./storage";
import Hub "../../hub/types";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import UUID "mo:uuid";

actor AuthSystem {
    private let storage = Storage.AuthStorage();
    private let SESSION_DURATION_DEFAULT = 24 * 60 * 60 * 1000_000_000; // 24 hours in nanoseconds

    // External canister references
    private let hub = actor("aaaaa-aa") : actor { 
        getToken : shared (Hub.TokenId) -> async ?Hub.LNFT;
        recordEvent : shared (Hub.EventType, Hub.EventData) -> async ();
    };

    // Authentication
    public shared({ caller }) func login(request: Types.LoginRequest) : async Types.AuthResponse {
        if (Principal.isAnonymous(caller)) {
            return #err(#Unauthorized);
        };

        // Rate limiting check
        if (not storage.checkRateLimit(caller, "login")) {
            return #err(#SystemError);
        };

        // Get or create user profile
        let profile = await _getOrCreateProfile(caller);
        
        // Create new session
        let sessionId = await _createSession(
            caller,
            request.deviceInfo,
            request.sessionDuration
        );

        storage.recordAuthEvent({
            id = UUID.toText(await UUID.make());
            timestamp = Time.now();
            eventType = #Login;
            userId = caller;
            metadata = _createLoginMetadata(request.deviceInfo);
        });

        #ok({
            sessionId = sessionId;
            profile = profile;
            permissions = _getUserPermissions(profile);
        })
    };

    public shared({ caller }) func logout(sessionId: Text) : async Types.AuthResponse {
        switch (storage.getSession(sessionId)) {
            case (null) { #err(#InvalidSession) };
            case (?session) {
                if (not Principal.equal(session.userId, caller)) {
                    return #err(#Unauthorized);
                };

                if (storage.removeSession(sessionId)) {
                    storage.recordAuthEvent({
                        id = UUID.toText(await UUID.make());
                        timestamp = Time.now();
                        eventType = #Logout;
                        userId = caller;
                        metadata = [("sessionId", sessionId)];
                    });

                    switch (storage.getProfile(caller)) {
                        case (null) { #err(#UserNotFound) };
                        case (?profile) {
                            #ok({
                                sessionId = "";
                                profile = profile;
                                permissions = [];
                            })
                        };
                    }
                } else {
                    #err(#SystemError)
                }
            };
        }
    };

    public shared({ caller }) func validateSession(request: Types.SessionValidationRequest) : async Types.AuthResponse {
        switch (storage.getSession(request.sessionId)) {
            case (null) { #err(#InvalidSession) };
            case (?session) {
                if (session.expiresAt < Time.now()) {
                    ignore storage.removeSession(session.id);
                    storage.recordAuthEvent({
                        id = UUID.toText(await UUID.make());
                        timestamp = Time.now();
                        eventType = #SessionExpired;
                        userId = session.userId;
                        metadata = [("sessionId", session.id)];
                    });
                    return #err(#SessionExpired);
                };

                switch (storage.getProfile(session.userId)) {
                    case (null) { #err(#UserNotFound) };
                    case (?profile) {
                        // Update last active time
                        let updatedSession = {
                            session with
                            lastActive = Time.now();
                            tokenId = request.tokenId;
                        };
                        ignore storage.updateSession(session.id, updatedSession);

                        #ok({
                            sessionId = session.id;
                            profile = profile;
                            permissions = _getUserPermissions(profile);
                        })
                    };
                }
            };
        }
    };

    // Profile Management
    public shared({ caller }) func updateProfile(request: Types.UpdateProfileRequest) : async Types.AuthResponse {
        switch (storage.getProfile(caller)) {
            case (null) { #err(#UserNotFound) };
            case (?currentProfile) {
                let updatedProfile = storage.updateProfile(
                    caller,
                    func (profile: Types.UserProfile) : Types.UserProfile {
                        {
                            profile with
                            displayName = Option.get(request.displayName, profile.displayName);
                            avatar = Option.get(request.avatar, profile.avatar);
                            preferences = Option.get(request.preferences, profile.preferences);
                        }
                    }
                );

                switch (updatedProfile) {
                    case (null) { #err(#SystemError) };
                    case (?profile) {
                        storage.recordAuthEvent({
                            id = UUID.toText(await UUID.make());
                            timestamp = Time.now();
                            eventType = #ProfileUpdated;
                            userId = caller;
                            metadata = [];
                        });

                        #ok({
                            sessionId = "";  // No session changes
                            profile = profile;
                            permissions = _getUserPermissions(profile);
                        })
                    };
                }
            };
        }
    };

    // Role Management
    public shared({ caller }) func assignRole(userId: Principal, role: Types.Role) : async Types.AuthResponse {
        if (not _isAdmin(caller)) {
            return #err(#Unauthorized);
        };

        switch (storage.getProfile(userId)) {
            case (null) { #err(#UserNotFound) };
            case (?currentProfile) {
                let updatedProfile = storage.updateProfile(
                    userId,
                    func (profile: Types.UserProfile) : Types.UserProfile {
                        {
                            profile with
                            roles = Array.append(profile.roles, [role]);
                        }
                    }
                );

                switch (updatedProfile) {
                    case (null) { #err(#SystemError) };
                    case (?profile) {
                        storage.recordAuthEvent({
                            id = UUID.toText(await UUID.make());
                            timestamp = Time.now();
                            eventType = #RoleChanged;
                            userId = userId;
                            metadata = [
                                ("role", _roleToText(role)),
                                ("action", "assigned"),
                                ("by", Principal.toText(caller))
                            ];
                        });

                        #ok({
                            sessionId = "";
                            profile = profile;
                            permissions = _getUserPermissions(profile);
                        })
                    };
                }
            };
        }
    };

    // Query Methods
    public query func getUserSessions(userId: Principal) : async [Types.Session] {
        storage.getActiveSessions(userId)
    };

    public query func getAuthEvents(userId: Principal, limit: ?Nat) : async [Types.AuthEvent] {
        storage.getAuthEvents(userId, limit)
    };

    public query func getProfile(userId: Principal) : async ?Types.UserProfile {
        storage.getProfile(userId)
    };

    // Helper Methods
    private func _getOrCreateProfile(userId: Principal) : async Types.UserProfile {
        switch (storage.getProfile(userId)) {
            case (?profile) { profile };
            case (null) {
                let profile : Types.UserProfile = {
                    principal = userId;
                    displayName = Principal.toText(userId);
                    avatar = null;
                    created = Time.now();
                    ownedTokens = [];
                    preferences = {
                        theme = null;
                        language = null;
                        notifications = {
                            emailNotifications = true;
                            pushNotifications = true;
                            tokenUpdates = true;
                            systemAnnouncements = true;
                        };
                        privacySettings = {
                            profileVisibility = #Public;
                            activityVisibility = #Friends;
                            showOnlineStatus = true;
                        };
                    };
                    roles = [#User];
                };
                ignore storage.createProfile(profile);
                profile
            };
        }
    };

    private func _createSession(
        userId: Principal,
        deviceInfo: ?Types.DeviceInfo,
        duration: ?Nat
    ) : async Text {
        let sessionId = UUID.toText(await UUID.make());
        let session : Types.Session = {
            id = sessionId;
            userId = userId;
            tokenId = null;
            created = Time.now();
            lastActive = Time.now();
            expiresAt = Time.now() + Option.get(duration, SESSION_DURATION_DEFAULT);
            deviceInfo = deviceInfo;
        };
        
        ignore storage.createSession(session);
        sessionId
    };

    private func _createLoginMetadata(deviceInfo: ?Types.DeviceInfo) : [(Text, Text)] {
        switch (deviceInfo) {
            case (null) { [] };
            case (?info) {
                [
                    ("deviceId", info.deviceId),
                    ("deviceType", info.deviceType),
                    ("browserInfo", info.browserInfo),
                    ("ipAddress", info.ipAddress)
                ]
            };
        }
    };

    private func _getUserPermissions(profile: Types.UserProfile) : [Types.Permission] {
        let permissions = Buffer.Buffer<Types.Permission>(0);
        for (role in profile.roles.vals()) {
            for (permission in _getRolePermissions(role).vals()) {
                permissions.add(permission);
            };
        };
        Buffer.toArray(permissions)
    };

    private func _getRolePermissions(role: Types.Role) : [Types.Permission] {
        switch (role) {
            case (#Admin) {
                [
                    #ManageUsers,
                    #ManageTokens,
                    #CreateTokens,
                    #ModifySystem,
                    #ViewAnalytics,
                    #Basic
                ]
            };
            case (#Creator) {
                [
                    #CreateTokens,
                    #ViewAnalytics,
                    #Basic
                ]
            };
            case (#User) {
                [#Basic]
            };
            case (#Guest) {
                [#Basic]
            };
        }
    };

    private func _isAdmin(userId: Principal) : Bool {
        switch (storage.getProfile(userId)) {
            case (null) { false };
            case (?profile) {
                Array.find<Types.Role>(
                    profile.roles,
                    func (role: Types.Role) : Bool = role == #Admin
                ) != null
            };
        }
    };

    private func _roleToText(role: Types.Role) : Text {
        switch (role) {
            case (#Admin) { "Admin" };
            case (#Creator) { "Creator" };
            case (#User) { "User" };
            case (#Guest) { "Guest" };
        }
    };

    // System Functions
    stable var stableStorage = {
        sessions = [] : [(Text, Types.Session)];
        profiles = [] : [(Principal, Types.UserProfile)];
        events = [] : [Types.AuthEvent];
        rateLimits = [] : [(Text, Types.RateLimit)];
        rateLimitStates = [] : [(Text, Types.RateLimitState)];
    };

    system func preupgrade() {
        stableStorage := storage.toStable();
    };

    system func postupgrade() {
        storage.loadStable(stableStorage);

        // Setup default rate limits
        storage.setRateLimit("login", {
            endpoint = "login";
            windowMs = 60_000_000_000;  // 1 minute
            maxRequests = 5;
        });
    };
};