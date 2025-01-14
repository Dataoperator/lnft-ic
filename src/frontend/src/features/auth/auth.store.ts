import { Identity } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { create } from "zustand";
import { actorFactory } from "../../utils/actor-factory";

// Import the canister types
import type { _SERVICE as LNFTCore } from "../../declarations/lnft_core/lnft_core.did";
import { idlFactory } from "../../declarations/lnft_core/lnft_core.did.js";

interface AuthState {
  isInitialized: boolean;
  isAuthenticated: boolean;
  identity: Identity | null;
  principal: string | null;
  actor: LNFTCore | null;
  error: Error | null;
  initialize: () => Promise<void>;
  login: () => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  isInitialized: false,
  isAuthenticated: false,
  identity: null,
  principal: null,
  actor: null,
  error: null,

  initialize: async () => {
    try {
      const authClient = await AuthClient.create();
      const isAuthenticated = await authClient.isAuthenticated();
      
      if (isAuthenticated) {
        const identity = authClient.getIdentity();
        const actor = await actorFactory.createActor<LNFTCore>({
          canisterId: process.env.VITE_LNFT_CORE_CANISTER_ID!,
          idlFactory,
          identity
        });

        set({
          isAuthenticated: true,
          identity,
          principal: identity.getPrincipal().toString(),
          actor,
          error: null,
        });
      }

      set({ isInitialized: true });
    } catch (error) {
      console.error('Auth initialization error:', error);
      set({ error: error as Error });
    }
  },

  login: async () => {
    try {
      const authClient = await AuthClient.create();
      
      await new Promise<void>((resolve, reject) => {
        authClient.login({
          identityProvider: process.env.VITE_DFX_NETWORK === "ic" 
            ? "https://identity.ic0.app" 
            : process.env.VITE_INTERNET_IDENTITY_URL,
          onSuccess: () => resolve(),
          onError: reject,
        });
      });

      const identity = authClient.getIdentity();
      const actor = await actorFactory.createActor<LNFTCore>({
        canisterId: process.env.VITE_LNFT_CORE_CANISTER_ID!,
        idlFactory,
        identity
      });

      set({
        isAuthenticated: true,
        identity,
        principal: identity.getPrincipal().toString(),
        actor,
        error: null,
      });
    } catch (error) {
      console.error('Login error:', error);
      set({ error: error as Error });
    }
  },

  logout: async () => {
    try {
      const authClient = await AuthClient.create();
      await authClient.logout();

      set({
        isAuthenticated: false,
        identity: null,
        principal: null,
        actor: null,
        error: null,
      });
    } catch (error) {
      console.error('Logout error:', error);
      set({ error: error as Error });
    }
  },
}));