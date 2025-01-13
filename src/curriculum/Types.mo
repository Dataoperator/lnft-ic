/// LNFT Curriculum System Types
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

module {
    /// Represents a learning task or goal for the LNFT
    public type Task = {
        id : Text;
        title : Text;
        description : Text;
        category : TaskCategory;
        difficulty : Difficulty;
        requirements : [Text];  // Required skills or previous tasks
        rewards : [Reward];
        deadline : ?Time.Time;  // Optional deadline for event-based tasks
        status : TaskStatus;
    };

    /// Categories of tasks
    public type TaskCategory = {
        #Exploration;    // Discovering new capabilities
        #Skill;         // Learning new skills
        #Social;        // Interacting with other LNFTs
        #Event;         // Special time-limited tasks
        #Achievement;   // Long-term goals
        #Custom : Text; // Custom category
    };

    /// Difficulty levels
    public type Difficulty = {
        #Beginner;
        #Intermediate;
        #Advanced;
        #Expert;
    };

    /// Possible rewards for completing tasks
    public type Reward = {
        #Skill : Text;         // New skill ID
        #Trait : Text;         // New trait ID
        #EmotionalState : Text; // New emotional state
        #MemoryExpansion : Nat; // Additional memory capacity
        #Custom : Text;        // Custom reward
    };

    /// Status of a task
    public type TaskStatus = {
        #Available;     // Can be started
        #InProgress;    // Currently being worked on
        #Completed;     // Successfully finished
        #Failed;        // Failed to complete
        #Expired;       // Time-limited task that expired
    };

    /// Represents the curriculum for an LNFT
    public type Curriculum = {
        owner : Principal;     // LNFT ID
        tasks : Buffer.Buffer<Task>;
        completedTasks : Buffer.Buffer<Task>;
        currentLevel : Nat;    // Affects task availability
        experience : Nat;      // Points earned from completing tasks
    };

    /// Result of task completion attempt
    public type TaskCompletionResult = {
        #Success : {
            task : Task;
            rewards : [Reward];
            experienceGained : Nat;
        };
        #Failure : Text;
        #Requirements : [Text];  // Missing requirements
    };
}