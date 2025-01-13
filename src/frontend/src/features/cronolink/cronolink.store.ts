import { create } from 'zustand';
import { Actor } from '@dfinity/agent';
import { useAuthStore } from '../auth/auth.store';
import { Memory, EmotionalState } from '../../types';

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
}

export const useCronolinkStore = create<CronolinkState>((set, get) => ({
  isLoading: false,
  error: null,
  messages: [],
  currentEmotionalState: null,
  memories: [],

  sendMessage: async (lnftId: string, content: string) => {
    set({ isLoading: true, error: null });
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<any>(
        process.env.CRONOLINK_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      // Add user message to chat
      const userMessage: Message = {
        id: crypto.randomUUID(),
        content,
        sender: 'user',
        timestamp: Date.now()
      };
      set(state => ({ messages: [...state.messages, userMessage] }));

      // Get LNFT response
      const response = await actor.processMessage({
        lnftId,
        message: content
      });

      // Add LNFT response to chat
      const lnftMessage: Message = {
        id: crypto.randomUUID(),
        content: response.content,
        sender: 'lnft',
        timestamp: Date.now(),
        emotionalState: response.emotionalState
      };
      set(state => ({ 
        messages: [...state.messages, lnftMessage],
        currentEmotionalState: response.emotionalState,
        isLoading: false
      }));

    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to send message',
        isLoading: false
      });
    }
  },

  fetchMemories: async (lnftId: string) => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<any>(
        process.env.CRONOLINK_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      const memories = await actor.getMemories(lnftId);
      set({ memories });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch memories' });
    }
  },

  fetchEmotionalState: async (lnftId: string) => {
    try {
      const authStore = useAuthStore.getState();
      if (!authStore.identity) throw new Error('Not authenticated');

      const actor = Actor.createActor<any>(
        process.env.CRONOLINK_CANISTER_ID as string,
        {
          agentOptions: {
            identity: authStore.identity,
            host: process.env.IC_HOST
          }
        }
      );

      const emotionalState = await actor.getCurrentEmotionalState(lnftId);
      set({ currentEmotionalState: emotionalState });
    } catch (error) {
      set({ error: error instanceof Error ? error.message : 'Failed to fetch emotional state' });
    }
  },

  clearChat: () => {
    set({ messages: [], currentEmotionalState: null });
  }
}));