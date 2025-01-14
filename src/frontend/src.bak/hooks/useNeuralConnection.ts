import { useState, useEffect, useCallback } from 'react';
import { LNFT } from '../types/canister';
import { CronolinkStore } from '../features/cronolink/cronolink.store';

interface UseNeuralConnectionProps {
  lnft: LNFT | null;
  onConnectionStateChange?: (isConnected: boolean) => void;
  onConnectionError?: (error: Error) => void;
}

export const useNeuralConnection = ({
  lnft,
  onConnectionStateChange,
  onConnectionError,
}: UseNeuralConnectionProps) => {
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [connectionStrength, setConnectionStrength] = useState(0);
  const [error, setError] = useState<Error | null>(null);

  const cronolinkStore = new CronolinkStore();

  const connect = useCallback(async () => {
    if (!lnft) return;
    
    try {
      setIsConnecting(true);
      setError(null);

      // Simulate neural connection establishment
      for (let i = 0; i <= 100; i += 10) {
        await new Promise(resolve => setTimeout(resolve, 200));
        setConnectionStrength(i);
      }

      // Initialize connection with LNFT
      await cronolinkStore.processMessage(lnft.id, '/initialize_neural_link');
      
      setIsConnected(true);
      onConnectionStateChange?.(true);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to establish neural connection');
      setError(error);
      onConnectionError?.(error);
    } finally {
      setIsConnecting(false);
    }
  }, [lnft, onConnectionStateChange, onConnectionError]);

  const disconnect = useCallback(async () => {
    if (!lnft || !isConnected) return;

    try {
      // Simulate neural connection teardown
      for (let i = 100; i >= 0; i -= 10) {
        await new Promise(resolve => setTimeout(resolve, 100));
        setConnectionStrength(i);
      }

      // Cleanup connection with LNFT
      await cronolinkStore.processMessage(lnft.id, '/terminate_neural_link');
      
      setIsConnected(false);
      onConnectionStateChange?.(false);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to terminate neural connection');
      setError(error);
      onConnectionError?.(error);
    }
  }, [lnft, isConnected, onConnectionStateChange, onConnectionError]);

  // Auto-connect when LNFT is provided
  useEffect(() => {
    if (lnft && !isConnected && !isConnecting) {
      connect();
    }
    return () => {
      if (isConnected) {
        disconnect();
      }
    };
  }, [lnft, isConnected, isConnecting, connect, disconnect]);

  // Monitor connection strength
  useEffect(() => {
    if (!isConnected) return;

    const interval = setInterval(() => {
      // Simulate minor fluctuations in connection strength
      setConnectionStrength(prev => {
        const fluctuation = Math.random() * 10 - 5; // Random value between -5 and 5
        const newStrength = Math.max(0, Math.min(100, prev + fluctuation));
        return Math.round(newStrength);
      });
    }, 5000);

    return () => clearInterval(interval);
  }, [isConnected]);

  return {
    isConnected,
    isConnecting,
    connectionStrength,
    error,
    connect,
    disconnect,
  };
};