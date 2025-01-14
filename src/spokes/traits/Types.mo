/// Trait and Rarity System Types
import Time "mo:base/Time";

module {
    /// Represents a trait category
    public type TraitCategory = {
        #Personality;     // Core personality traits
        #Ability;        // Special abilities
        #Appearance;     // Visual characteristics
        #Background;     // Origin story elements
        #Special;        // Event-based or unique traits
    };

    /// Rarity levels for traits
    public type RarityLevel = {
        #Common;      // 50% chance
        #Uncommon;    // 30% chance
        #Rare;       // 15% chance
        #Legendary;   // 4% chance
        #Mythic;      // 1% chance
        #Event;       // Special event-only traits
    };

    /// Trait definition
    public type Trait = {
        id: Text;
        name: Text;
        description: Text;
        category: TraitCategory;
        rarity: RarityLevel;
        maxSupply: ?Nat;     // Optional supply cap
        currentSupply: Nat;   // Current number minted
        modifiers: TraitModifiers;
        compatibility: [Text];  // IDs of compatible traits
        conflicts: [Text];     // IDs of conflicting traits
        metadata: [(Text, Text)];  // Additional properties
    };

    /// Modifiers that a trait applies to an LNFT
    public type TraitModifiers = {
        emotional: [(Text, Int)];     // Modifications to emotional baselines
        learning: [(Text, Int)];      // Modifications to learning rates
        memory: [(Text, Int)];        // Modifications to memory capacity
        special: [(Text, Text)];      // Special effects or abilities
    };

    /// Configuration for trait generation
    public type TraitConfig = {
        baseDistribution: [(RarityLevel, Nat)];  // Base probability distribution
        eventModifiers: [(Text, [(RarityLevel, Nat)])];  // Event-specific modifications
        minTraits: Nat;
        maxTraits: Nat;
        requiredCategories: [TraitCategory];  // Categories that must be present
    };

    /// Result of trait generation
    public type TraitGenerationResult = {
        traits: [Trait];
        rarity: RarityLevel;  // Overall rarity level of the combination
        score: Nat;          // Rarity score (higher = rarer)
        specialEffects: [Text];  // Special effects from trait combinations
    };
};