import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import IC "./IC";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";

actor class Cronolink() {
    type TokenId = Nat;

    // Custom hash function for Nat
    private func natHash(n: Nat): Hash.Hash {
        let h1 = Nat32.fromNat(n);
        let h2 = Nat32.fromNat(Nat.div(n, 4294967296)); // Using Nat.div instead of >>
        func fnv1a(h: Nat32): Nat32 {
            let fnv_prime: Nat32 = 16777619;
            let fnv_offset: Nat32 = 2166136261;
            return (fnv_offset ^ h) *% fnv_prime;
        };
        return fnv1a(h1 ^ h2);
    };

    // Runtime state with custom hash
    private let conversations = HashMap.HashMap<TokenId, Buffer.Buffer<(Text, Text)>>(100, Nat.equal, natHash);
    private let apiConfigs = HashMap.HashMap<Text, IC.ApiConfig>(10, Text.equal, Text.hash);
    private var requestCount : Nat = 0;
    private let managementCanister : IC.ManagementCanister = actor "aaaaa-aa";

    // Rate limiting
    private let rateLimitWindow = 60_000_000_000; // 1 minute in nanoseconds
    private let requestsPerWindow = 10;
    private let rateLimits = HashMap.HashMap<Principal, [(Nat, Nat)]>(100, Principal.equal, Principal.hash);

    private func safeTimeToNat(t: Int): Nat {
        if (t < 0) { 0 } else {
            Int.abs(t)
        }
    };

    private func checkRateLimit(caller: Principal) : Bool {
        let now = safeTimeToNat(Time.now());
        let userRequests = Option.get(rateLimits.get(caller), []);
        let recentRequests = Array.filter<(Nat, Nat)>(
            userRequests,
            func((timestamp, _)) = (now > timestamp) and (Nat.sub(now, timestamp) < rateLimitWindow)
        );
        
        if (recentRequests.size() >= requestsPerWindow) {
            false
        } else {
            let requestBuffer = Buffer.fromArray<(Nat, Nat)>(recentRequests);
            requestBuffer.add((now, 1));
            rateLimits.put(caller, Buffer.toArray(requestBuffer));
            true
        }
    };

    // Rest of the implementation remains the same...
}