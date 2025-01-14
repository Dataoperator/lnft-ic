import type { Identity } from '@dfinity/agent';
import { createStore } from '../../utils/store-factory';
import { EmotionalState, Memory, _SERVICE } from '../../types/canister';
import { canisterId } from '../../declarations/cronolink';

export class CronolinkStore {
  private actor: _SERVICE | null = null;
  private identity: Identity | undefined;

  constructor() {
    this.initialize();
  }

  private async initialize() {
    this.identity = this.getStoredIdentity();
    this.actor = await createStore(canisterId, this.identity);
  }

  private getStoredIdentity(): Identity | undefined {
    try {
      const authStore = localStorage.getItem('authStore');
      if (authStore) {
        const { identity } = JSON.parse(authStore);
        return identity;
      }
    } catch (error) {
      console.error('Error retrieving identity:', error);
    }
    return undefined;
  }

  async processMessage(lnftId: string, message: string): Promise<{
    response: string;
    emotionalUpdate?: EmotionalState;
    newMemory?: Memory;
  }> {
    try {
      if (!this.actor) throw new Error('Actor not initialized');

      const result = await this.actor.processMessage({
        lnftId,
        message,
      });

      if ('Ok' in result) {
        return result.Ok;
      } else {
        throw new Error(result.Err);
      }
    } catch (error) {
      console.error('Error processing message:', error);
      throw error;
    }
  }

  async getMemories(lnftId: string): Promise<Memory[]> {
    try {
      if (!this.actor) throw new Error('Actor not initialized');
      return await this.actor.getMemories(lnftId);
    } catch (error) {
      console.error('Error getting memories:', error);
      throw error;
    }
  }

  async getCurrentEmotionalState(lnftId: string): Promise<EmotionalState> {
    try {
      if (!this.actor) throw new Error('Actor not initialized');
      return await this.actor.getCurrentEmotionalState(lnftId);
    } catch (error) {
      console.error('Error getting emotional state:', error);
      throw error;
    }
  }
}