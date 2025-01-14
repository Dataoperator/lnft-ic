import React from 'react';
import { motion } from 'framer-motion';
import { useAuthStore } from '../auth.store';

export const LoginButton: React.FC = () => {
  const { isAuthenticated, login, logout } = useAuthStore();

  return (
    <motion.button
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      onClick={isAuthenticated ? logout : login}
      className={`
        inline-flex items-center px-4 py-2 border border-transparent 
        text-sm font-mono rounded-md shadow-sm 
        ${isAuthenticated 
          ? 'text-cyber-neon border-cyber-pink bg-cyber-darker hover:bg-cyber-pink/20' 
          : 'text-cyber-neon border-cyber-neon bg-cyber-darker hover:bg-cyber-neon/20'
        } 
        transition-colors duration-200
        focus:outline-none focus:ring-2 focus:ring-offset-2 
        ${isAuthenticated ? 'focus:ring-cyber-pink' : 'focus:ring-cyber-neon'}
      `}
    >
      {isAuthenticated ? 'Disconnect Neural Link' : 'Connect Neural Link'}
    </motion.button>
  );
};