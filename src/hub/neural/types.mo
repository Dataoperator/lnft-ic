/**
 * LNFT Neural Core Type System
 * File: types.mo
 * Purpose: Comprehensive type definitions for the LNFT Neural Processing System
 * Version: 1.0.0
 */

import Float "mo:base/Float";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Order "mo:base/Order";
import Int "mo:base/Int";

module {
    // =============== Core Identity Types ===============
    public type EntityId = {
        id: Nat;
        creation_time: Time.Time;
        last_modified: Time.Time;
        version: Nat;
    };

    // =============== Emotional System Types ===============
    public type EmotionIntensity = Float;  // 0.0 to 1.0 scale

    public type EmotionalDimension = {
        #joy : EmotionIntensity;           // Joy vs Sadness (0.0-1.0)
        #trust : EmotionIntensity;         // Trust vs Distrust (0.0-1.0)
        #fear : EmotionIntensity;          // Fear vs Courage (0.0-1.0)
        #surprise : EmotionIntensity;      // Surprise vs Anticipation (0.0-1.0)
        #sadness : EmotionIntensity;       // Sadness vs Joy (0.0-1.0)
        #disgust : EmotionIntensity;       // Disgust vs Acceptance (0.0-1.0)
        #anger : EmotionIntensity;         // Anger vs Serenity (0.0-1.0)
        #anticipation : EmotionIntensity;  // Anticipation vs Surprise (0.0-1.0)
    };

    public type EmotionalState = {
        dimensions: [EmotionalDimension];
        timestamp: Time.Time;
        overall_intensity: EmotionIntensity;
        stability_factor: Float;            // Resistance to change (0.0-1.0)
        dominant_emotion: EmotionalDimension;
        recent_changes: [(EmotionalDimension, Float)];  // Track recent shifts
        decay_rate: Float;                  // Natural emotion decay rate
        confidence: Float;                  // Certainty in emotional assessment
    };

    // =============== Memory System Types ===============
    public type MemoryPriority = {
        #critical;    // Must be preserved
        #high;        // Important memories
        #medium;      // Regular memories
        #low;         // Can be compressed/forgotten
    };

    public type MemoryNode = {
        id: Nat;
        content: {
            #text: Text;
            #emotional: EmotionalState;
            #composite: [MemoryNode];
            #reference: EntityId;           // Reference to another entity
        };
        context: {
            emotional_state: EmotionalState;
            environmental_factors: [(Text, Float)];
            social_context: ?[EntityId];
            temporal_context: Time.Time;
            spatial_context: ?Text;         // Location/space reference
        };
        metadata: {
            creation_time: Time.Time;
            last_accessed: Time.Time;
            access_count: Nat;
            priority: MemoryPriority;
            tags: [Text];
            version: Nat;
            compression_history: [(Time.Time, Nat)];  // Compression level changes
        };
        associations: [MemoryAssociation];
        compression_level: Nat;             // 0 = uncompressed
        recall_strength: Float;             // 0.0-1.0
        validation_status: ValidationResult;
    };

    public type MemoryAssociation = {
        source_id: Nat;
        target_id: Nat;
        association_type: {
            #causal;        // Cause and effect
            #temporal;      // Time-based
            #semantic;      // Meaning-based
            #emotional;     // Feeling-based
            #spatial;       // Location-based
            #hierarchical; // Part-whole relationships
            #analogical;   // Similarity-based
        };
        strength: Float;    // 0.0-1.0
        creation_time: Time.Time;
        reinforcement_count: Nat;
        context: Text;
        bidirectional: Bool;  // Whether association works both ways
        decay_rate: Float;    // How quickly association weakens
    };

    // =============== Trait System Types ===============
    public type TraitCategory = {
        #personality;     // Core personality traits
        #skill;          // Learned abilities
        #social;         // Social capabilities
        #cognitive;      // Mental abilities
        #emotional;      // Emotional capabilities
        #physical;       // Physical characteristics
        #composite;      // Combination of multiple categories
    };

    public type TraitLevel = {
        current: Nat;
        maximum: Nat;
        minimum: Nat;
        progress: Float;    // 0.0-1.0 to next level
        regression: Float;  // Progress towards level loss
        last_update: Time.Time;
        evolution_history: [(Time.Time, Int)];  // Track level changes
    };

    public type TraitDefinition = {
        id: Nat;
        name: Text;
        category: TraitCategory;
        description: Text;
        level: TraitLevel;
        modifiers: [(Text, Float)];         // Named effect modifiers
        evolution: {
            rate: Float;                    // Base evolution rate
            factors: [(Text, Float)];       // Influencing factors
            triggers: [Text];               // Evolution trigger conditions
            constraints: [(Text, Float)];   // Evolution limitations
        };
        dependencies: [TraitDependency];
        metadata: {
            creation_time: Time.Time;
            last_modified: Time.Time;
            version: Nat;
            stability: Float;               // Resistance to change
            flexibility: Float;             // Ability to adapt
        };
        validation: ValidationResult;
    };

    public type TraitDependency = {
        trait_id: Nat;
        relationship_type: {
            #requires;      // Must have to progress
            #conflicts;     // Inhibits progress
            #synergizes;    // Enhances progress
            #transforms;    // Can transform into
            #catalyzes;    // Accelerates changes
        };
        influence_weight: Float;  // -1.0 to 1.0
        minimum_level: Nat;
        conditions: [Text];       // Additional conditions
        temporal_factor: Float;   // Time-based influence
    };

    // =============== State Management Types ===============
    public type StateTransition = {
        id: Nat;
        transition_type: {
            #emotional;
            #trait;
            #memory;
            #composite;
            #emergency;     // Critical state changes
        };
        from_state: {
            #emotional: EmotionalState;
            #trait: TraitDefinition;
            #memory: MemoryNode;
            #composite: [StateTransition];
        };
        to_state: {
            #emotional: EmotionalState;
            #trait: TraitDefinition;
            #memory: MemoryNode;
            #composite: [StateTransition];
        };
        trigger: {
            event_id: ?Nat;
            condition: Text;
            threshold: Float;
            context: ?Text;
        };
        metadata: {
            timestamp: Time.Time;
            duration: Int;           // Transition duration in nanoseconds
            energy_cost: Float;      // Computational cost
            reversible: Bool;
            validation: ValidationResult;
        };
    };

    // =============== Validation Types ===============
    public type ValidationSeverity = {
        #error;        // Must be fixed
        #warning;      // Should be addressed
        #info;         // Informational only
    };

    public type ValidationResult = {
        valid: Bool;
        timestamp: Time.Time;
        messages: [{
            severity: ValidationSeverity;
            code: Text;
            message: Text;
            context: ?Text;
            resolution: ?Text;
        }];
        metrics: ?{
            duration: Int;
            resource_usage: Float;
            confidence: Float;
        };
        history: [(Time.Time, Bool)];  // Validation history
    };

    // =============== Performance Types ===============
    public type PerformanceMetrics = {
        timestamp: Time.Time;
        emotional_processing: {
            average_time: Int;       // in nanoseconds
            peak_time: Int;
            operation_count: Nat;
            error_count: Nat;
            success_rate: Float;
        };
        memory_operations: {
            retrieval_time: Int;     // in nanoseconds
            storage_time: Int;
            compression_ratio: Float;
            cache_hits: Nat;
            optimization_level: Float;
        };
        trait_evolution: {
            processing_time: Int;    // in nanoseconds
            evolution_events: Nat;
            successful_changes: Nat;
            regression_events: Nat;
            stability_index: Float;
        };
        system_health: {
            uptime: Int;
            memory_usage: Float;
            cpu_usage: Float;
            error_rate: Float;
            responsiveness: Float;
            optimization_status: Text;
        };
    };

    // =============== Configuration Types ===============
    public type NeuralCoreConfig = {
        emotional_system: {
            base_decay_rate: Float;          // Per hour
            intensity_threshold: Float;       // Minimum for processing
            stability_factor: Float;          // Change resistance
            dimension_weights: [(Text, Float)];  // Per dimension
            adaptation_rate: Float;           // Learning rate
        };
        memory_system: {
            retention_factor: Float;         // Base retention strength
            compression_threshold: Float;     // When to compress
            association_minimum: Float;       // Minimum association strength
            cache_size: Nat;                 // Nodes to keep in quick access
            optimization_frequency: Int;      // Cleanup interval
        };
        trait_system: {
            evolution_base_rate: Float;      // Base evolution speed
            level_scaling: Float;            // Level difficulty curve
            dependency_impact: Float;        // Dependency influence strength
            mutation_chance: Float;          // Random evolution chance
            regression_resistance: Float;    // Resistance to losing progress
        };
        performance: {
            target_processing_time: Int;     // Target ns for operations
            max_memory_usage: Float;         // Maximum memory usage %
            optimization_threshold: Float;    // When to optimize
            backup_frequency: Int;           // Backup interval in hours
            monitoring_granularity: Int;     // Metrics collection frequency
        };
        safety: {
            validation_frequency: Int;       // How often to validate state
            error_tolerance: Float;          // Acceptable error rate
            recovery_mode: Text;             // How to handle critical errors
            backup_retention: Int;           // How long to keep backups
        };
    };

    // =============== Error Handling ===============
    public type ErrorCode = {
        #validation_failed;
        #resource_exhausted;
        #invalid_state;
        #system_error;
        #timeout;
        #data_corruption;
        #performance_degradation;
        #security_violation;
    };

    public type Result<T> = Result.Result<T, {
        code: ErrorCode;
        message: Text;
        timestamp: Time.Time;
        context: ?Text;
        severity: ValidationSeverity;
        recovery_suggestion: ?Text;
    }>;
};