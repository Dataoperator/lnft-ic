import { useState, useCallback } from 'react';
import { Trait, Rarity, TraitType } from '../types/canister';
import { MintingStore } from '../features/minting/minting.store';

interface MintingOptions {
  onMintSuccess?: (tokenId: string) => void;
  onMintError?: (error: Error) => void;
  onPriceUpdate?: (price: bigint) => void;
}

export const useMinting = (options?: MintingOptions) => {
  const [isMinting, setIsMinting] = useState(false);
  const [currentPrice, setCurrentPrice] = useState<bigint | null>(null);
  const [availableTraits, setAvailableTraits] = useState<Trait[]>([]);
  const [error, setError] = useState<Error | null>(null);

  const mintingStore = new MintingStore();

  const fetchPrice = useCallback(async () => {
    try {
      const price = await mintingStore.getCurrentPrice();
      setCurrentPrice(price);
      options?.onPriceUpdate?.(price);
    } catch (err) {
      console.error('Failed to fetch price:', err);
      setError(err instanceof Error ? err : new Error('Failed to fetch current price'));
    }
  }, [options]);

  const fetchAvailableTraits = useCallback(async () => {
    try {
      const traits = await mintingStore.getAvailableTraits();
      setAvailableTraits(traits);
    } catch (err) {
      console.error('Failed to fetch traits:', err);
      setError(err instanceof Error ? err : new Error('Failed to fetch available traits'));
    }
  }, []);

  const mintLNFT = useCallback(async (name: string, selectedTraits: Trait[]) => {
    try {
      setIsMinting(true);
      setError(null);

      // Validate traits
      if (!validateTraits(selectedTraits)) {
        throw new Error('Invalid trait configuration');
      }

      const result = await mintingStore.mintLNFT(name, selectedTraits);
      
      if (result.success) {
        options?.onMintSuccess?.(result.tokenId);
        return result.tokenId;
      } else {
        throw new Error('Minting failed');
      }
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown minting error');
      setError(error);
      options?.onMintError?.(error);
      throw error;
    } finally {
      setIsMinting(false);
    }
  }, [options]);

  const validateTraits = (traits: Trait[]): boolean => {
    // Ensure we have at least one of each trait type
    const traitTypes = new Set(traits.map(t => t.type));
    const requiredTypes = Object.values(TraitType);
    
    if (traitTypes.size !== requiredTypes.length) {
      return false;
    }

    // Validate individual traits
    return traits.every(trait => {
      // Ensure trait has a value
      if (!trait.value.trim()) return false;

      // Ensure trait has a valid rarity
      if (!Object.values(Rarity).includes(trait.rarity)) return false;

      // Ensure trait has a valid type
      if (!Object.values(TraitType).includes(trait.type)) return false;

      return true;
    });
  };

  const generateRandomTraits = useCallback((): Trait[] => {
    const traits: Trait[] = [];
    const rarityWeights = {
      [Rarity.COMMON]: 0.5,
      [Rarity.UNCOMMON]: 0.3,
      [Rarity.RARE]: 0.15,
      [Rarity.LEGENDARY]: 0.05,
    };

    // Generate one trait for each type
    Object.values(TraitType).forEach(type => {
      // Get available traits for this type
      const typeTraits = availableTraits.filter(t => t.type === type);
      if (typeTraits.length === 0) return;

      // Select random trait based on rarity weights
      const roll = Math.random();
      let cumulativeWeight = 0;
      let selectedRarity = Rarity.COMMON;

      for (const [rarity, weight] of Object.entries(rarityWeights)) {
        cumulativeWeight += weight;
        if (roll <= cumulativeWeight) {
          selectedRarity = rarity as Rarity;
          break;
        }
      }

      // Filter traits by selected rarity
      const rarityTraits = typeTraits.filter(t => t.rarity === selectedRarity);
      const selectedTrait = rarityTraits[Math.floor(Math.random() * rarityTraits.length)];

      if (selectedTrait) {
        traits.push(selectedTrait);
      }
    });

    return traits;
  }, [availableTraits]);

  return {
    isMinting,
    currentPrice,
    availableTraits,
    error,
    mintLNFT,
    fetchPrice,
    fetchAvailableTraits,
    generateRandomTraits,
    validateTraits,
  };
};