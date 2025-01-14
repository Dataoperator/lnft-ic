import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";

module {
    // Enhanced LNFT Type
    public type LNFT = {
        id: TokenId;
        owner: Principal;
        name: Text;
        description: Text;
        created: Time.Time;
        lastInteraction: Time.Time;
        neuralState: NeuralState;
        emotionalState: EmotionalState;
        traits: [Trait];
        skills: [Skill];
        memories: [Memory];
        socialBonds: [SocialBond];
        metadata: Metadata;
    };

    // Neural System Types
    public type NeuralState = {
        activityMap: [(Text, Float)];  // Neural region activations
        pathStrengths: [(Text, Float)]; // Neural pathway strengths
        lastUpdate: Time.Time;
        emotionalInfluence: EmotionalState;
        memoryIndex: [Text];  // Active memory references
        traitInfluence: [TraitInfluence];
    };

    public type NeuralInput = {
        stimulusType: StimulusType;
        content: Text;
        intensity: Float;
        context: ?Context;
    };

    public type StimulusType = {
        #Sensory;
        #Emotional;
        #Cognitive;
        #Social;
        #Environmental;
    };

    // Enhanced Emotional System
    public type EmotionalState = {
        joy: Float;
        trust: Float;
        fear: Float;
        surprise: Float;
        sadness: Float;
        disgust: Float;
        anger: Float;
        anticipation: Float;
        valence: Float;  // Overall emotional tone
        arousal: Float;  // Emotional intensity
        dominance: Float; // Sense of control
    };

    // Enhanced Memory System
    public type Memory = {
        id: MemoryId;
        created: Time.Time;
        lastAccessed: Time.Time;
        content: MemoryContent;
        emotionalContext: EmotionalState;
        strength: Float;
        connections: [MemoryConnection];
        tags: [Text];
    };

    public type MemoryContent = {
        #Experience: ExperienceMemory;
        #Knowledge: KnowledgeMemory;
        #Social: SocialMemory;
    };

    public type MemoryConnection = {
        targetId: MemoryId;
        strength: Float;
        type: ConnectionType;
        formed: Time.Time;
    };

    // Enhanced Trait System
    public type Trait = {
        id: TraitId;
        name: Text;
        category: TraitCategory;
        level: Float;
        potential: Float;
        evolution: TraitEvolution;
        influences: [TraitInfluence];
    };

    public type TraitCategory = {
        #Personality;
        #Ability;
        #Preference;
        #Specialty;
    };

    public type TraitEvolution = {
        history: Buffer.Buffer<EvolutionEvent>;
        rate: Float;
        direction: Float;
        stability: Float;
    };

    public type TraitInfluence = {
        sourceId: Text;
        weight: Float;
        type: InfluenceType;
    };

    // Enhanced Social System
    public type SocialBond = {
        targetId: TokenId;
        strength: Float;
        formed: Time.Time;
        lastInteraction: Time.Time;
        type: BondType;
        history: Buffer.Buffer<SocialInteraction>;
        emotionalContext: EmotionalState;
    };

    public type SocialInteraction = {
        timestamp: Time.Time;
        type: InteractionType;
        content: Text;
        emotionalImpact: EmotionalState;
        outcome: InteractionOutcome;
    };

    public type BondType = {
        #Friendship;
        #Mentorship;
        #Rivalry;
        #Alliance;
    };

    // Event System
    public type Event = {
        id: Text;
        timestamp: Time.Time;
        category: EventCategory;
        data: EventData;
        impact: EventImpact;
    };

    public type EventCategory = {
        #Neural;
        #Emotional;
        #Memory;
        #Trait;
        #Social;
        #System;
    };

    public type EventImpact = {
        neuralChange: ?NeuralChange;
        emotionalChange: ?EmotionalChange;
        traitChange: ?TraitChange;
        socialChange: ?SocialChange;
    };

    // Helper Types
    public type Context = {
        environment: ?Text;
        participants: ?[TokenId];
        triggers: ?[Text];
        metadata: ?[(Text, Text)];
    };

    public type Metadata = {
        version: Text;
        created: Time.Time;
        updated: Time.Time;
        attributes: [(Text, Text)];
    };

    // Type Aliases
    public type TokenId = Text;
    public type TraitId = Text;
    public type SkillId = Text;
    public type MemoryId = Text;

    // Additional Type Definitions
    public type InteractionType = {
        #Collaborate;
        #Compete;
        #Learn;
        #Teach;
        #Support;
        #Challenge;
    };

    public type InteractionOutcome = {
        success: Bool;
        impact: Float;
        details: Text;
    };

    public type ConnectionType = {
        #Temporal;
        #Causal;
        #Semantic;
        #Emotional;
    };

    public type InfluenceType = {
        #Direct;
        #Indirect;
        #Catalytic;
        #Inhibitory;
    };

    public type ExperienceMemory = {
        event: Text;
        location: ?Text;
        participants: [TokenId];
        outcome: Text;
    };

    public type KnowledgeMemory = {
        concept: Text;
        relationships: [Text];
        confidence: Float;
        source: Text;
    };

    public type SocialMemory = {
        interaction: SocialInteraction;
        relationship: Text;
        impact: Float;
    };

    public type NeuralChange = {
        regions: [(Text, Float)];
        pathways: [(Text, Float)];
    };

    public type EmotionalChange = {
        before: EmotionalState;
        after: EmotionalState;
        trigger: Text;
    };

    public type TraitChange = {
        traitId: TraitId;
        oldValue: Float;
        newValue: Float;
        cause: Text;
    };

    public type SocialChange = {
        bondId: Text;
        changeType: Text;
        magnitude: Float;
    };

    public type Error = {
        #Unauthorized;
        #InvalidToken;
        #InvalidRequest;
        #NotFound;
        #AlreadyExists;
        #SystemError;
        #Custom: Text;
    };
};