import { create } from 'zustand';
import { useAuthStore } from '../auth/auth.store';
import { Memory, EmotionalState } from '../../types/canister';
import { _SERVICE } from '../../../../declarations/cronolink/cronolink.did';
import { createActor } from '../../../../declarations/cronolink';

interface Message {
  id: string;
  content: string;
  sender: 'user' | 'lnft';
  timestamp: number;
  emotionalState?: EmotionalState;
}

interface CronolinkState {
  isLoading: boolean;
  error: string | null;
  messages: Message[];
  currentEmotionalState: EmotionalState | null;
  memories: Memory[];
  sendMessage: (lnftId: string, content: string) => Promise<void>;
  fetchMemories: (lnftId: string) => Promise<void>;
  fetchEmotionalState: (lnftId: string) => Promise<void>;
  clearChat: () => void;
  setError: (error: string | null) => void;
}

export const useCronolinkStore = create<CronolinkState>((set, get) => ({
  isLoading: false,
  error: null,
  messages: [],
  currentEmotionalState: null,
  memories: [],

  setError: (error: string | null) => set({ error }),

  sendMessage: async (lnftId: string, content: string) => {
    set({ isLoading: true, error: null });
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) {
        throw new Error('Neural link not established');
      }

      // Create actor with authentication
      const actor = createActor(process.env.VITE_CRONOLINK_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      // Add user message to chat immediately for better UX
      const userMessage: Message = {
        id: crypto.randomUUID(),
        content,
        sender: 'user',
        timestamp: Date.now()
      };
      set(state => ({ messages: [...state.messages, userMessage] }));

      // Process message through the canister
      const result = await actor.processMessage({
        lnftId,
        message: content
      });

      if ('Err' in result) {
        throw new Error(result.Err);
      }

      const { response, emotionalUpdate, newMemory } = result.Ok;

      // Add LNFT response to chat
      const lnftMessage: Message = {
        id: crypto.randomUUID(),
        content: response,
        sender: 'lnft',
        timestamp: Date.now(),
        emotionalState: emotionalUpdate
      };

      set(state => ({ 
        messages: [...state.messages, lnftMessage],
        currentEmotionalState: emotionalUpdate || state.currentEmotionalState,
        memories: newMemory ? [newMemory, ...state.memories] : state.memories,
        isLoading: false
      }));

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Neural link communication failed';
      set({ 
        error: errorMessage,
        isLoading: false
      });
      throw error; // Re-throw for UI handling
    }
  },

  fetchMemories: async (lnftId: string) => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) {
        throw new Error('Neural link not established');
      }

      const actor = createActor(process.env.VITE_CRONOLINK_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const memories = await actor.getMemories(lnftId);
      set({ memories });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to retrieve memories';
      set({ error: errorMessage });
      throw error;
    }
  },

  fetchEmotionalState: async (lnftId: string) => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) {
        throw new Error('Neural link not established');
      }

      const actor = createActor(process.env.VITE_CRONOLINK_CANISTER_ID!, {
        agentOptions: {
          identity: authStore.identity,
          host: process.env.VITE_IC_HOST
        }
      });

      const emotionalState = await actor.getCurrentEmotionalState(lnftId);
      set({ currentEmotionalState: emotionalState });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to retrieve emotional state';
      set({ error: errorMessage });
      throw error;
    }
  },

  clearChat: () => {
    set({ 
      messages: [], 
      currentEmotionalState: null,
      error: null 
    });
  }
}));