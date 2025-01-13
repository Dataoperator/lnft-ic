import Principal "mo:base/Principal";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Types "./Types";

module {
    // Stable storage
    private stable var stableSupply : Nat = 0;
    private stable var stableTokenOwners : [(Types.TokenId, Principal)] = [];
    private stable var stableOwnedTokens : [(Principal, [Types.TokenId])] = [];
    private stable var stableTokenMetadata : [(Types.TokenId, Types.Metadata)] = [];
    private stable var stableVersion : Nat = 0;

    public class ICRC7(owner: Principal) {
        private var supply : Nat = stableSupply;
        private let tokenOwners = HashMap.fromIter<Types.TokenId, Principal>(
            stableTokenOwners.vals(),
            stableTokenOwners.size(),
            Nat.equal,
            Types.tokenIdHash
        );

        private let ownedTokens = HashMap.HashMap<Principal, Buffer.Buffer<Types.TokenId>>(
            10,
            Principal.equal,
            Principal.hash
        );

        private let tokenMetadata = HashMap.fromIter<Types.TokenId, Types.Metadata>(
            stableTokenMetadata.vals(),
            stableTokenMetadata.size(),
            Nat.equal,
            Types.tokenIdHash
        );

        // Initialize owned tokens from stable storage
        do {
            for ((owner, tokens) in stableOwnedTokens.vals()) {
                let tokenBuffer = Buffer.Buffer<Types.TokenId>(tokens.size());
                for (token in tokens.vals()) {
                    tokenBuffer.add(token);
                };
                ownedTokens.put(owner, tokenBuffer);
            };
        };

        // ICRC7 Standard Interface
        public func icrc7_name() : Text {
            "Living NFT"
        };

        public func icrc7_symbol() : Text {
            "LNFT"
        };

        public func icrc7_total_supply() : Nat {
            supply
        };

        public func icrc7_metadata() : [(Text, Text)] {
            [
                ("name", "Living NFT"),
                ("symbol", "LNFT"),
                ("description", "Living NFTs with evolving traits and memories")
            ]
        };

        public func icrc7_owner_of(token_id : Types.TokenId) : ?Types.Account {
            switch (tokenOwners.get(token_id)) {
                case (?owner) {
                    ?{ owner = owner; subaccount = null }
                };
                case null { null }
            }
        };

        // Enhanced minting with events and validation
        public func mint(args : Types.MintArgs) : Result.Result<Types.TokenId, Text> {
            let tokenId = supply;
            supply += 1;

            tokenOwners.put(tokenId, args.to.owner);
            tokenMetadata.put(tokenId, args.metadata);

            // Update owned tokens with efficient buffer usage
            switch (ownedTokens.get(args.to.owner)) {
                case (?tokens) {
                    tokens.add(tokenId);
                };
                case null {
                    let newTokens = Buffer.Buffer<Types.TokenId>(1);
                    newTokens.add(tokenId);
                    ownedTokens.put(args.to.owner, newTokens);
                };
            };

            #ok(tokenId)
        };

        // Optimized transfer implementation
        public func transfer(args : Types.TransferArgs) : Result.Result<(), Types.TransferError> {
            // Validate caller is owner
            if (args.from.owner != msg.caller) {
                return #err(#Unauthorized);
            };

            for (token_id in args.token_ids.vals()) {
                switch (tokenOwners.get(token_id)) {
                    case (?current_owner) {
                        if (current_owner != args.from.owner) {
                            return #err(#Unauthorized);
                        };

                        // Update ownership with efficient updates
                        tokenOwners.put(token_id, args.to.owner);

                        // Update from owner's tokens
                        switch (ownedTokens.get(args.from.owner)) {
                            case (?from_tokens) {
                                let newFromTokens = Buffer.Buffer<Types.TokenId>(from_tokens.size() - 1);
                                for (tid in from_tokens.vals()) {
                                    if (tid != token_id) {
                                        newFromTokens.add(tid);
                                    };
                                };
                                ownedTokens.put(args.from.owner, newFromTokens);
                            };
                            case null {};
                        };

                        // Update to owner's tokens
                        switch (ownedTokens.get(args.to.owner)) {
                            case (?to_tokens) {
                                to_tokens.add(token_id);
                            };
                            case null {
                                let newTokens = Buffer.Buffer<Types.TokenId>(1);
                                newTokens.add(token_id);
                                ownedTokens.put(args.to.owner, newTokens);
                            };
                        };
                    };
                    case null {
                        return #err(#GenericError({ 
                            error_code = 404; 
                            message = "Token not found" 
                        }));
                    };
                };
            };

            #ok(())
        };

        // Efficient metadata retrieval
        public func get_metadata(token_id : Types.TokenId) : ?Types.Metadata {
            tokenMetadata.get(token_id)
        };

        // Optimized token enumeration
        public func tokens_of(owner : Principal) : [Types.TokenId] {
            switch (ownedTokens.get(owner)) {
                case (?tokens) {
                    Buffer.toArray(tokens)
                };
                case null { [] }
            }
        };

        // System functions for upgrades
        public func preupgrade() : () {
            stableSupply := supply;
            stableTokenOwners := Iter.toArray(tokenOwners.entries());
            stableTokenMetadata := Iter.toArray(tokenMetadata.entries());
            
            stableOwnedTokens := Array.mapEntries<Principal, Buffer.Buffer<Types.TokenId>, (Principal, [Types.TokenId])>(
                Iter.toArray(ownedTokens.entries()),
                func(owner, tokens, _) = (owner, Buffer.toArray(tokens))
            );
            
            stableVersion += 1;
        };

        public func postupgrade() : () {
            stableTokenOwners := [];
            stableOwnedTokens := [];
            stableTokenMetadata := [];
        };
    };
}