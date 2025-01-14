import { ActorSubclass, HttpAgentOptions, Identity } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { CreateActorOptions } from '@dfinity/agent/lib/cjs/actor';

export interface InterfaceFactory {
  createActor: <T>(
    canisterId: string | Principal,
    options?: CreateActorOptions
  ) => ActorSubclass<T>;
}

export interface _SERVICE {
  // LNFT Core methods
  mint: (args: { name: string; traits: Trait[] }) => Promise<{ Ok: string } | { Err: string }>;
  getCurrentPrice: () => Promise<bigint>;
  getAvailableTraits: () => Promise<Trait[]>;
  
  // Memory and Emotional State methods
  getMemories: (id: string) => Promise<Memory[]>;
  getCurrentEmotionalState: (id: string) => Promise<EmotionalState>;
  
  // Cronolink methods
  processMessage: (args: { lnftId: string; message: string }) => Promise<{ 
    Ok: { 
      response: string; 
      emotionalUpdate?: EmotionalState;
      newMemory?: Memory;
    } 
  } | { 
    Err: string 
  }>;
}

export interface LNFT {
  id: string;
  owner: Principal;
  name: string;
  consciousness: number;
  traits: Trait[];
  emotionalState: EmotionalState;
  memories: Memory[];
}

export interface Trait {
  type: TraitType;
  value: string;
  rarity: Rarity;
}

export enum TraitType {
  PERSONALITY = 'PERSONALITY',
  ABILITY = 'ABILITY',
  PREFERENCE = 'PREFERENCE',
}

export enum Rarity {
  COMMON = 'COMMON',
  UNCOMMON = 'UNCOMMON',
  RARE = 'RARE',
  LEGENDARY = 'LEGENDARY',
}

export interface EmotionalState {
  primary: string;
  intensity: number;
  timestamp: bigint;
}

export interface Memory {
  id: string;
  type: MemoryType;
  content: string;
  timestamp: bigint;
  emotionalContext?: EmotionalState;
}

export enum MemoryType {
  INTERACTION = 'INTERACTION',
  EXPERIENCE = 'EXPERIENCE',
  OBSERVATION = 'OBSERVATION',
}