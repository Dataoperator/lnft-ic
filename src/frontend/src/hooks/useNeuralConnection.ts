import { useState, useEffect, useCallback } from 'react';
import { LNFT } from '../types/canister';
import { useCronolinkStore } from '../features/cronolink/cronolink.store';

interface UseNeuralConnectionOptions {
  lnft: LNFT | null;
  onConnectionStateChange?: (isConnected: boolean) => void;
  onConnectionError?: (error: Error) => void;
  connectionTimeout?: number;
}

interface NeuralConnectionState {
  isConnected: boolean;
  isConnecting: boolean;
  connectionStrength: number;
  error: Error | null;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
}

const CONNECTION_STAGES = [
  'Initializing neural interface...',
  'Synchronizing consciousness patterns...',
  'Aligning emotional matrices...',
  'Establishing memory bridges...',
  'Finalizing neural pathways...'
];

export const useNeuralConnection = ({
  lnft,
  onConnectionStateChange,
  onConnectionError,
  connectionTimeout = 10000 // 10 seconds default timeout
}: UseNeuralConnectionOptions): NeuralConnectionState => {
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [connectionStrength, setConnectionStrength] = useState(0);
  const [error, setError] = useState<Error | null>(null);
  const [currentStage, setCurrentStage] = useState(0);

  const { sendMessage } = useCronolinkStore();

  const connect = useCallback(async () => {
    if (!lnft || isConnected || isConnecting) return;
    
    let timeoutId: NodeJS.Timeout;
    
    try {
      setIsConnecting(true);
      setError(null);

      // Setup connection timeout
      const timeoutPromise = new Promise((_, reject) => {
        timeoutId = setTimeout(() => {
          reject(new Error('Neural connection timeout'));
        }, connectionTimeout);
      });

      // Simulate neural connection stages
      const connectionPromise = (async () => {
        for (let i = 0; i <= CONNECTION_STAGES.length - 1; i++) {
          setCurrentStage(i);
          await new Promise(resolve => setTimeout(resolve, 1000));
          setConnectionStrength((i + 1) * (100 / CONNECTION_STAGES.length));
        }

        // Initialize connection with LNFT
        await sendMessage(lnft.id, '/initialize_neural_link');
      })();

      // Race between connection and timeout
      await Promise.race([connectionPromise, timeoutPromise]);
      
      setIsConnected(true);
      onConnectionStateChange?.(true);
      
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to establish neural connection');
      setError(error);
      onConnectionError?.(error);
      setConnectionStrength(0);
    } finally {
      setIsConnecting(false);
      clearTimeout(timeoutId!);
    }
  }, [lnft, isConnected, isConnecting, connectionTimeout, sendMessage, onConnectionStateChange, onConnectionError]);

  const disconnect = useCallback(async () => {
    if (!lnft || !isConnected) return;

    try {
      // Simulate neural connection teardown
      for (let i = CONNECTION_STAGES.length - 1; i >= 0; i--) {
        setCurrentStage(i);
        setConnectionStrength((i) * (100 / CONNECTION_STAGES.length));
        await new Promise(resolve => setTimeout(resolve, 500));
      }

      await sendMessage(lnft.id, '/terminate_neural_link');
      
      setIsConnected(false);
      setConnectionStrength(0);
      onConnectionStateChange?.(false);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to terminate neural connection');
      setError(error);
      onConnectionError?.(error);
    }
  }, [lnft, isConnected, sendMessage, onConnectionStateChange, onConnectionError]);

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

  // Monitor connection strength with fluctuations
  useEffect(() => {
    if (!isConnected) return;

    const interval = setInterval(() => {
      setConnectionStrength(prev => {
        const fluctuation = Math.random() * 10 - 5; // Random value between -5 and 5
        return Math.max(70, Math.min(100, prev + fluctuation));
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