# LNFT (Living NFT) Project

A next-generation NFT platform on the Internet Computer that creates "living" NFTs with emotions, memories, and the ability to interact with external services. Each NFT is a unique digital entity capable of evolving through interactions, storing memories, and expressing emotions.

## 🌟 Core Features

- **ICRC-7 Compliance**: Full implementation of the Internet Computer NFT standard
- **Dynamic Traits**: Evolving trait system with rarity mechanics
- **Emotional State**: NFTs maintain and evolve emotional states based on interactions
- **Memory System**: Persistent on-chain memory storage for interactions and experiences
- **External Integration**: Seamless integration with LLM, Voice, and YouTube services
- **Internet Identity**: Secure authentication using Internet Computer's Identity system

## 🛠 Technology Stack

### Backend
- Motoko (Internet Computer's native language)
- ICRC-7 NFT Standard
- Internet Computer HTTP outcalls
- Stable storage patterns

### Frontend
- React 18
- TypeScript
- Vite
- TailwindCSS
- Internet Computer JS Agent

## 🔧 System Architecture

```
Backend:
├─ LNFT Core (ICRC-7)
│  ├─ Token management
│  └─ Memory system
├─ Authentication
│  └─ Internet Identity
├─ Cronolink
│  ├─ Chat system
│  └─ API integration
└─ Types
   └─ Shared declarations

Frontend:
├─ src/
│  ├─ features/
│  │  ├─ auth/
│  │  ├─ minting/
│  │  └─ cronolink/
│  ├─ components/
│  └─ declarations/
```

## 📋 Prerequisites

- dfx (Internet Computer SDK) >= 0.14.1
- Node.js >= 16.0.0
- npm >= 8.0.0
- Vessel package manager (for Motoko dependencies)

## 🚀 Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/Dataoperator/lnft-ic.git
   cd lnft-ic
   ```

2. Install dependencies:
   ```bash
   npm install
   dfx start --clean --background
   ```

3. Deploy locally:
   ```bash
   dfx deploy
   ```

## 💻 Development

### Local Development
```bash
# Start the local replica
dfx start --clean --background

# Deploy all canisters
dfx deploy

# Start frontend development server
npm run dev
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

## 🔐 Security Features

- Secure authentication with Internet Identity
- Rate limiting for API calls
- Proper session management
- Cross-canister call security

## 🌐 External Integrations

- LLM Integration for advanced reasoning
- Voice synthesis capabilities
- YouTube embed support
- Image generation support (planned)

## 📦 Current Status

- ✅ Core Backend Implementation
- ✅ ICRC-7 Compliance
- ✅ Authentication System
- ✅ Memory System
- ✅ External API Integration
- 🟡 Frontend Development (In Progress)
- 🟡 Testing Suite (In Progress)
- ❌ Production Deployment

## 🗺 Roadmap

1. Complete Frontend Implementation
2. Implement Testing Suite
3. Production Deployment
4. Community Features
5. Enhanced AI Integration

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- [Internet Computer Documentation](https://internetcomputer.org/docs/)
- [ICRC-7 Standard](https://internetcomputer.org/docs/current/developer-docs/integrations/icrc-7/)
- [Motoko Documentation](https://internetcomputer.org/docs/current/developer-docs/build/languages/motoko/)
- [DFX Documentation](https://internetcomputer.org/docs/current/references/cli-reference/dfx-parent/)

## ⚠️ Note

This project is under active development. Features and APIs may change.