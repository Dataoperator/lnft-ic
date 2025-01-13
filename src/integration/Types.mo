/// Integration System Types
import Time "mo:base/Time";
import SkillTypes "../skill_library/Types";
import CurriculumTypes "../curriculum/Types";
import MemoryTypes "../memory_system/EnhancedTypes";

module {
    /// Represents a complete LNFT state
    public type LNFTState = {
        tokenId: Nat;
        skills: SkillTypes.SkillLibrary;
        curriculum: CurriculumTypes.Curriculum;
        memories: [MemoryTypes.EnhancedMemoryEntry];
        emotionalState: MemoryTypes.EnhancedEmotionalState;
        level: Nat;
        experience: Nat;
        lastUpdate: Time.Time;
    };

    /// Event types that can trigger state changes
    public type StateEvent = {
        #SkillLearned: SkillTypes.Skill;
        #TaskCompleted: CurriculumTypes.Task;
        #EmotionalChange: MemoryTypes.EnhancedEmotionalState;
        #MemoryAdded: MemoryTypes.EnhancedMemoryEntry;
        #LevelUp: Nat;
        #Interaction: InteractionEvent;
    };

    /// Interaction events with other LNFTs or external systems
    public type InteractionEvent = {
        eventType: Text;
        targetId: ?Nat;  // Optional target LNFT
        data: Text;      // Event-specific data
        timestamp: Time.Time;
    };

    /// Response from state update
    public type StateUpdateResponse = {
        success: Bool;
        newState: LNFTState;
        triggers: [StateEvent];  // Additional events triggered by this update
        memoryUpdates: [MemoryTypes.EnhancedMemoryEntry];
    };

    /// Integration configuration
    public type IntegrationConfig = {
        autoGenerateTasks: Bool;
        emotionalSensitivity: Nat8;  // 0-100 scale
        learningRate: Nat8;          // 0-100 scale
        interactionFrequency: Nat;   // Maximum interactions per time period
        maxConcurrentTasks: Nat;
    };
};