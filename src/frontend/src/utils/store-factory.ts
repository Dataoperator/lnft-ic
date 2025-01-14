import { HttpAgent, Actor, Identity } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { idlFactory as lnftIdlFactory } from '../../../declarations/lnft_core/lnft_core.did.js';
import { idlFactory as cronolinkIdlFactory } from '../../../declarations/cronolink/cronolink.did.js';
import type { _SERVICE as LNFTService } from '../../../declarations/lnft_core/lnft_core.did.js';
import type { _SERVICE as CronolinkService } from '../../../declarations/cronolink/cronolink.did.js';

export type CanisterService = LNFTService | CronolinkService;

interface CreateActorOptions {
  canisterId: string | Principal;
  identity?: Identity;
  host?: string;
}

/**
 * Creates an actor instance for interacting with a canister
 * @param options Configuration options for actor creation
 * @returns Actor instance
 */
export const createActor = async <T extends CanisterService>({
  canisterId,
  identity,
  host = process.env.DFX_NETWORK === 'ic' ? 'https://ic0.app' : 'http://localhost:4943'
}: CreateActorOptions) => {
  try {
    const agent = new HttpAgent({ host, identity });

    // Only fetch root key in local development
    if (process.env.DFX_NETWORK !== 'ic') {
      await agent.fetchRootKey().catch(e => {
        console.error('Failed to fetch root key:', e);
        throw new Error('Failed to initialize local development environment');
      });
    }

    // Determine which IDL factory to use based on canister ID
    const idlFactory = 
      canisterId === process.env.VITE_LNFT_CORE_CANISTER_ID 
        ? lnftIdlFactory 
        : cronolinkIdlFactory;

    const actor = Actor.createActor<T>(idlFactory, {
      agent,
      canisterId: typeof canisterId === 'string' ? Principal.fromText(canisterId) : canisterId
    });

    return actor;
  } catch (error) {
    console.error('Failed to create actor:', error);
    throw new Error('Failed to establish canister connection');
  }
};

/**
 * Type guard for checking response types
 */
export const isSuccessResponse = <T>(
  response: { Ok: T } | { Err: string }
): response is { Ok: T } => {
  return 'Ok' in response;
};

/**
 * Transforms canister response to handle Ok/Err pattern
 */
export const transformResponse = <T>(
  response: { Ok: T } | { Err: string }
): T => {
  if (isSuccessResponse(response)) {
    return response.Ok;
  }
  throw new Error(response.Err);
};