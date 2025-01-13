import { AuthClient } from '@dfinity/auth-client';
import { Actor, Identity } from '@dfinity/agent';
import { canisterId, createActor } from '../declarations/auth';

export class AuthenticationService {
    private authClient: AuthClient | null = null;
    private identity: Identity | null = null;
    private actor: any | null = null;

    async initialize() {
        this.authClient = await AuthClient.create({
            idleOptions: {
                disableDefaultIdleCallback: true,
                disableIdle: false,
                idleTimeout: 1000 * 60 * 30, // 30 minutes
            }
        });

        // Check if we're already authenticated
        if (await this.authClient.isAuthenticated()) {
            this.identity = this.authClient.getIdentity();
            this.actor = createActor(canisterId, {
                agentOptions: {
                    identity: this.identity,
                }
            });
        }
    }

    async login(): Promise<boolean> {
        if (!this.authClient) {
            throw new Error('AuthClient not initialized');
        }

        return new Promise((resolve) => {
            this.authClient!.login({
                identityProvider: process.env.DFX_NETWORK === 'ic' 
                    ? 'https://identity.ic0.app/#authorize'
                    : `http://localhost:4943?canisterId=${process.env.INTERNET_IDENTITY_CANISTER_ID}`,
                onSuccess: async () => {
                    this.identity = this.authClient!.getIdentity();
                    this.actor = createActor(canisterId, {
                        agentOptions: {
                            identity: this.identity,
                        }
                    });
                    resolve(true);
                },
                onError: (error) => {
                    console.error('Login failed:', error);
                    resolve(false);
                },
                // Maximum authorization expiration is 8 days
                maxTimeToLive: BigInt(8) * BigInt(24) * BigInt(3_600_000_000_000), // 8 days in nanoseconds
                derivationOrigin: process.env.DFX_NETWORK === 'ic' 
                    ? 'https://lnft.app'  // Replace with your production domain
                    : 'http://localhost:4943',
            });
        });
    }

    async logout(): Promise<void> {
        if (!this.authClient) {
            throw new Error('AuthClient not initialized');
        }

        await this.authClient.logout();
        this.identity = null;
        this.actor = null;
    }

    getIdentity(): Identity | null {
        return this.identity;
    }

    getActor(): any | null {
        return this.actor;
    }

    isAuthenticated(): Promise<boolean> {
        return this.authClient ? this.authClient.isAuthenticated() : Promise.resolve(false);
    }

    getPrincipal(): string | null {
        return this.identity ? this.identity.getPrincipal().toString() : null;
    }
}