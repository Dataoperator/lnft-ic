        // Upgrade memory capacity
        let memoryUpgrade = switch (memoryCanister) {
            case (?canister) {
                // Call memory canister to upgrade capacity
                let increase = calculateMemoryIncrease(newLevel);
                await MemorySystem.upgradeMemoryCapacity(state.tokenId, increase);
            };
            case null #err("Memory canister not configured");
        };

        // Upgrade skill library
        let skillUpgrade = switch (skillCanister) {
            case (?canister) {
                let newCapacity = calculateSkillCapacity(newLevel);
                await SkillLibrary.upgradeLibrary(state.tokenId, newCapacity);
            };
            case null #err("Skill canister not configured");
        };

        // Upgrade curriculum
        let curriculumUpgrade = switch (curriculumCanister) {
            case (?canister) {
                let newConfig = calculateCurriculumConfig(newLevel);
                await CurriculumSystem.upgradeCurriculum(state.tokenId, newConfig);
            };
            case null #err("Curriculum canister not configured");
        };

        {
            state with
            level = newLevel;
            // Update other fields based on upgrade results
        };
    };

    private func generateLevelTasks(state: LNFTState) : async () {
        switch (curriculumCanister) {
            case (?canister) {
                let levelTasks = generateTasksForLevel(state.level);
                await CurriculumSystem.addTasks(state.tokenId, levelTasks);
            };
            case null {};
        };
    };

    private func handleInteraction(
        state: LNFTState,
        event: Types.InteractionEvent
    ) : async (LNFTState, MemoryTypes.EnhancedMemoryEntry) {
        // Process interaction based on type
        let memory = switch (event.eventType) {
            case "social_interaction" {
                // Handle social interaction between LNFTs
                let memory = createInteractionMemory(event);
                
                // Update emotional state based on interaction
                let emotionalImpact = calculateInteractionEmotion(event);
                ignore await updateEmotionalState(state.tokenId, emotionalImpact);
                
                memory;
            };
            case "skill_sharing" {
                // Handle skill sharing between LNFTs
                let sharedSkill = parseSharedSkill(event.data);
                ignore await processSkillSharing(state.tokenId, sharedSkill, event.targetId);
                
                createSkillSharingMemory(event);
            };
            case "collaborative_task" {
                // Handle collaborative task between LNFTs
                let taskData = parseCollaborativeTask(event.data);
                ignore await processCollaborativeTask(state.tokenId, taskData, event.targetId);
                
                createCollaborativeTaskMemory(event);
            };
            case _ {
                createGenericInteractionMemory(event);
            };
        };

        // Update state based on interaction results
        let updatedState = {
            state with
            lastUpdate = Time.now();
        };

        (updatedState, memory);
    };

    // Helper functions for interaction handling
    private func createInteractionMemory(
        event: Types.InteractionEvent
    ) : MemoryTypes.EnhancedMemoryEntry {
        {
            timestamp = event.timestamp;
            content = "Interacted with LNFT " # Option.get(event.targetId, 0);
            category = #Social;
            emotional_impact = null;  // Will be calculated based on interaction
            tags = ["interaction", event.eventType];
            metadata = null;
            linked_entities = switch(event.targetId) {
                case (?id) ?[Nat.toText(id)];
                case null null;
            };
            importance = 70;
        };
    };

    private func createSkillSharingMemory(
        event: Types.InteractionEvent
    ) : MemoryTypes.EnhancedMemoryEntry {
        {
            timestamp = event.timestamp;
            content = "Shared skill with LNFT " # Option.get(event.targetId, 0);
            category = #Skill;
            emotional_impact = ?{
                base = "collaboration";
                secondary = ?"teaching";
                intensity = 75;
                duration = ?Time.now();
                triggers = ["skill_sharing"];
                context = ?event.data;
            };
            tags = ["skill_sharing", "collaboration"];
            metadata = null;
            linked_entities = switch(event.targetId) {
                case (?id) ?[Nat.toText(id)];
                case null null;
            };
            importance = 80;
        };
    };

    private func createCollaborativeTaskMemory(
        event: Types.InteractionEvent
    ) : MemoryTypes.EnhancedMemoryEntry {
        {
            timestamp = event.timestamp;
            content = "Collaborated on task with LNFT " # Option.get(event.targetId, 0);
            category = #Achievement;
            emotional_impact = ?{
                base = "cooperation";
                secondary = ?"accomplishment";
                intensity = 80;
                duration = ?Time.now();
                triggers = ["collaboration"];
                context = ?event.data;
            };
            tags = ["collaborative_task", "teamwork"];
            metadata = null;
            linked_entities = switch(event.targetId) {
                case (?id) ?[Nat.toText(id)];
                case null null;
            };
            importance = 85;
        };
    };

    private func createGenericInteractionMemory(
        event: Types.InteractionEvent
    ) : MemoryTypes.EnhancedMemoryEntry {
        {
            timestamp = event.timestamp;
            content = "Generic interaction: " # event.eventType;
            category = #Social;
            emotional_impact = null;
            tags = ["interaction", event.eventType];
            metadata = null;
            linked_entities = switch(event.targetId) {
                case (?id) ?[Nat.toText(id)];
                case null null;
            };
            importance = 60;
        };
    };

    // Calculation helper functions
    private func calculateMemoryIncrease(level: Nat) : Nat {
        // Base increase of 100 memories per level
        100 * level;
    };

    private func calculateSkillCapacity(level: Nat) : Nat {
        // Base capacity of 5 skills, +3 per level
        5 + (3 * level);
    };

    private func calculateCurriculumConfig(level: Nat) : CurriculumTypes.CurriculumConfig {
        {
            maxTasks = 5 + level;
            taskDifficulty = if (level < 5) #Beginner
                           else if (level < 10) #Intermediate
                           else if (level < 15) #Advanced
                           else #Expert;
            rewardMultiplier = 1 + (level / 5);
        };
    };

    // System hooks for upgrade safety
    system func preupgrade() {
        // Implementation for stable storage
    };

    system func postupgrade() {
        // Implementation for stable storage restoration
    };

    // Canister configuration
    public shared({ caller }) func configureCanister(
        name: Text,
        canister: Principal
    ) : async () {
        switch(name) {
            case "skill" { skillCanister := ?canister; };
            case "curriculum" { curriculumCanister := ?canister; };
            case "memory" { memoryCanister := ?canister; };
            case _ {};
        };
    };
}
