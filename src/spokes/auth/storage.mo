import Types "./types";
import Hub "../../hub/types";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

module {
    public class AuthStorage() {
        // Core Storage
        private var sessions = HashMap.HashMap<Text, Types.Session>(0, Text.equal, Text.hash);
        private var profiles = HashMap.HashMap<Principal, Types.UserProfile>(0, Principal.equal, Principal.hash);
        private var authEvents = Buffer.Buffer<Types.AuthEvent>(0);
        private var rateLimits = HashMap.HashMap<Text, Types.RateLimit>(0, Text.equal, Text.hash);
        private var rateLimitStates = HashMap.HashMap<Text, Types.RateLimitState>(0, Text.equal, Text.hash);

        // Session Management
        public func createSession(session: Types.Session) : Bool {
            sessions.put(session.id, session);
            true
        };

        public func getSession(sessionId: Text) : ?Types.Session {
            sessions.get(sessionId)
        };

        public func updateSession(sessionId: Text, updatedSession: Types.Session) : Bool {
            sessions.put(sessionId, updatedSession);
            true
        };

        public func removeSession(sessionId: Text) : Bool {
            sessions.delete(sessionId);
            true
        };

        public func getActiveSessions(userId: Principal) : [Types.Session] {
            let active = Buffer.Buffer<Types.Session>(0);
            for ((_, session) in sessions.entries()) {
                if (Principal.equal(session.userId, userId) and 
                    session.expiresAt > Time.now()) {
                    active.add(session);
                };
            };
            Buffer.toArray(active)
        };

        // Profile Management
        public func createProfile(profile: Types.UserProfile) : Bool {
            profiles.put(profile.principal, profile);
            true
        };

        public func getProfile(userId: Principal) : ?Types.UserProfile {
            profiles.get(userId)
        };

        public func updateProfile(userId: Principal, updateFn: (Types.UserProfile) -> Types.UserProfile) : ?Types.UserProfile {
            switch (profiles.get(userId)) {
                case (null) { null };
                case (?profile) {
                    let updated = updateFn(profile);
                    profiles.put(userId, updated);
                    ?updated
                };
            }
        };

        // Event Management
        public func recordAuthEvent(event: Types.AuthEvent) {
            authEvents.add(event);
        };

        public func getAuthEvents(userId: Principal, limit: ?Nat) : [Types.AuthEvent] {
            let userEvents = Buffer.mapFilter<Types.AuthEvent, Types.AuthEvent>(
                authEvents,
                func (event: Types.AuthEvent) : ?Types.AuthEvent {
                    if (Principal.equal(event.userId, userId)) {
                        ?event
                    } else {
                        null
                    }
                }
            );

            switch (limit) {
                case (null) { Buffer.toArray(userEvents) };
                case (?n) {
                    let arr = Buffer.toArray(userEvents);
                    let start = if (arr.size() > n) {
                        arr.size() - n
                    } else {
                        0
                    };
                    Array.tabulate<Types.AuthEvent>(
                        Nat.min(n, arr.size()),
                        func (i: Nat) : Types.AuthEvent {
                            arr[start + i]
                        }
                    )
                };
            }
        };

        // Rate Limiting
        public func setRateLimit(endpoint: Text, limit: Types.RateLimit) {
            rateLimits.put(endpoint, limit);
        };

        public func getRateLimit(endpoint: Text) : ?Types.RateLimit {
            rateLimits.get(endpoint)
        };

        public func checkRateLimit(
            userId: Principal,
            endpoint: Text
        ) : Bool {
            let key = Principal.toText(userId) # ":" # endpoint;
            
            switch (rateLimits.get(endpoint)) {
                case (null) { true }; // No rate limit set
                case (?limit) {
                    switch (rateLimitStates.get(key)) {
                        case (null) {
                            // First request
                            rateLimitStates.put(key, {
                                userId = userId;
                                endpoint = endpoint;
                                requests = [(Time.now(), 1)];
                            });
                            true
                        };
                        case (?state) {
                            let currentTime = Time.now();
                            let windowStart = currentTime - Int.abs(limit.windowMs);
                            
                            // Filter requests within window
                            let recentRequests = Array.filter<(Time.Time, Nat)>(
                                state.requests,
                                func(req: (Time.Time, Nat)) : Bool {
                                    req.0 >= windowStart
                                }
                            );

                            // Sum requests
                            let totalRequests = Array.foldLeft<(Time.Time, Nat), Nat>(
                                recentRequests,
                                0,
                                func(acc: Nat, req: (Time.Time, Nat)) : Nat {
                                    acc + req.1
                                }
                            );

                            if (totalRequests < limit.maxRequests) {
                                // Update state
                                rateLimitStates.put(key, {
                                    userId = userId;
                                    endpoint = endpoint;
                                    requests = Array.append(
                                        recentRequests,
                                        [(currentTime, 1)]
                                    );
                                });
                                true
                            } else {
                                false
                            }
                        };
                    }
                };
            }
        };

        // Role and Permission Management
        public func hasPermission(userId: Principal, permission: Types.Permission) : Bool {
            switch (profiles.get(userId)) {
                case (null) { false };
                case (?profile) {
                    // Check if user has required role for permission
                    Array.find<Types.Role>(
                        profile.roles,
                        func (role: Types.Role) : Bool {
                            _roleHasPermission(role, permission)
                        }
                    ) != null
                };
            }
        };

        private func _roleHasPermission(role: Types.Role, permission: Types.Permission) : Bool {
            switch (role, permission) {
                case (#Admin, _) { true };
                case (#Creator, #CreateTokens) { true };
                case (#Creator, #ViewAnalytics) { true };
                case (#User, #Basic) { true };
                case (#Guest, #Basic) { true };
                case (_, _) { false };
            }
        };

        // Stable Storage Management
        public func toStable() : {
            sessions: [(Text, Types.Session)];
            profiles: [(Principal, Types.UserProfile)];
            events: [Types.AuthEvent];
            rateLimits: [(Text, Types.RateLimit)];
            rateLimitStates: [(Text, Types.RateLimitState)];
        } {
            {
                sessions = HashMap.toArray(sessions);
                profiles = HashMap.toArray(profiles);
                events = Buffer.toArray(authEvents);
                rateLimits = HashMap.toArray(rateLimits);
                rateLimitStates = HashMap.toArray(rateLimitStates);
            }
        };

        public func loadStable(stable: {
            sessions: [(Text, Types.Session)];
            profiles: [(Principal, Types.UserProfile)];
            events: [Types.AuthEvent];
            rateLimits: [(Text, Types.RateLimit)];
            rateLimitStates: [(Text, Types.RateLimitState)];
        }) {
            sessions := HashMap.fromIter<Text, Types.Session>(
                stable.sessions.vals(),
                stable.sessions.size(),
                Text.equal,
                Text.hash
            );
            profiles := HashMap.fromIter<Principal, Types.UserProfile>(
                stable.profiles.vals(),
                stable.profiles.size(),
                Principal.equal,
                Principal.hash
            );
            authEvents := Buffer.fromArray(stable.events);
            rateLimits := HashMap.fromIter<Text, Types.RateLimit>(
                stable.rateLimits.vals(),
                stable.rateLimits.size(),
                Text.equal,
                Text.hash
            );
            rateLimitStates := HashMap.fromIter<Text, Types.RateLimitState>(
                stable.rateLimitStates.vals(),
                stable.rateLimitStates.size(),
                Text.equal,
                Text.hash
            );
        };
    };
};