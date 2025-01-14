import { useState, useEffect } from 'react';
import { LNFT, EmotionalState, Memory } from '../types/canister';
import { MintingStore } from '../features/minting/minting.store';
import { CronolinkStore } from '../features/cronolink/cronolink.store';

export const useLNFT = (id: string) => {
  const [lnft, setLNFT] = useState<LNFT | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const cronolinkStore = new CronolinkStore();
  const mintingStore = new MintingStore();

  useEffect(() => {
    if (id) {
      fetchLNFT();
    }
  }, [id]);

  const fetchLNFT = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Fetch emotional state and memories in parallel
      const [emotionalState, memories] = await Promise.all([
        cronolinkStore.getCurrentEmotionalState(id),
        cronolinkStore.getMemories(id),
      ]);

      // Fetch traits
      const traits = await mintingStore.getAvailableTraits();

      // Combine data
      setLNFT({
        id,
        emotionalState,
        memories,
        traits,
        // Note: These would come from your actual backend
        name: `LNFT #${id}`,
        consciousness: 100,
        owner: await (await cronolinkStore.getIdentity())?.getPrincipal()!,
      });
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to fetch LNFT'));
    } finally {
      setIsLoading(false);
    }
  };

  const updateEmotionalState = (newState: EmotionalState) => {
    setLNFT(prev => prev ? { ...prev, emotionalState: newState } : null);
  };

  const addMemory = (newMemory: Memory) => {
    setLNFT(prev => 
      prev ? { ...prev, memories: [newMemory, ...prev.memories] } : null
    );
  };

  return {
    lnft,
    isLoading,
    error,
    updateEmotionalState,
    addMemory,
    refresh: fetchLNFT,
  };
};