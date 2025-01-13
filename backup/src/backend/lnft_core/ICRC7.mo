import Principal "mo:base/Principal";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Types "./Types";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

module {
    public type Account = {
        owner : Principal;
        subaccount : ?[Nat8];
    };

    public type TransferArgs = {
        spender_subaccount : ?[Nat8];
        from : Account;
        to : Account;
        token_ids : [Types.TokenId];
        memo : ?Blob;
        created_at_time : ?Nat64;
    };

    public type TransferError = {
        #Unauthorized;
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 };
        #Duplicate : { duplicate_of : Nat };
        #GenericError : { error_code : Nat; message : Text };
    };

    public type MintArgs = {
        to : Account;
        metadata : Types.Metadata;
    };

    public class ICRC7(owner: Principal) {
        private let tokenOwners = HashMap.HashMap<Types.TokenId, Principal>(0, Nat.equal, Hash.hash);
        private let ownedTokens = HashMap.HashMap<Principal, Buffer.Buffer<Types.TokenId>>(0, Principal.equal, Principal.hash);
        private let tokenMetadata = HashMap.HashMap<Types.TokenId, Types.Metadata>(0, Nat.equal, Hash.hash);
        private var nextTokenId : Types.TokenId = 0;

        public func icrc7_name() : Text {
            "Living NFT"
        };

        public func icrc7_symbol() : Text {
            "LNFT"
        };

        public func icrc7_total_supply() : Nat {
            nextTokenId
        };

        public func icrc7_metadata() : [(Text, Text)] {
            [
                ("name", "Living NFT"),
                ("symbol", "LNFT"),
                ("description", "Living NFTs with evolving traits and memories")
            ]
        };

        public func icrc7_owner_of(token_id : Types.TokenId) : ?Account {
            switch (tokenOwners.get(token_id)) {
                case (?owner) {
                    ?{ owner = owner; subaccount = null }
                };
                case null { null }
            }
        };

        public func mint(args : MintArgs) : Result.Result<Types.TokenId, Text> {
            let tokenId = nextTokenId;
            nextTokenId += 1;

            tokenOwners.put(tokenId, args.to.owner);
            tokenMetadata.put(tokenId, args.metadata);

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

        public func transfer(args : TransferArgs) : Result.Result<(), TransferError> {
            // Verify caller is the owner
            if (args.from.owner != msg.caller) {
                return #err(#Unauthorized);
            };

            for (token_id in args.token_ids.vals()) {
                switch (tokenOwners.get(token_id)) {
                    case (?current_owner) {
                        if (current_owner != args.from.owner) {
                            return #err(#Unauthorized);
                        };

                        // Update ownership
                        tokenOwners.put(token_id, args.to.owner);

                        // Update owned tokens buffers
                        switch (ownedTokens.get(args.from.owner)) {
                            case (?from_tokens) {
                                from_tokens.filterEntries(func(_, tid) = tid != token_id);
                            };
                            case null {};
                        };

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

        public func get_metadata(token_id : Types.TokenId) : ?Types.Metadata {
            tokenMetadata.get(token_id)
        };

        public func tokens_of(owner : Principal) : [Types.TokenId] {
            switch (ownedTokens.get(owner)) {
                case (?tokens) {
                    Buffer.toArray(tokens)
                };
                case null { [] }
            }
        };
    }
}