import React, { useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuthStore } from '../auth.store';
import { LoginButton } from './LoginButton';
import { NeuralLink } from '../../../components/NeuralLink';

interface AuthGuardProps {
  children: React.ReactNode;
}

export const AuthGuard: React.FC<AuthGuardProps> = ({ children }) => {
  const [isChecking, setIsChecking] = useState(true);
  const { isAuthenticated, initialize } = useAuthStore();
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      try {
        await initialize();
      } catch (error) {
        console.error('Auth check failed:', error);
      } finally {
        setIsChecking(false);
      }
    };

    checkAuth();
  }, [initialize]);

  if (isChecking) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center">
        <motion.div
          animate={{ opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 1.5, repeat: Infinity }}
          className="text-cyan-500 text-xl font-mono"
        >
          Initializing neural interface...
        </motion.div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <NeuralLink>
        <AnimatePresence mode="wait">
          <motion.div
            key="login"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="min-h-screen flex flex-col items-center justify-center p-4"
          >
            <motion.div
              className="max-w-md w-full space-y-8 p-8 bg-black/80 rounded-xl border border-cyan-500/30 backdrop-blur-sm"
              initial={{ scale: 0.95 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring", stiffness: 300, damping: 25 }}
            >
              <div className="text-center space-y-6">
                <h2 className="text-3xl font-bold text-cyan-400">
                  Neural Authentication Required
                </h2>
                <p className="text-gray-400">
                  Please authenticate using your Internet Identity to access the neural interface.
                </p>
                <div className="pt-4">
                  <LoginButton />
                </div>
              </div>
            </motion.div>
          </motion.div>
        </AnimatePresence>
      </NeuralLink>
    );
  }

  // User is authenticated
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: 20 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
};