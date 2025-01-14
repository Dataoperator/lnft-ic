import { AuthClient } from '@dfinity/auth-client';
import { Identity } from '@dfinity/agent';
import { createStore } from '../../utils/store-factory';
import { canisterId } from '../../declarations/auth';

export class AuthStore {
  private static instance: AuthStore;
  private authClient: AuthClient | null = null;
  private identity: Identity | null = null;

  private constructor() {}

  static getInstance(): AuthStore {
    if (!AuthStore.instance) {
      AuthStore.instance = new AuthStore();
    }
    return AuthStore.instance;
  }

  async initialize(): Promise<void> {
    this.authClient = await AuthClient.create();
    const isAuthenticated = await this.authClient.isAuthenticated();
    
    if (isAuthenticated) {
      this.identity = this.authClient.getIdentity();
      this.saveIdentityToStorage(this.identity);
    }
  }

  async login(): Promise<boolean> {
    if (!this.authClient) {
      throw new Error('AuthClient not initialized');
    }

    const days = BigInt(1);
    const hours = BigInt(24);
    const nanoseconds = BigInt(3600000000000);

    try {
      const success = await this.authClient.login({
        identityProvider: process.env.DFX_NETWORK === 'ic' 
          ? 'https://identity.ic0.app'
          : `http://localhost:4943?canisterId=${canisterId}`,
        maxTimeToLive: days * hours * nanoseconds,
        onSuccess: () => {
          this.identity = this.authClient!.getIdentity();
          this.saveIdentityToStorage(this.identity);
        },
      });

      return success;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  }

  async logout(): Promise<void> {
    if (!this.authClient) {
      throw new Error('AuthClient not initialized');
    }

    await this.authClient.logout();
    this.identity = null;
    localStorage.removeItem('identity');
  }

  getIdentity(): Identity | null {
    return this.identity;
  }

  isAuthenticated(): boolean {
    return !!this.identity;
  }

  private saveIdentityToStorage(identity: Identity): void {
    try {
      localStorage.setItem('identity', JSON.stringify({
        type: 'Internet Identity',
        principal: identity.getPrincipal().toString(),
      }));
    } catch (error) {
      console.error('Error saving identity to storage:', error);
    }
  }
}

// Create and export a singleton instance
export const authStore = AuthStore.getInstance();