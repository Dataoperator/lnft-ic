/// LNFT Curriculum System Implementation
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Types "./Types";
import Debug "mo:base/Debug";

actor class CurriculumSystem() {
    type Task = Types.Task;
    type Curriculum = Types.Curriculum;
    type TaskCompletionResult = Types.TaskCompletionResult;
    type Reward = Types.Reward;

    /// Stable storage for curricula
    private stable var curricula : [(Principal, Curriculum)] = [];
    
    /// Runtime buffer for active curricula
    private var activeCurricula = Buffer.Buffer<(Principal, Curriculum)>(0);

    /// Initialize a new curriculum for an LNFT
    public shared(msg) func initializeCurriculum() : async Result.Result<Curriculum, Text> {
        let owner = msg.caller;
        
        switch (getCurriculum(owner)) {
            case (?existing) {
                #err("Curriculum already exists for this LNFT");
            };
            case null {
                let newCurriculum : Curriculum = {
                    owner = owner;
                    tasks = Buffer.Buffer<Task>(10);
                    completedTasks = Buffer.Buffer<Task>(10);
                    currentLevel = 1;
                    experience = 0;
                };
                
                activeCurricula.add((owner, newCurriculum));
                
                // Generate initial tasks
                await generateTasks(owner);
                
                #ok(newCurriculum);
            };
        };
    };

    /// Start a task
    public shared(msg) func startTask(taskId : Text) : async Result.Result<Task, Text> {
        let owner = msg.caller;
        
        switch (getCurriculum(owner)) {
            case (?curriculum) {
                switch (findTask(curriculum, taskId)) {
                    case (?task) {
                        if (task.status == #Available) {
                            let updatedTask = {
                                task with
                                status = #InProgress;
                            };
                            updateTask(curriculum, updatedTask);
                            #ok(updatedTask);
                        } else {
                            #err("Task is not available");
                        };
                    };
                    case null {
                        #err("Task not found");
                    };
                };
            };
            case null {
                #err("No curriculum found for this LNFT");
            };
        };
    };

    /// Complete a task
    public shared(msg) func completeTask(taskId : Text) : async TaskCompletionResult {
        let owner = msg.caller;
        
        switch (getCurriculum(owner)) {
            case (?curriculum) {
                switch (findTask(curriculum, taskId)) {
                    case (?task) {
                        if (task.status == #InProgress) {
                            // Check requirements
                            let missingReqs = checkRequirements(curriculum, task.requirements);
                            if (missingReqs.size() > 0) {
                                return #Requirements(missingReqs);
                            };

                            // Calculate experience gained
                            let expGained = calculateExperience(task);

                            // Update task status and move to completed
                            let completedTask = {
                                task with
                                status = #Completed;
                            };
                            curriculum.tasks.filterEntries(func(i, t) = t.id != taskId);
                            curriculum.completedTasks.add(completedTask);
                            
                            // Update curriculum
                            let updatedCurriculum = {
                                curriculum with
                                experience = curriculum.experience + expGained;
                            };
                            updateCurriculum(owner, updatedCurriculum);

                            // Generate new tasks if needed
                            await generateTasks(owner);

                            #Success({
                                task = completedTask;
                                rewards = task.rewards;
                                experienceGained = expGained;
                            });
                        } else {
                            #Failure("Task is not in progress");
                        };
                    };
                    case null {
                        #Failure("Task not found");
                    };
                };
            };
            case null {
                #Failure("No curriculum found for this LNFT");
            };
        };
    };

    /// Generate new tasks based on LNFT's level and completed tasks
    private func generateTasks(owner : Principal) : async () {
        switch (getCurriculum(owner)) {
            case (?curriculum) {
                let currentTasks = curriculum.tasks.size();
                if (currentTasks < 5) {  // Maintain at least 5 available tasks
                    let tasksNeeded = 5 - currentTasks;
                    let newTasks = generateTasksForLevel(curriculum.currentLevel, tasksNeeded);
                    for (task in newTasks.vals()) {
                        curriculum.tasks.add(task);
                    };
                    updateCurriculum(owner, curriculum);
                };
            };
            case null {};
        };
    };

    /// Generate appropriate tasks for the current level
    private func generateTasksForLevel(level : Nat, count : Nat) : [Task] {
        // This would contain logic to generate level-appropriate tasks
        // For now, we'll return placeholder tasks
        var tasks = Buffer.Buffer<Task>(count);
        for (i in Iter.range(0, count - 1)) {
            let task : Task = {
                id = Int.toText(Time.now()) # "_" # Int.toText(i);
                title = "Level " # Nat.toText(level) # " Task " # Int.toText(i);
                description = "Auto-generated task for level " # Nat.toText(level);
                category = #Exploration;
                difficulty = #Beginner;
                requirements = [];
                rewards = [#Experience(100 * level)];
                deadline = null;
                status = #Available;
            };
            tasks.add(task);
        };
        Buffer.toArray(tasks);
    };

    /// Helper functions
    private func getCurriculum(owner : Principal) : ?Curriculum {
        for ((currOwner, curr) in activeCurricula.vals()) {
            if (currOwner == owner) {
                return ?curr;
            };
        };
        null;
    };

    private func updateCurriculum(owner : Principal, curriculum : Curriculum) {
        var index = 0;
        for ((currOwner, _) in activeCurricula.vals()) {
            if (currOwner == owner) {
                activeCurricula.put(index, (owner, curriculum));
                return;
            };
            index += 1;
        };
    };

    private func findTask(curriculum : Curriculum, taskId : Text) : ?Task {
        for (task in curriculum.tasks.vals()) {
            if (task.id == taskId) {
                return ?task;
            };
        };
        null;
    };

    private func checkRequirements(curriculum : Curriculum, required : [Text]) : [Text] {
        var missing = Buffer.Buffer<Text>(0);
        for (reqId in required.vals()) {
            var found = false;
            for (task in curriculum.completedTasks.vals()) {
                if (task.id == reqId) {
                    found := true;
                    break;
                };
            };
            if (not found) {
                missing.add(reqId);
            };
        };
        Buffer.toArray(missing);
    };

    private func calculateExperience(task : Task) : Nat {
        // This would contain more complex logic based on task difficulty
        // For now, return a basic amount
        switch (task.difficulty) {
            case (#Beginner) 100;
            case (#Intermediate) 250;
            case (#Advanced) 500;
            case (#Expert) 1000;
        };
    };

    /// System hooks
    system func preupgrade() {
        curricula := Buffer.toArray(activeCurricula);
    };

    system func postupgrade() {
        activeCurricula := Buffer.fromArray(curricula);
        curricula := [];
    };
}