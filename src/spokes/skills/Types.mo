import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

module {
    public type Skill = {
        id : Nat;
        name : Text;
        description : Text;
        category : Text;
        level : Nat;
        experience : Nat;
    };

    public type SkillCategory = {
        #Combat;
        #Magic;
        #Crafting;
        #Social;
        #Knowledge;
        #Special : Text;
    };

    public type SkillProgress = {
        skillId : Nat;
        currentExp : Nat;
        level : Nat;
        lastUsed : Time.Time;
    };

    public type SkillResult = {
        success : Bool;
        message : Text;
        expGained : Nat;
    };

    public type SkillUpgrade = {
        skillId : Nat;
        newLevel : Nat;
        bonuses : [Text];
    };
}