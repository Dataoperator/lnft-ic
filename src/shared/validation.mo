import Types "../hub/types";
import Utils "./utils";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Result "mo:base/Result";

module {
    public type ValidationResult = Result.Result<(), Text>;

    // Token Validation
    public func validateTokenMetadata(name: Text, description: Text) : ValidationResult {
        if (not Utils.validateText(name, 1, 100)) {
            #err("Token name must be between 1 and 100 characters")
        } else if (not Utils.validateText(description, 0, 1000)) {
            #err("Token description must be less than 1000 characters")
        } else {
            #ok(())
        }
    };

    // Memory Validation
    public func validateMemoryContent(content: Text) : ValidationResult {
        if (not Utils.validateText(content, 1, 5000)) {
            #err("Memory content must be between 1 and 5000 characters")
        } else {
            #ok(())
        }
    };

    public func validateMemoryStrength(strength: Nat) : ValidationResult {
        if (not Utils.validateNat(strength, 0, 100)) {
            #err("Memory strength must be between 0 and 100")
        } else {
            #ok(())
        }
    };

    // Trait Validation
    public func validateTraitData(
        name: Text,
        description: Text,
        level: Nat
    ) : ValidationResult {
        if (not Utils.validateText(name, 1, 50)) {
            #err("Trait name must be between 1 and 50 characters")
        } else if (not Utils.validateText(description, 1, 500)) {
            #err("Trait description must be between 1 and 500 characters")
        } else if (not Utils.validateNat(level, 1, 100)) {
            #err("Trait level must be between 1 and 100")
        } else {
            #ok(())
        }
    };

    // Skill Validation
    public func validateSkillData(
        name: Text,
        description: Text,
        level: Nat,
        experience: Nat
    ) : ValidationResult {
        if (not Utils.validateText(name, 1, 50)) {
            #err("Skill name must be between 1 and 50 characters")
        } else if (not Utils.validateText(description, 1, 500)) {
            #err("Skill description must be between 1 and 500 characters")
        } else if (not Utils.validateNat(level, 1, 100)) {
            #err("Skill level must be between 1 and 100")
        } else if (not Utils.validateNat(experience, 0, 10000)) {
            #err("Experience must be between 0 and 10000")
        } else {
            #ok(())
        }
    };

    // Emotional State Validation
    public func validateEmotionalState(state: Types.EmotionalState) : ValidationResult {
        if (not Utils.validateNat(state.joy, 0, 100)) {
            #err("Joy must be between 0 and 100")
        } else if (not Utils.validateNat(state.sadness, 0, 100)) {
            #err("Sadness must be between 0 and 100")
        } else if (not Utils.validateNat(state.anger, 0, 100)) {
            #err("Anger must be between 0 and 100")
        } else if (not Utils.validateNat(state.fear, 0, 100)) {
            #err("Fear must be between 0 and 100")
        } else if (not Utils.validateNat(state.trust, 0, 100)) {
            #err("Trust must be between 0 and 100")
        } else {
            #ok(())
        }
    };

    // Practice Validation
    public func validatePracticeData(duration: Nat, effectiveness: Nat) : ValidationResult {
        if (not Utils.validateNat(duration, 1, 480)) { // Max 8 hours
            #err("Practice duration must be between 1 and 480 minutes")
        } else if (not Utils.validateNat(effectiveness, 0, 100)) {
            #err("Effectiveness must be between 0 and 100")
        } else {
            #ok(())
        }
    };

    // Neural Response Validation
    public func validateNeuralResponse(response: Text, confidence: Float) : ValidationResult {
        if (not Utils.validateText(response, 1, 2000)) {
            #err("Neural response must be between 1 and 2000 characters")
        } else if (confidence < 0 or confidence > 1) {
            #err("Confidence must be between 0 and 1")
        } else {
            #ok(())
        }
    };

    // Auth Validation
    public func validateDisplayName(name: Text) : ValidationResult {
        if (not Utils.validateText(name, 3, 50)) {
            #err("Display name must be between 3 and 50 characters")
        } else {
            #ok(())
        }
    };

    public func validateSessionDuration(durationMs: Nat) : ValidationResult {
        let maxDuration = 30 * 24 * 60 * 60 * 1000; // 30 days
        if (not Utils.validateNat(durationMs, 60_000, maxDuration)) {
            #err("Session duration must be between 1 minute and 30 days")
        } else {
            #ok(())
        }
    };

    // Array Validation Helpers
    public func validateArrayLength<T>(array: [T], minLength: Nat, maxLength: Nat) : ValidationResult {
        let length = array.size();
        if (length < minLength) {
            #err("Array must have at least " # Nat.toText(minLength) # " elements")
        } else if (length > maxLength) {
            #err("Array cannot have more than " # Nat.toText(maxLength) # " elements")
        } else {
            #ok(())
        }
    };

    // Metadata Validation
    public func validateMetadataPair(key: Text, value: Text) : ValidationResult {
        if (not Utils.validateText(key, 1, 50)) {
            #err("Metadata key must be between 1 and 50 characters")
        } else if (not Utils.validateText(value, 0, 500)) {
            #err("Metadata value must be less than 500 characters")
        } else {
            #ok(())
        }
    };

    public func validateMetadataArray(metadata: [(Text, Text)]) : ValidationResult {
        switch (validateArrayLength(metadata, 0, 20)) {
            case (#err(e)) { #err(e) };
            case (#ok(_)) {
                for ((key, value) in metadata.vals()) {
                    switch (validateMetadataPair(key, value)) {
                        case (#err(e)) { return #err(e) };
                        case (#ok(_)) {};
                    };
                };
                #ok(())
            };
        }
    };

    // Combined Validation
    public func validateAll(validations: [ValidationResult]) : ValidationResult {
        for (validation in validations.vals()) {
            switch (validation) {
                case (#err(e)) { return #err(e) };
                case (#ok(_)) {};
            };
        };
        #ok(())
    };

    // Helper for aggregating multiple validation errors
    public func aggregateValidations(validations: [ValidationResult]) : Text {
        let errors = Array.mapFilter<ValidationResult, Text>(
            validations,
            func (v: ValidationResult) : ?Text {
                switch (v) {
                    case (#err(e)) { ?e };
                    case (#ok(_)) { null };
                }
            }
        );
        Text.join("; ", errors.vals())
    };
};