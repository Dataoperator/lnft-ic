import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { authStore } from '../auth.store';

interface LoginButtonProps {
  onSuccess?: () => void;
  onError?: (error: Error) => void;
}

export const LoginButton: React.FC<LoginButtonProps> = ({ onSuccess, onError }) => {
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    setIsLoading(true);
    try {
      await authStore.initialize();
      const success = await authStore.login();
      if (success) {
        onSuccess?.();
      }
    } catch (error) {
      console.error('Login failed:', error);
      if (error instanceof Error) {
        onError?.(error);
      } else {
        onError?.(new Error('Unknown error occurred during login'));
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <motion.button
      onClick={handleLogin}
      disabled={isLoading}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      className={`
        relative px-8 py-3 rounded-lg font-medium text-white
        ${isLoading 
          ? 'bg-cyan-600 cursor-wait' 
          : 'bg-cyan-500 hover:bg-cyan-600'}
        transition-colors duration-200
        flex items-center justify-center space-x-2
        border border-cyan-400/30 shadow-lg
        hover:shadow-cyan-500/20
      `}
    >
      {isLoading ? (
        <>
          <motion.span
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
          >
            ⚡
          </motion.span>
          <span>Connecting...</span>
        </>
      ) : (
        <>
          <span className="text-xl">🔐</span>
          <span>Connect with Internet Identity</span>
        </>
      )}
    </motion.button>
  );
};