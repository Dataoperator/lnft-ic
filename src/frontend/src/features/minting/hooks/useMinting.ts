import { useState } from 'react';
import { useAuthStore } from '../../auth/auth.store';

export interface MintingOptions {
  name: string;
  description: string;
  traits: Record<string, string | number>;
}

export const useMinting = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const { actor } = useAuthStore();

  const mint = async (options: MintingOptions) => {
    if (!actor) {
      throw new Error('No actor available');
    }

    setIsLoading(true);
    setError(null);

    try {
      // Call the minting function from your LNFT canister
      const result = await actor.mint({
        name: options.name,
        description: options.description,
        traits: options.traits,
      });

      return result;
    } catch (err) {
      setError(err as Error);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    mint,
    isLoading,
    error,
  };
};