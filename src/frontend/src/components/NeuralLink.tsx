import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';
import { MatrixText } from './MatrixText';

interface NeuralLinkProps {
  children: React.ReactNode;
  className?: string;
  isConnected?: boolean;
  onConnectionComplete?: () => void;
  connectionTime?: number;
}

export const NeuralLink: React.FC<NeuralLinkProps> = ({
  children,
  className,
  isConnected = false,
  onConnectionComplete,
  connectionTime = 2
}) => {
  const [isInitialized, setIsInitialized] = useState(false);
  const [connectionProgress, setConnectionProgress] = useState(0);
  const [showLoadingText, setShowLoadingText] = useState(true);

  useEffect(() => {
    if (!isConnected) return;

    const startTime = Date.now();
    const endTime = startTime + (connectionTime * 1000);

    const updateProgress = () => {
      const now = Date.now();
      const progress = Math.min(((now - startTime) / (connectionTime * 1000)) * 100, 100);
      setConnectionProgress(progress);

      if (now < endTime) {
        requestAnimationFrame(updateProgress);
      } else {
        setIsInitialized(true);
        onConnectionComplete?.();
      }
    };

    requestAnimationFrame(updateProgress);

    const textTimeout = setTimeout(() => {
      setShowLoadingText(false);
    }, connectionTime * 1000);

    return () => {
      clearTimeout(textTimeout);
    };
  }, [isConnected, connectionTime, onConnectionComplete]);

  return (
    <div className={cn('relative min-h-screen', className)}>
      <AnimatePresence>
        {!isInitialized && (
          <motion.div
            key="loading"
            initial={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-50 flex items-center justify-center bg-black"
          >
            <div className="text-center space-y-8">
              <AnimatePresence mode="wait">
                {showLoadingText && (
                  <motion.div
                    key="loading-text"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    className="space-y-4"
                  >
                    <MatrixText 
                      text="INITIALIZING NEURAL LINK"
                      className="text-2xl text-cyan-500"
                    />
                    <p className="text-cyan-500/70 text-sm font-mono">
                      Establishing quantum-encrypted connection...
                    </p>
                  </motion.div>
                )}
              </AnimatePresence>

              <motion.div
                className="w-64 h-1 bg-cyan-950 rounded-full overflow-hidden"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
              >
                <motion.div
                  className="h-full bg-cyan-500"
                  initial={{ width: 0 }}
                  animate={{ width: `${connectionProgress}%` }}
                  transition={{ duration: 0.1 }}
                />
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {children}
    </div>
  );
};