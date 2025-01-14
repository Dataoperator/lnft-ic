import Types "./Types";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Time "mo:base/Time";

module {
    public type RarityLevel = Types.RarityLevel;
    public type Trait = Types.Trait;

    public func calculateRarityBonus(baseValue : Nat, rarityLevel : RarityLevel) : Nat {
        let multiplier = switch (rarityLevel) {
            case (#Common) 100;
            case (#Uncommon) 150;
            case (#Rare) 200;
            case (#Epic) 300;
            case (#Legendary) 500;
        };
        baseValue * multiplier / 100
    };

    public func getRarityProbability(level : RarityLevel) : Nat {
        switch (level) {
            case (#Common) 50;     // 50%
            case (#Uncommon) 30;   // 30%
            case (#Rare) 15;       // 15%
            case (#Epic) 4;        // 4%
            case (#Legendary) 1;    // 1%
        }
    };

    public func isRarityHigherOrEqual(a : RarityLevel, b : RarityLevel) : Bool {
        let getValue = func (r : RarityLevel) : Nat {
            switch (r) {
                case (#Common) 1;
                case (#Uncommon) 2;
                case (#Rare) 3;
                case (#Epic) 4;
                case (#Legendary) 5;
            }
        };
        getValue(a) >= getValue(b)
    };
}