import { create } from 'zustand';
import { AuthClient } from '@dfinity/auth-client';
import { Identity } from '@dfinity/agent';

interface AuthState {
  isAuthenticated: boolean;
  identity: Identity | null;
  principal: string | null;
  isInitializing: boolean;
  authClient: AuthClient | null;
  login: () => Promise<void>;
  logout: () => Promise<void>;
  initialize: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  isAuthenticated: false,
  identity: null,
  principal: null,
  isInitializing: true,
  authClient: null,

  initialize: async () => {
    try {
      const authClient = await AuthClient.create();
      const isAuthenticated = await authClient.isAuthenticated();
      
      set({
        authClient,
        isAuthenticated,
        isInitializing: false,
        identity: isAuthenticated ? authClient.getIdentity() : null,
        principal: isAuthenticated ? authClient.getIdentity().getPrincipal().toString() : null,
      });
    } catch (error) {
      console.error('Failed to initialize auth client:', error);
      set({ isInitializing: false });
    }
  },

  login: async () => {
    const { authClient } = get();
    if (!authClient) return;

    try {
      await new Promise<void>((resolve, reject) => {
        authClient.login({
          identityProvider: process.env.DFX_NETWORK === 'ic' 
            ? 'https://identity.ic0.app'
            : `http://localhost:4943/?canisterId=${process.env.INTERNET_IDENTITY_CANISTER_ID}`,
          onSuccess: () => {
            const identity = authClient.getIdentity();
            set({
              isAuthenticated: true,
              identity,
              principal: identity.getPrincipal().toString(),
            });
            resolve();
          },
          onError: reject,
        });
      });
    } catch (error) {
      console.error('Login failed:', error);
    }
  },

  logout: async () => {
    const { authClient } = get();
    if (!authClient) return;

    await authClient.logout();
    set({
      isAuthenticated: false,
      identity: null,
      principal: null,
    });
  },
}));