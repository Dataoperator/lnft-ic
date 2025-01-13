import { create } from 'zustand';
import { Actor, ActorSubclass } from '@dfinity/agent';
import { useAuthStore } from '../auth/auth.store';
import { LNFT, Trait } from '../../types';
import { _SERVICE } from '../../declarations/lnft_core/lnft_core.did';

interface MintingState {
  isLoading: boolean;
  error: string | null;
  currentPrice: bigint;
  traits: Trait[];
  mint: (name: string, selectedTraits: string[]) => Promise<string>;
  fetchCurrentPrice: () => Promise<void>;
  fetchAvailableTraits: () => Promise<void>;
}

export const useMintingStore = create<MintingState>((set, get) => ({
  isLoading: false,
  error: null,
  currentPrice: BigInt(0),
  traits: [],

  mint: async (name: string, selectedTraits: string[]) => {
    set({ isLoading: true, error: null });
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<_SERVICE>(
        process.env.LNFT_CORE_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      const result = await actor.mint({
        name,
        traits: selectedTraits,
        payment: { amount: get().currentPrice }
      });

      set({ isLoading: false });
      return result.ok ? result.ok : Promise.reject(result.err);
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to mint LNFT', isLoading: false });
      throw error;
    }
  },

  fetchCurrentPrice: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<_SERVICE>(
        process.env.LNFT_CORE_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      const price = await actor.getCurrentMintingFee();
      set({ currentPrice: price });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch price' });
    }
  },

  fetchAvailableTraits: async () => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<_SERVICE>(
        process.env.LNFT_CORE_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      const traits = await actor.getAvailableTraits();
      set({ traits: traits.map(t => ({
        id: t.id,
        name: t.name,
        rarity: t.rarity,
        type: t.type
      })) });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch traits' });
    }
  }
}));