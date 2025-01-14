import { useState } from 'react';
import { Actor } from '@dfinity/agent';
import { useAuth } from './useAuth';

interface Trait {
  name: string;
  value: number;
}

interface MintData {
  traits: Trait[];
  archetype: string;
  timestamp: number;
}

export const useMinting = () => {
  const [isMinting, setIsMinting] = useState(false);
  const { actor } = useAuth();

  const mintEntity = async (data: MintData) => {
    if (!actor) throw new Error('No actor available');
    
    setIsMinting(true);
    try {
      // Convert traits to the format expected by the canister
      const traitData = data.traits.reduce((acc, trait) => {
        acc[trait.name.toLowerCase()] = trait.value;
        return acc;
      }, {} as Record<string, number>);

      // Call the mint method on the LNFT canister
      const result = await actor.mint({
        traits: traitData,
        archetype: data.archetype,
        timestamp: BigInt(data.timestamp)
      });

      return result;
    } catch (error) {
      console.error('Minting error:', error);
      throw error;
    } finally {
      setIsMinting(false);
    }
  };

  return {
    mintEntity,
    isMinting
  };
};