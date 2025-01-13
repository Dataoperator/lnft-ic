/// LNFT Skill Library Types
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

module {
    /// Represents a skill that an LNFT can learn and execute
    public type Skill = {
        id : Text;
        name : Text;
        description : Text;
        code : Text;  // The actual executable code snippet
        category : SkillCategory;
        rarity : Rarity;
        prerequisites : [Text];  // IDs of required skills
        created : Time.Time;
        modified : Time.Time;
        metadata : [SkillMetadata];
    };

    /// Categories of skills
    public type SkillCategory = {
        #ApiCall;       // External API interactions
        #DataAnalysis;  // Processing and analyzing data
        #MediaGen;      // Image/audio generation
        #Social;        // Interactions with other LNFTs
        #Custom : Text; // Custom category
    };

    /// Rarity levels for skills
    public type Rarity = {
        #Common;
        #Uncommon;
        #Rare;
        #Legendary;
        #Event : Text;  // Special event-based rarity
    };

    /// Additional metadata for skills
    public type SkillMetadata = {
        key : Text;
        value : Text;
    };

    /// Represents a collection of skills
    public type SkillLibrary = {
        owner : Principal;  // LNFT ID that owns these skills
        skills : Buffer.Buffer<Skill>;
        maxCapacity : Nat;  // Maximum number of skills that can be stored
        level : Nat;       // Library level (affects maxCapacity)
    };

    /// Execution result of a skill
    public type SkillExecutionResult = {
        #Success : Text;
        #Failure : Text;
        memoryLog : Text;  // Log entry to be added to LNFT memory
    };

    /// Skill learning result
    public type SkillLearningResult = {
        #Learned : Skill;
        #Failed : Text;
        #PrerequisitesNeeded : [Text];
    };
}