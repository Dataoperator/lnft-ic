import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";

module {
    public type Account = { owner : Principal; subaccount : ?[Nat8] };
    public type Memo = Blob;
    public type TransactionId = Nat;
    public type TokenId = Nat;
    public type Timestamp = Int;

    // Custom hash function for Nat values
    private func natHash(n: Nat) : Hash.Hash {
        Text.hash(Nat.toText(n))
    };

    public type MetadataContainer = {
        #Metadata : [(Text, MetadataValue)];
        #Blob : Blob;
    };

    public type MetadataValue = {
        #Nat : Nat;
        #Int : Int;
        #Text : Text;
        #Blob : Blob;
        #Array : [MetadataValue];
    };

    public type MintArgs = {
        to : Account;
        metadata : ?MetadataContainer;
    };

    public type BurnArgs = {
        token_id : TokenId;
    };

    public type Result_1 = {
        #Ok : TokenId;
        #Err : Error;
    };

    public type Error = {
        #GenericError;
        #Unauthorized;
        #InvalidTokenId;
        #AlreadyExistTokenId;
        #InvalidRequest;
    };

    public type TransferArgs = {
        to : Account;
        token_id : TokenId;
        memo : ?Memo;
    };

    public type TransferError = {
        #Unauthorized;
        #InvalidTokenId;
        #InvalidRequest;
    };

    public type ApprovalArgs = {
        from_subaccount : ?[Nat8];
        spender : Principal;
        token_id : TokenId;
        expires_at : ?Timestamp;
    };

    public type ApprovalError = {
        #Unauthorized;
        #InvalidTokenId;
        #InvalidRequest;
    };

    public class ICRC7(_owner : Principal, _symbol : Text, _name : Text, _description : Text, _royalties : Nat, _royaltyRecipient : Principal, _supply_cap : ?Nat) {
        // Token Data
        private var totalSupply : Nat = 0;
        private let metadata = TrieMap.TrieMap<TokenId, MetadataContainer>(Nat.equal, natHash);
        private let owners = TrieMap.TrieMap<TokenId, Account>(Nat.equal, natHash);
        private let balances = TrieMap.TrieMap<Principal, Buffer.Buffer<TokenId>>(Principal.equal, Principal.hash);
        private let approved = TrieMap.TrieMap<TokenId, (Principal, ?Timestamp)>(Nat.equal, natHash);
        private let transactions = Buffer.Buffer<(Time.Time, TransactionId)>(0);
        private var lastTxId : Nat = 0;
        
        // Collection Settings
        private let owner = _owner;
        private let symbol = _symbol;
        private let name = _name;
        private let description = _description;
        private let royalties = _royalties;
        private let royaltyRecipient = _royaltyRecipient;
        private let supply_cap = _supply_cap;

        // Implementation
        public func get_token_metadata(tokenId : TokenId) : ?MetadataContainer {
            metadata.get(tokenId)
        };

        public func owner_of(tokenId : TokenId) : ?Account {
            owners.get(tokenId)
        };

        public func balance_of(account : Account) : Nat {
            switch(balances.get(account.owner)) {
                case(null) { 0 };
                case(?tokens) { tokens.size() };
            }
        };

        public func get_transactions(_account : Account) : [(Time.Time, TransactionId)] {
            Buffer.toArray(transactions)
        };

        public func is_approved(tokenId : TokenId, spender : Principal) : Bool {
            switch(approved.get(tokenId)) {
                case(null) { false };
                case(?(approvedSpender, expiry)) {
                    if(approvedSpender == spender) {
                        switch(expiry) {
                            case(null) { true };
                            case(?exp) { exp > Time.now() };
                        }
                    } else {
                        false
                    }
                }
            }
        };

        public func approve(args : ApprovalArgs, caller : Principal) : Result.Result<(), ApprovalError> {
            switch(owners.get(args.token_id)) {
                case(null) {
                    #err(#InvalidTokenId)
                };
                case(?currentOwner) {
                    if(currentOwner.owner != caller) {
                        return #err(#Unauthorized)
                    };
                    approved.put(args.token_id, (args.spender, args.expires_at));
                    #ok()
                }
            }
        };

        public func transfer(args : TransferArgs, caller : Principal) : Result.Result<(), TransferError> {
            switch(owners.get(args.token_id)) {
                case(null) {
                    return #err(#InvalidTokenId)
                };
                case(?currentOwner) {
                    if(currentOwner.owner != caller and not is_approved(args.token_id, caller)) {
                        return #err(#Unauthorized)
                    };

                    switch(balances.get(currentOwner.owner)) {
                        case(null) { return #err(#InvalidRequest) };
                        case(?tokens) {
                            let index = Buffer.indexOf<TokenId>(args.token_id, tokens, Nat.equal);
                            switch(index) {
                                case(null) { return #err(#InvalidRequest) };
                                case(?i) { ignore tokens.remove(i) };
                            }
                        }
                    };

                    switch(balances.get(args.to.owner)) {
                        case(null) {
                            let newBalance = Buffer.Buffer<TokenId>(1);
                            newBalance.add(args.token_id);
                            balances.put(args.to.owner, newBalance);
                        };
                        case(?tokens) { tokens.add(args.token_id) }
                    };

                    owners.put(args.token_id, args.to);
                    approved.delete(args.token_id);
                    lastTxId += 1;
                    transactions.add((Time.now(), lastTxId));
                    #ok()
                }
            }
        };

        public func mint(args : MintArgs, caller : Principal) : Result_1 {
            if(caller != owner) {
                return #Err(#Unauthorized)
            };

            switch(supply_cap) {
                case(?cap) {
                    if(totalSupply >= cap) {
                        return #Err(#GenericError)
                    }
                };
                case(null) {}
            };

            let tokenId = totalSupply;

            switch(args.metadata) {
                case(?md) { metadata.put(tokenId, md) };
                case(null) {}
            };

            owners.put(tokenId, args.to);

            switch(balances.get(args.to.owner)) {
                case(null) {
                    let newBalance = Buffer.Buffer<TokenId>(1);
                    newBalance.add(tokenId);
                    balances.put(args.to.owner, newBalance);
                };
                case(?tokens) { tokens.add(tokenId) }
            };

            totalSupply += 1;
            lastTxId += 1;
            transactions.add((Time.now(), lastTxId));
            #Ok(tokenId)
        };

        // Standard metadata
        public func icrc7_name() : Text { name };
        public func icrc7_symbol() : Text { symbol };
        public func icrc7_description() : Text { description };
        public func icrc7_total_supply() : Nat { totalSupply };
        public func icrc7_supply_cap() : ?Nat { supply_cap };
        public func icrc7_royalties() : Nat { royalties };
        public func icrc7_royalty_recipient() : Principal { royaltyRecipient };
        public func icrc7_collection_metadata() : MetadataContainer {
            #Metadata([
                ("name", #Text(name)),
                ("symbol", #Text(symbol)),
                ("description", #Text(description)),
                ("royalties", #Nat(royalties)),
                ("royaltyRecipient", #Text(Principal.toText(royaltyRecipient))),
            ])
        };

        // Supported standards
        public func supported_standards() : [Text] {
            ["ICRC-7"]
        };
    };
};