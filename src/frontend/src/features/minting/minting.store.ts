import { create } from 'zustand';
import { useAuthStore } from '../auth/auth.store';
import { Trait, TraitType, Rarity } from '../../types/canister';
import { _SERVICE } from '../../../../declarations/lnft_core/lnft_core.did';
import { createActor } from '../../../../declarations/lnft_core';

interface MintingState {
  isLoading: boolean;
  error: string | null;
  currentPrice: bigint;
  traits: Trait[];
  selectedTraits: string[];
  name: string;
  mint: (name: string, traits: string[]) => Promise<string>;
  setName: (name: string) => void;
  setSelectedTraits: (traits: string[]) => void;
  fetchCurrentPrice: () => Promise<void>;
  fetchAvailableTraits: () => Promise<void>;
  reset: () => void;
}

const DEFAULT_STATE = {
  isLoading: false,
  error: null,
  currentPrice: BigInt(0),
  traits: [],
  selectedTraits: [],
  name: ''
};

export const useMintingStore = create<MintingState>((set, get) => ({
  ...DEFAULT_STATE,

  setName: (name: string) => set({ name }),
  
  setSelectedTraits: (selectedTraits: string[]) => set({ selectedTraits }),

  reset: () => set(DEFAULT_STATE),

  mint: async (name: string, traitIds: string[]) => {
    set({ isLoading: true, error: null });
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Neural link not established');

      const actor = createActor(process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const result = await actor.mint({
        name,
        traitIds
      });

      if ('Err' in result) {
        throw new Error(result.Err);
      }

      set({ isLoading: false });
      return result.Ok;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Entity generation failed';
      set({
        error: errorMessage,
        isLoading: false
      });
      throw new Error(errorMessage);
    }
  },

  fetchCurrentPrice: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Neural link not established');

      const actor = createActor(process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const price = await actor.getCurrentPrice();
      set({ currentPrice: price });
    } catch (error) {
      set({ 
        error: error instanceof Error 
          ? error.message 
          : 'Failed to retrieve entity generation cost' 
      });
    }
  },

  fetchAvailableTraits: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Neural link not established');

      const actor = createActor(process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const traits = await actor.getAvailableTraits();
      set({ traits });
    } catch (error) {
      set({ 
        error: error instanceof Error 
          ? error.message 
          : 'Failed to retrieve available traits' 
      });
    }
  }
}));