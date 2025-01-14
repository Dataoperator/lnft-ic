import { create } from 'zustand';
import { useAuthStore } from '../auth/auth.store';
import { Trait } from '../../types';
import { createCanisterActor } from '../../types/canister';
import { _SERVICE } from '../../../../declarations/lnft_core/lnft_core.did';
import { createActor } from '../../../../declarations/lnft_core';

interface MintingState {
  isLoading: boolean;
  error: string | null;
  currentPrice: bigint;
  traits: Trait[];
  mint: (name: string, traitIds: string[]) => Promise<void>;
  fetchCurrentPrice: () => Promise<void>;
  fetchAvailableTraits: () => Promise<void>;
}

export const useMintingStore = create<MintingState>((set) => ({
  isLoading: false,
  error: null,
  currentPrice: BigInt(0),
  traits: [],

  mint: async (name: string, traitIds: string[]) => {
    set({ isLoading: true, error: null });
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = createCanisterActor<_SERVICE>({
        createActor
      }, process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      await actor.mint({
        name,
        traitIds
      });

      set({ isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to mint LNFT',
        isLoading: false
      });
    }
  },

  fetchCurrentPrice: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = createCanisterActor<_SERVICE>({
        createActor
      }, process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const price = await actor.getCurrentPrice();
      set({ currentPrice: price });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch price' });
    }
  },

  fetchAvailableTraits: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = createCanisterActor<_SERVICE>({
        createActor
      }, process.env.VITE_LNFT_CORE_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const traits = await actor.getAvailableTraits();
      set({ traits });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch traits' });
    }
  }
}));