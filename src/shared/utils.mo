import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Nat32 "mo:base/Nat32";
import UUID "mo:uuid";

module {
    // Input Validation
    public func validateText(text: Text, minLength: Nat, maxLength: Nat) : Bool {
        let length = text.size();
        length >= minLength and length <= maxLength
    };

    public func validateNat(value: Nat, min: Nat, max: Nat) : Bool {
        value >= min and value <= max
    };

    public func sanitizeText(text: Text) : Text {
        // Basic text sanitization
        let sanitized = Text.map(
            text,
            func (c: Char) : Char {
                if (_isValidChar(c)) { c } else { ' ' }
            }
        );
        _collapseWhitespace(sanitized)
    };

    // Error Handling
    public func wrapResult<T, E>(computation: () -> T) : Result.Result<T, E> {
        try {
            #ok(computation())
        } catch (e) {
            #err(Error.message(e))
        }
    };

    // Time Utilities
    public func isExpired(timestamp: Time.Time, duration: Int) : Bool {
        Time.now() > timestamp + duration
    };

    public func formatTime(time: Time.Time) : Text {
        // Basic ISO timestamp
        let seconds = time / 1_000_000_000;
        Nat.toText(Int.abs(seconds))
    };

    // Array Utilities
    public func paginate<T>(array: [T], offset: Nat, limit: Nat) : [T] {
        let start = Nat.min(offset, array.size());
        let end = Nat.min(start + limit, array.size());
        Array.tabulate<T>(
            end - start,
            func (i: Nat) : T {
                array[start + i]
            }
        )
    };

    public func removeDuplicates<T>(array: [T], equal: (T, T) -> Bool) : [T] {
        let buffer = Buffer.Buffer<T>(0);
        for (item in array.vals()) {
            if (not Buffer.contains<T>(buffer, item, equal)) {
                buffer.add(item);
            };
        };
        Buffer.toArray(buffer)
    };

    // Hash Utilities
    public func combineHashes(hash1: Hash.Hash, hash2: Hash.Hash) : Hash.Hash {
        Text.hash(Nat32.toText(hash1) # Nat32.toText(hash2))
    };

    // Principal Utilities
    public func principalToText(principal: Principal) : Text {
        Principal.toText(principal)
    };

    public func isValidPrincipal(text: Text) : Bool {
        try {
            ignore Principal.fromText(text);
            true
        } catch _ {
            false
        }
    };

    // Private Helper Functions
    private func _isValidChar(c: Char) : Bool {
        let code = Nat32.fromNat(Char.toNat32(c));
        (code >= 32 and code <= 126) or // Basic ASCII
        (code >= 160 and code <= 255)   // Extended Latin
    };

    private func _collapseWhitespace(text: Text) : Text {
        var result = "";
        var lastWasSpace = false;
        
        for (c in text.chars()) {
            if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
                if (not lastWasSpace) {
                    result := result # " ";
                    lastWasSpace := true;
                };
            } else {
                result := result # Char.toText(c);
                lastWasSpace := false;
            };
        };
        
        result
    };

    // Logging and Debugging
    public func logError(error: Text, metadata: [(Text, Text)]) {
        // TODO: Implement proper logging system
        Debug.print("Error: " # error # "\nMetadata: " # debug_show(metadata));
    };

    public func logEvent(eventType: Text, details: Text) {
        // TODO: Implement proper logging system
        Debug.print("Event: " # eventType # "\nDetails: " # details);
    };

    // Security Utilities
    public func generateNonce() : async Text {
        UUID.toText(await UUID.make())
    };

    public func validateHash(input: Text, expectedHash: Text) : Bool {
        Text.hash(input) == Text.hash(expectedHash)
    };

    // Rate Limiting
    public type RateLimitConfig = {
        windowMs: Int;
        maxRequests: Nat;
    };

    public class RateLimiter(config: RateLimitConfig) {
        private var requests = Buffer.Buffer<Time.Time>(0);

        public func checkLimit() : Bool {
            let now = Time.now();
            let windowStart = now - config.windowMs;

            // Remove old requests
            requests := Buffer.mapFilter<Time.Time, Time.Time>(
                requests,
                func (time: Time.Time) : ?Time.Time {
                    if (time >= windowStart) { ?time } else { null }
                }
            );

            // Check if under limit
            if (requests.size() < config.maxRequests) {
                requests.add(now);
                true
            } else {
                false
            }
        };

        public func reset() {
            requests.clear();
        };
    };
};