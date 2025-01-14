import { HttpAgent, Actor } from '@dfinity/agent';
import type { Identity } from '@dfinity/agent';
import { idlFactory } from '../declarations/lnft_core/lnft_core.did.js';
import { _SERVICE } from '../types/canister';
import { Principal } from '@dfinity/principal';

export const createStore = async (canisterId: string | Principal, identity?: Identity) => {
  const agent = new HttpAgent({
    host: process.env.DFX_NETWORK === 'ic' ? 'https://ic0.app' : 'http://localhost:4943',
    identity: identity as Identity | undefined,
  });

  if (process.env.DFX_NETWORK !== 'ic') {
    await agent.fetchRootKey();
  }

  const actor = Actor.createActor<_SERVICE>(idlFactory, {
    agent,
    canisterId: typeof canisterId === 'string' ? Principal.fromText(canisterId) : canisterId,
  });

  return actor;
};