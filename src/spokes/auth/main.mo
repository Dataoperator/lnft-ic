import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Error "mo:base/Error";

actor Auth {
    // Simple ID generation without uuid dependency
    private var nextId: Nat = 0;
    
    private func generateId() : Text {
        nextId += 1;
        Nat.toText(nextId) # "-" # Int.toText(Time.now())
    };

    public shared({ caller }) func authenticate() : async Text {
        if (Principal.isAnonymous(caller)) {
            throw Error.reject("Anonymous principals not allowed");
        };
        
        generateId()
    };

    public shared({ caller }) func validate(sessionId: Text) : async Bool {
        if (Principal.isAnonymous(caller)) {
            return false;
        };
        
        // Simple validation - in production would need more robust check
        let parts = Text.split(sessionId, #char '-');
        switch (parts.next()) {
            case (?id) {
                let idNat = textToNat(id);
                idNat <= nextId
            };
            case null { false };
        }
    };

    private func textToNat(t : Text) : Nat {
        var n : Nat = 0;
        for (c in t.chars()) {
            let charToNum = Nat32.toNat(Char.toNat32(c) - 48);
            if (charToNum >= 0 and charToNum <= 9) {
                n := n * 10 + charToNum;
            };
        };
        n
    };
};