import type { Identity } from '@dfinity/agent';
import { createStore } from '../../utils/store-factory';
import { Trait, _SERVICE } from '../../types/canister';
import { canisterId } from '../../declarations/lnft_core';

export class MintingStore {
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

  async mintLNFT(name: string, selectedTraits: Trait[]) {
    try {
      if (!this.actor) throw new Error('Actor not initialized');

      const result = await this.actor.mint({
        name,
        traits: selectedTraits,
      });

      if ('Ok' in result) {
        return { success: true, tokenId: result.Ok };
      } else {
        throw new Error(result.Err);
      }
    } catch (error) {
      console.error('Error minting LNFT:', error);
      throw error;
    }
  }

  async getCurrentPrice(): Promise<bigint> {
    try {
      if (!this.actor) throw new Error('Actor not initialized');
      return await this.actor.getCurrentPrice();
    } catch (error) {
      console.error('Error getting current price:', error);
      throw error;
    }
  }

  async getAvailableTraits(): Promise<Trait[]> {
    try {
      if (!this.actor) throw new Error('Actor not initialized');
      return await this.actor.getAvailableTraits();
    } catch (error) {
      console.error('Error getting available traits:', error);
      throw error;
    }
  }
}