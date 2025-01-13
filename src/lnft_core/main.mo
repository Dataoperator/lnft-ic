import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Types "./Types";

actor class LNFTCore() {
    // Stable storage
    private stable var stableLNFTs : [(Types.TokenId, Types.LNFT)] = [];
    private stable var stableMemories : [(Nat, Types.MemoryEntry)] = [];
    private stable var mintCounter : Nat = 0;

    // Custom hash function for large Nat values
    private func natHash(n: Nat): Hash.Hash {
        let h1 = Nat32.fromNat(n);
        let h2 = Nat32.fromNat(n / 4294967296); // 2^32
        // FNV-1a hash
        func fnv1a(h: Nat32): Nat32 {
            let fnv_prime: Nat32 = 16777619;
            let fnv_offset: Nat32 = 2166136261;
            return (fnv_offset ^ h) *% fnv_prime;
        };
        return fnv1a(h1 ^ h2);
    };

    // Runtime state with custom hash function
    private let memories = HashMap.HashMap<Nat, Types.MemoryEntry>(500, Nat.equal, natHash);

    // Rest of the implementation remains the same...
}