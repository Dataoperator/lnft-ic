// Shared types between frontend and backend
export interface LNFT {
  id: string;
  owner: string;
  name: string;
  traits: Trait[];
  emotionalState: EmotionalState;
  memories: Memory[];
}

export interface Trait {
  id: string;
  name: string;
  rarity: Rarity;
  type: TraitType;
}

export enum Rarity {
  Common = 'Common',
  Uncommon = 'Uncommon',
  Rare = 'Rare',
  Epic = 'Epic',
  Legendary = 'Legendary',
  Event = 'Event'
}

export enum TraitType {
  Physical = 'Physical',
  Mental = 'Mental',
  Special = 'Special',
  Skill = 'Skill',
  Event = 'Event'
}

export interface EmotionalState {
  id: string;
  mood: string;
  intensity: number;
  timestamp: number;
}

export interface Memory {
  id: string;
  content: string;
  type: MemoryType;
  timestamp: number;
  emotionalImpact: number;
}

export enum MemoryType {
  Interaction = 'Interaction',
  Achievement = 'Achievement',
  Event = 'Event',
  Skill = 'Skill'
}