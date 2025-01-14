import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Hub "../../hub/types";

module {
    // Core Authentication Types
    public type Session = {
        id: Text;
        userId: Principal;
        tokenId: ?Hub.TokenId;
        created: Time.Time;
        lastActive: Time.Time;
        expiresAt: Time.Time;
        deviceInfo: ?DeviceInfo;
    };

    public type UserProfile = {
        principal: Principal;
        displayName: Text;
        avatar: ?Text;
        created: Time.Time;
        ownedTokens: [Hub.TokenId];
        preferences: UserPreferences;
        roles: [Role];
    };

    public type Role = {
        #Admin;
        #Creator;
        #User;
        #Guest;
    };

    public type Permission = {
        #ManageUsers;
        #ManageTokens;
        #CreateTokens;
        #ModifySystem;
        #ViewAnalytics;
        #Basic;
    };

    public type DeviceInfo = {
        deviceId: Text;
        deviceType: Text;
        browserInfo: Text;
        ipAddress: Text;
        lastLocation: ?Text;
    };

    public type UserPreferences = {
        theme: ?Text;
        language: ?Text;
        notifications: NotificationPreferences;
        privacySettings: PrivacySettings;
    };

    public type NotificationPreferences = {
        emailNotifications: Bool;
        pushNotifications: Bool;
        tokenUpdates: Bool;
        systemAnnouncements: Bool;
    };

    public type PrivacySettings = {
        profileVisibility: {#Public; #Private; #Friends};
        activityVisibility: {#Public; #Private; #Friends};
        showOnlineStatus: Bool;
    };

    // Authentication Events
    public type AuthEvent = {
        id: Text;
        timestamp: Time.Time;
        eventType: AuthEventType;
        userId: Principal;
        metadata: [(Text, Text)];
    };

    public type AuthEventType = {
        #Login;
        #Logout;
        #SessionExpired;
        #PermissionGranted;
        #PermissionRevoked;
        #ProfileUpdated;
        #RoleChanged;
    };

    // Request Types
    public type LoginRequest = {
        deviceInfo: ?DeviceInfo;
        sessionDuration: ?Nat; // in seconds
    };

    public type UpdateProfileRequest = {
        displayName: ?Text;
        avatar: ?Text;
        preferences: ?UserPreferences;
    };

    public type SessionValidationRequest = {
        sessionId: Text;
        tokenId: ?Hub.TokenId;
    };

    // Response Types
    public type AuthResponse = {
        #ok : {
            sessionId: Text;
            profile: UserProfile;
            permissions: [Permission];
        };
        #err : AuthError;
    };

    public type AuthError = {
        #Unauthorized;
        #InvalidSession;
        #SessionExpired;
        #InvalidRequest;
        #SystemError;
        #UserNotFound;
    };

    // Rate Limiting
    public type RateLimit = {
        endpoint: Text;
        windowMs: Nat;
        maxRequests: Nat;
    };

    public type RateLimitState = {
        userId: Principal;
        endpoint: Text;
        requests: [(Time.Time, Nat)];
    };
};