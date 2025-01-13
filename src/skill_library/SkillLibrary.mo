/// LNFT Skill Library Implementation
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Types "./Types";
import StableMemory "mo:base/ExperimentalStableMemory";
import Debug "mo:base/Debug";

actor class SkillLibrary() {
    type Skill = Types.Skill;
    type SkillLibrary = Types.SkillLibrary;
    type SkillExecutionResult = Types.SkillExecutionResult;
    type SkillLearningResult = Types.SkillLearningResult;

    /// Stable storage for skill libraries
    private stable var libraries : [(Principal, SkillLibrary)] = [];
    
    /// Runtime buffer for active libraries
    private var activeLibraries = Buffer.Buffer<(Principal, SkillLibrary)>(0);

    /// Initialize a new skill library for an LNFT
    public shared(msg) func initializeLibrary() : async Result.Result<SkillLibrary, Text> {
        let owner = msg.caller;
        
        // Check if library already exists
        switch (getLibrary(owner)) {
            case (?existing) {
                #err("Library already exists for this LNFT");
            };
            case null {
                let newLibrary : SkillLibrary = {
                    owner = owner;
                    skills = Buffer.Buffer<Skill>(10);
                    maxCapacity = 10;
                    level = 1;
                };
                
                activeLibraries.add((owner, newLibrary));
                #ok(newLibrary);
            };
        };
    };

    /// Learn a new skill
    public shared(msg) func learnSkill(skill : Skill) : async SkillLearningResult {
        let owner = msg.caller;
        
        switch (getLibrary(owner)) {
            case (?library) {
                // Check prerequisites
                let missingPrereqs = checkPrerequisites(library, skill.prerequisites);
                if (missingPrereqs.size() > 0) {
                    return #PrerequisitesNeeded(missingPrereqs);
                };

                // Check capacity
                if (library.skills.size() >= library.maxCapacity) {
                    return #Failed("Library at maximum capacity");
                };

                // Add skill to library
                library.skills.add(skill);
                updateLibrary(owner, library);
                
                #Learned(skill);
            };
            case null {
                #Failed("No library found for this LNFT");
            };
        };
    };

    /// Execute a skill
    public shared(msg) func executeSkill(skillId : Text) : async SkillExecutionResult {
        let owner = msg.caller;
        
        switch (getLibrary(owner)) {
            case (?library) {
                switch (findSkill(library, skillId)) {
                    case (?skill) {
                        try {
                            // Here we would actually execute the skill's code
                            // For now, we'll just simulate success
                            #Success("Skill executed successfully");
                        } catch (e) {
                            #Failure("Error executing skill: " # Debug.trap(debug_show(e)));
                        };
                    };
                    case null {
                        #Failure("Skill not found");
                    };
                };
            };
            case null {
                #Failure("No library found for this LNFT");
            };
        };
    };

    /// Upgrade library level
    public shared(msg) func upgradeLibrary() : async Result.Result<Nat, Text> {
        let owner = msg.caller;
        
        switch (getLibrary(owner)) {
            case (?library) {
                let newLevel = library.level + 1;
                let newCapacity = library.maxCapacity + 5;
                
                let updatedLibrary : SkillLibrary = {
                    owner = library.owner;
                    skills = library.skills;
                    maxCapacity = newCapacity;
                    level = newLevel;
                };
                
                updateLibrary(owner, updatedLibrary);
                #ok(newLevel);
            };
            case null {
                #err("No library found for this LNFT");
            };
        };
    };

    /// Helper functions
    private func getLibrary(owner : Principal) : ?SkillLibrary {
        for ((libOwner, lib) in activeLibraries.vals()) {
            if (libOwner == owner) {
                return ?lib;
            };
        };
        null;
    };

    private func updateLibrary(owner : Principal, library : SkillLibrary) {
        var index = 0;
        for ((libOwner, _) in activeLibraries.vals()) {
            if (libOwner == owner) {
                activeLibraries.put(index, (owner, library));
                return;
            };
            index += 1;
        };
    };

    private func findSkill(library : SkillLibrary, skillId : Text) : ?Skill {
        for (skill in library.skills.vals()) {
            if (skill.id == skillId) {
                return ?skill;
            };
        };
        null;
    };

    private func checkPrerequisites(library : SkillLibrary, required : [Text]) : [Text] {
        var missing = Buffer.Buffer<Text>(0);
        for (reqId in required.vals()) {
            switch (findSkill(library, reqId)) {
                case null {
                    missing.add(reqId);
                };
                case _ {};
            };
        };
        Buffer.toArray(missing);
    };

    /// System hooks
    system func preupgrade() {
        libraries := Buffer.toArray(activeLibraries);
    };

    system func postupgrade() {
        activeLibraries := Buffer.fromArray(libraries);
        libraries := [];
    };
}