import { useState, useEffect, useCallback } from 'react';
import { LNFT, EmotionalState, Memory, Principal } from '../types/canister';
import { useMintingStore } from '../features/minting/minting.store';
import { useCronolinkStore } from '../features/cronolink/cronolink.store';
import { useAuthStore } from '../features/auth/auth.store';

interface LNFTState {
  lnft: LNFT | null;
  isLoading: boolean;
  error: Error | null;
  updateEmotionalState: (newState: EmotionalState) => void;
  addMemory: (newMemory: Memory) => void;
  refresh: () => Promise<void>;
}

interface UseLNFTOptions {
  onStateChange?: (state: EmotionalState) => void;
  onNewMemory?: (memory: Memory) => void;
  onError?: (error: Error) => void;
}

export const useLNFT = (
  id: string | null,
  options: UseLNFTOptions = {}
): LNFTState => {
  const [lnft, setLNFT] = useState<LNFT | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  
  const { fetchMemories, fetchEmotionalState } = useCronolinkStore();
  const { fetchAvailableTraits } = useMintingStore();
  const { identity } = useAuthStore();

  const fetchLNFT = useCallback(async () => {
    if (!id || !identity) return;

    try {
      setIsLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [
        emotionalState,
        memories,
        traits,
      ] = await Promise.all([
        fetchEmotionalState(id),
        fetchMemories(id),
        fetchAvailableTraits(),
      ]);

      // Construct LNFT object
      const newLNFT: LNFT = {
        id,
        emotionalState,
        memories,
        traits,
        name: `Entity ${id}`,
        consciousness: calculateConsciousness(memories, emotionalState),
        owner: Principal.fromText(identity.getPrincipal().toString()),
      };

      setLNFT(newLNFT);
    } catch (err) {
      const error = err instanceof Error 
        ? err 
        : new Error('Failed to fetch entity data');
      setError(error);
      options.onError?.(error);
    } finally {
      setIsLoading(false);
    }
  }, [id, identity, options.onError]);

  // Initial fetch and setup
  useEffect(() => {
    fetchLNFT();
  }, [fetchLNFT]);

  // Update methods
  const updateEmotionalState = useCallback((newState: EmotionalState) => {
    setLNFT(prev => {
      if (!prev) return null;
      const updated = { ...prev, emotionalState: newState };
      options.onStateChange?.(newState);
      return updated;
    });
  }, [options.onStateChange]);

  const addMemory = useCallback((newMemory: Memory) => {
    setLNFT(prev => {
      if (!prev) return null;
      const updated = { 
        ...prev, 
        memories: [newMemory, ...prev.memories],
        consciousness: calculateConsciousness(
          [newMemory, ...prev.memories],
          prev.emotionalState
        )
      };
      options.onNewMemory?.(newMemory);
      return updated;
    });
  }, [options.onNewMemory]);

  return {
    lnft,
    isLoading,
    error,
    updateEmotionalState,
    addMemory,
    refresh: fetchLNFT,
  };
};

// Helper function to calculate consciousness level
const calculateConsciousness = (
  memories: Memory[], 
  emotionalState: EmotionalState
): number => {
  // Base consciousness level
  let consciousness = 70;

  // Adjust based on number of memories (max +15)
  consciousness += Math.min(memories.length * 0.5, 15);

  // Adjust based on emotional intensity (max +15)
  consciousness += Math.min(emotionalState.intensity * 0.15, 15);

  // Ensure bounds
  return Math.max(0, Math.min(100, consciousness));
};