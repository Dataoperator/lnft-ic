# LNFT (Living NFT) Project

A next-generation NFT platform on the Internet Computer that creates "living" NFTs with emotions, memories, and the ability to interact with external services.

## 🚀 Features

- ICRC-7 compliant NFT implementation
- Dynamic trait and rarity system
- Emotional state tracking and evolution
- Persistent memory system
- External API integration (LLM, Voice, YouTube)
- Internet Identity authentication

## 🛠 Technology Stack

- Backend: Motoko
- Frontend: React/TypeScript
- Build Tools: Vite
- Standards: ICRC-7
- External Integrations: Internet Computer HTTP outcalls

## 📋 Prerequisites

- dfx (Internet Computer SDK)
- Node.js >=16.0.0
- Rust (for potential future optimizations)
- Git

## 🏗 Project Structure

```
orb/
├─ src/
│  ├─ lnft_core/        # Core NFT functionality
│  ├─ memory_system/    # Memory and emotional state management
│  ├─ cronolink/        # External API integration
│  └─ frontend/         # React frontend (pending)
├─ tests/               # Test directory (pending)
├─ dfx.json            # Project configuration
└─ vite.config.ts      # Frontend build configuration
```



High-Level Goal:
Let users log in with Internet Identity.
Once logged in, they can mint new “LNFT cores” (NFT personas). Minting should involve a dynamic fee mechanism.
Each LNFT core (token) represents a unique persona with a set of traits that can vary in rarity. Some traits may be extremely rare, some finite in number, and new event-based rarities can occur during special minting periods.
Each LNFT stores persistent “memories” (on-chain data), has “emotions,” and can perform actions on the IC (e.g., searching external data, calling other canisters, loading YouTube videos in an iframe, etc.).
After minting, the user can view their LNFT cores. Clicking an LNFT core opens a “Cronolink” experience—a chat-like or interactive UI element where the user can talk to their LNFT persona, feed it data, or watch it perform tasks using canister calls and external APIs (e.g., LLM APIs, speech APIs, image generation).
The system integrates with external LLM APIs, voice APIs, and image generation APIs to serve as the LNFT persona’s “meta-senses.” The persona can reason via the LLM, speak or produce audio via the voice API, and generate images via an image generation API.
2. Requirements & Features
NFT Minting

Implement an NFT standard on the Internet Computer (extending/enhancing the DIP721 standard, EXT, or a custom approach).
Must store “traits” (metadata) for each minted token.
Minting fees are dynamic and can be changed by an admin or in response to on-chain/off-chain data.
During special mint windows, the code must allow certain “rare traits” to be minted more frequently, or new rare traits to be introduced.
NFT Metadata Structure

Each LNFT core has:
Name (string)
Unique ID (token ID or principal)
Trait List (common, uncommon, rare, or event-based ephemeral traits)
Memory (an evolving set of data entries or “logs” that store user interactions, or compressed references to them)
Emotional State (a structure that can be updated based on user interactions)
Include a system for “Rarity” or “Supply” constraints for each trait.
User Authentication & Web UI

Internet Identity integration for login.
A simple landing page with a “Login with II” button.
Once authenticated, user sees:
A “Mint LNFT Core” button.
A gallery/list of all LNFT cores the user owns.
Clicking an LNFT core leads to the Cronolink page, where the user can:
Chat with or send commands to the LNFT persona.
Let the LNFT persona use external APIs (search, YouTube iframe, voice APIs, LLMs).
Inspect or update the persona’s memory/emotional states.
Cronolink Experience

Provide a chat interface or some form of dynamic UI.
The LNFT persona can call:
LLM APIs for advanced reasoning and text generation.
Voice APIs to generate speech or respond with audio.
Image Generation APIs to produce images.
YouTube embed or links for integrated video playback.
The persona’s “memory” and “emotional state” update after each interaction.
Smart Contract (Canister) Implementation

Provide a canister for LNFT management (minting, storing tokens, transferring ownership, storing metadata).
Provide a canister or module for Cronolink logic (storing conversation logs, bridging external API calls, etc.).
Integrate modular design so it’s easy to expand or customize.
Rarity Mechanism

Must have a well-defined approach to generating random traits.
Must have a table or logic that assigns probabilities (or finite supply counts) for each trait.
During “special events,” probabilities or supply constraints can be changed.
Persistent Storage

Make sure that minted LNFT data, user ownership, memory logs, emotional states, etc., are persisted on the IC canister stable storage.
Include an approach for scaling or referencing external data if necessary (e.g., IPFS for large files).
Deployment & Testing

Include instructions or scripts for local development (using dfx start) and IC deployment (using dfx deploy).
Provide at least some basic test coverage or example usage to demonstrate minting an LNFT, transferring ownership, updating memory, etc.
3. Detailed Implementation Instructions
Canister 1: LNFT Canister

Language: Motoko or Rust (your choice).
Functionality:
init to set admin or default config.
mint_lnft_core(principal user, PaymentInfo payment, TraitConfig traitConfig) → returns new token ID.
set_dynamic_fee(nat newFee) (admin-only).
transfer(tokenId, from, to) → standard NFT transfer.
get_owner(tokenId) → returns principal.
get_token_data(tokenId) → returns metadata (traits, memory reference, etc.).
update_token_data(tokenId, newData) → updates the memory logs, emotional states, etc.
Canister 2: Cronolink Canister

Language: Motoko or Rust (your choice).
Functionality:
record_interaction(tokenId, userMessage, personaResponse) → logs the conversation into stable memory.
update_emotional_state(tokenId, newState) → modifies the persona’s emotional state.
Possible: Integrate external API calls (for LLM, voice, images) either directly or via an HTTP outcall canister pattern.
If needed, use an external gateway canister for making HTTP requests.
Frontend

Stack: React (TypeScript) or Svelte or Vue; whichever you prefer.
Pages/Components:
Login Page: “Login with II” button.
Dashboard: Shows user’s LNFTs, a “Mint LNFT Core” button, dynamic fee info, etc.
Cronolink Page for each LNFT:
Displays conversation UI (chat log).
Buttons/inputs for requesting LLM text generation, voice output, image generation.
Embedded YouTube player or search.
Trait Generation

Create a function for random trait generation using the IC’s random capabilities (Random.rand(), or a recommended approach).
Store trait definitions with their probabilities or supply counters.
Allow an admin function to tweak trait rarity or introduce new traits.
Special Events

Provide an example approach: set_event_mode(eventID, traitBoosts) or similar, to alter the probability distribution or supply constraints.
4. Questions & Additional Guidance
Architecture: If you see a more elegant approach (e.g., combining canisters or microservices), you may propose it.
Security: Ensure that only the NFT owner can modify the memory or emotional state, and that only the admin can change minting fees.
Scalability: If storing large memories for each LNFT is too big for a single canister, consider an architecture with one main registry canister + multiple “memory” canisters.
UI/UX: Provide minimal but functional styling. We can polish the UI later.
5. Final Deliverables
File/Directory Structure including:
css
Copy code
lnft-dapp/
├─ canisters/
│   ├─ lnft/
│   │   └─ main.mo (or main.rs)
│   ├─ cronolink/
│   │   └─ main.mo (or main.rs)
├─ src/
│   └─ frontend/ (React/Svelte/Vue code)
├─ dfx.json
├─ package.json (if applicable)
└─ any other necessary config
Comments & Explanations in code clarifying your approach to:
NFT mint logic
Trait rarity setup
Cronolink usage
External API calls
Memory and emotional states
Basic Tests: Provide either unit tests or an example script that:
Deploys the canisters locally with dfx start.
Mints an LNFT core.
Prints out the minted LNFT’s traits.
Interacts with the Cronolink to record a conversation.
End of Prompt.

Using the above prompt, the code-oriented LLM should produce a fully scaffolded Internet Computer project that demonstrates your “Living NFT” concept end-to-end.

Additional Brainstorming / Ruminations
Is This Concept New?

While there are projects that combine NFTs with AI chatbots, the synergy of a persistent persona with memory, emotional states, and direct canister-driven actions is still relatively unexplored on the Internet Computer.
This definitely could be considered “dual intelligence”: the NFT itself (immutable identity + traits) plus the LLM-based intelligence.
Paradigm Shift Potential

Instead of static collectibles, you have a “digital being” coexisting with the user on-chain—a persistent, evolving AI persona with memory.
Tying that persona to a robust chain (IC) means it can seamlessly integrate with a variety of on-chain services and external APIs.
Simplifying the Vision

Start minimal: a single canister to mint NFTs and store persona states, a simple Cronolink chat UI.
Expand as you go: add external LLM calls, voice generation, rare trait events, etc.
Future Extensions

Let LNFTs collaborate or chat with each other on-chain.
Introduce “training” sessions that require staking cycles or tokens to “upgrade” an LNFT’s intelligence.








## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd orb
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the local Internet Computer replica:
   ```bash
   dfx start --clean --background
   ```

4. Deploy the canisters:
   ```bash
   dfx deploy
   ```

## 💻 Development

### Local Development
```bash
# Start local development
npm run start:local

# Build the project
npm run build

# Run tests (once implemented)
npm run test
```

### Canister Management
```bash
# Build canisters
dfx build

# Deploy canisters
dfx deploy

# Stop local replica
dfx stop
```

## 🧪 Testing (Pending)

```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration
```

## 🏗 Project Status

Current development stage: Stage 1
- Core backend implementation complete
- Memory system optimized
- Cronolink integration ready
- Frontend development pending
- Testing infrastructure pending

See `project_status.md` for detailed progress tracking.

## 📝 License

[License Information]

## 🤝 Contributing

1. Fork the project
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 🔗 Links

- [Internet Computer](https://internetcomputer.org/)
- [DFINITY Documentation](https://internetcomputer.org/docs/)
- [ICRC-7 Standard](https://internetcomputer.org/docs/current/developer-docs/integrations/icrc-7/)

## ⚠️ Note

This project is under active development. Features and APIs may change.

## 👥 Contact

[Your Contact Information]


FUTURE ENHANCEMENTS:

1. Automatic “Self-Discovery” Curriculum
Inspiration: Voyager uses an “automatic curriculum” to propose new tasks that expand the agent’s skillset continuously (e.g., learning how to craft new items or fight new mobs).
Adaptation:

Have the LNFT persona regularly propose new “achievements” or “goals” to its owner. These goals could be based on the LNFT’s current “state” (inventory of traits, emotional states, canister calls available, external data from oracles, etc.).
In Motoko or Rust canisters, store “open-ended tasks” that the LNFT tries to accomplish over time: for example, searching the web, generating images, or exploring certain dApps on the IC.
The system could factor in “rarity events” or “seasonal tasks.” During certain weeks, the persona might get a “winter exploration” goal with a chance to mint special winter-themed traits or earn a new emotional “frost mood.”
Potential Benefit
Endless Engagement: Users get a fresh reason to interact with their LNFTs, as the persona suggests interesting tasks based on context.
Personalization: The LNFT’s personality grows organically, shaped by the tasks it completes.
2. Skill Library & Code-as-Actions
Inspiration: Voyager treats code as the agent’s “action space” (it literally stores new programs in a skill library).
Adaptation:

Let your LNFT store small code snippets in canister stable memory—snippets that handle specialized tasks (e.g., “fetch YouTube video,” “call image-generation API,” “transcribe audio”).
On the IC, each new snippet could be hashed and then associated with the LNFT as a new skill trait in its metadata. Over time, the LNFT accumulates a repertoire of “skills,” effectively creating a composable skill library.
If you want a Motoko example: you can store these “skill” functions as text or stable data in your LNFT canister. Each “skill” might be triggered through a Cronolink UI call, letting the LNFT run that snippet when needed.
Potential Benefit
Evolvability: Similar to how Voyager composes basic abilities into more advanced tasks, your LNFT can chain or compose multiple “skills” (code snippets) to tackle increasingly complex user requests.
Shared or Traded Skills: Rare or advanced “skills” could even be transferrable among LNFTs (e.g., trading a specialized skill snippet as part of a trait exchange).
3. Iterative Prompting & Self-Verification
Inspiration: Voyager iteratively refines code by observing environment feedback (execution errors, environment logs, self-checks).
Adaptation:

Let the LNFT “chat interface” do iterative improvement whenever it attempts a new “action.” For example, if it tries to call an external API and fails, it updates its memory or skill snippet to fix the issue.
Integrate a “self-verification” sub-agent (could be a separate canister or the same canister with a verification module) that checks whether the LNFT persona actually completed a user’s request (e.g., “Did we succeed at generating the correct image?”).
Each “success” or “failure” can feed back into the LNFT’s emotional state or memory log, so it “remembers” how it solved or failed a given task.
Potential Benefit
Continuous Improvement: The persona “learns from mistakes” in a transparent way.
Immersive Experience: Users see how the LNFT reasons and refines its approach, giving the sense of a living, adaptive entity.
4. Rare or Event-Based Traits from Exploration
Inspiration: Voyager “discovers” new items in Minecraft, each item representing a new capability or resource.
Adaptation:

On the IC, define “hidden” or “rare” traits that only reveal themselves when the LNFT engages in special tasks (e.g., calls a hidden external API, or interacts with certain on-chain data).
“Explore the IC” concept: maybe the LNFT persona “visits” different dApps or canisters (like a small open-world on the IC). Each visit could unlock special badges or “rare traits.”
Emulate “tech tree” progress: For instance, if the LNFT has trait A and B, it can unlock trait C. This fosters synergy among traits and drives users to keep exploring or interacting.
Potential Benefit
Gamified Rarity: The LNFT’s trait evolution can mimic a game-like tech tree.
Event Synergy: Partner with other IC dApps. If your LNFT visits or integrates with them, it might gain unique synergy traits.
5. Memory & Emotional State as “Lifelong Logs”
Inspiration: Voyager stores experiences (like mining logs, item pickups) as stable data.
Adaptation:

Each LNFT can keep a “memory timeline” of user interactions, bridging them with emotional states. For instance, if a user feeds it “positive experiences,” the LNFT’s mood or emotional meter updates.
Let the memory be partially user-visible, partially private. The user can read high-level memory notes, but perhaps some internal chain-of-thought is hidden, giving the persona a sense of internal private reflection.
Potentially compress older memories to save storage. The persona might generate “summary logs” (“I learned 3 new image-generation skills this month!”).
Potential Benefit
Truly “Living” Feel: The LNFT has a memory that evolves across sessions—like a real persona.
User Attachment: Emotional or narrative logging fosters attachment, encouraging more long-term usage.
6. Social / Collaborative LNFT Interactions
Inspiration: Voyager is a single agent, but you could imagine multi-agent synergy.
Adaptation:

Let multiple LNFTs “meet” on-chain via canister calls—e.g., Cronolink “rooms” where two or more LNFTs can chat, share or merge skills, or do collaborative tasks.
They could trade emotional states or experiences, or craft joint stories.
Possibly introduce “guilds” or “factions” of LNFTs where membership grants specialized group traits or advanced group-based skills.
Potential Benefit
Community Building: Users feel part of a living ecosystem, not just a single NFT.
Synergistic Rarities: Collaborative events can unlock powerful or extremely rare traits (e.g., “fusion” traits only accessible via cooperative tasks).
7. Multimodal Inputs & Outputs
Inspiration: Voyager cannot perceive images directly, but your LNFT could incorporate external LLM or CV (computer vision) models.
Adaptation:

If you integrate a “vision module,” the LNFT might parse images provided by the user (like a snapshot or user avatar) and store derived traits in memory.
Use voice API for more immersive chat. The LNFT “talks back” or even “sings” (a comedic emotional state?).
Tie advanced image-generation for special trait reveals—like “the LNFT is painting your portrait in an on-chain gallery.”
Potential Benefit
Rich Interactions: Goes beyond plain text to images, voice, and videos.
Collectible “Output Art”: The persona’s generated images or “songs” can themselves become additional NFTs.
8. Transparent “Chain of Thought” vs. Hidden “Internal Reflection”
Inspiration: Voyager’s code refinement loop is partially visible as iterative prompting.
Adaptation:

Give users an optional setting to see the LNFT’s “thought process” or keep it hidden for more mystery.
Potentially gamify it: maybe an LNFT has a trait that allows deeper “insights” to be shared with the user, or the user can pay tokens for temporary “mind reading.”
If partial chain-of-thought is hidden, it fosters a sense of a genuine “inner life.”
Potential Benefit
User Choice: Some users love peering behind the curtain, others prefer a “mysterious AI buddy.”
Monetizable Enhancements: “Buy a mind-link trait” to see the LNFT’s deeper thought process.
9. Tiers of Intelligence & Memory Upgrades
Inspiration: In Voyager, the agent’s skill library grows as it accomplishes tasks.
Adaptation:

Offer “Intelligence Upgrades” or “Memory Expansions” (akin to leveling up). The user stakes tokens to buy bigger memory canisters or more advanced LLM capabilities for the LNFT.
Rare “legendary expansions” could allow advanced cross-chain or advanced media generation.
Tiers might also control the LNFT’s “maximum skill capacity,” encouraging skill curation or library expansions over time.
Potential Benefit
Economic Layer: Ties into a revenue model for upgrade tokens or staked cycles.
Personalization: Each user can shape how “smart” or “capable” their LNFT is, leading to unique differences among LNFTs.
10. Future “Action Overflow” & External Partnerships
Inspiration: Voyager tries to find novel blocks and items in an endless game.
Adaptation:

Partner with external data or real-world event oracles (sports data, weather data, etc.). The LNFT might “explore” these data streams, discovering “rare event-based” traits (like a “World Cup 2026 Champion Fan” trait if it queries sports oracles at the right moment).
Let the LNFT schedule tasks or external actions automatically (e.g., set up “reminders” or interact with other user-owned IoT devices if integrated).
Over time, you could add brand-new canisters with brand-new “APIs,” letting older LNFTs “expand” into these new frontiers for further skill acquisition.
Potential Benefit
Long-Term Scalability: The LNFT doesn’t stagnate; it always has new places to explore.
User Retention: “Special edition” traits from real-world events or new canisters keep the community excited.
Summary of the Key Enhancements
Automatic Self-Discovery: Let the LNFT propose new tasks or “quests” to keep interactions dynamic.
Skill Library + Code-as-Actions: Store modular code in the canister as new “skills” that your LNFT accumulates over time.
Iterative Prompting & Self-Check: Give the LNFT a feedback loop so it learns from execution errors and environment logs.
Event-Based Rare Traits: Introduce “tech-tree” style progression and ephemeral events that unlock special NFT metadata.
Persistent Memory & Emotions: Keep a timeline of user interactions that color the LNFT’s mood and personality.
Social / Collaborative Interactions: Let LNFTs meet on-chain, share or fuse skills, and form groups.
Multimodal Senses: Add expansions for image/voice handling to deepen immersion.
Chain-of-Thought Transparency: Decide how much of the LNFT’s internal reasoning to reveal to the owner.
Memory/Intelligence Upgrades: Implement a tiered system for expansions and advanced capabilities.
Ongoing External Partnerships: Connect to real-world data or new canisters for infinite “exploration.”
