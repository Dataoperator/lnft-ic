import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MatrixRain } from '../../components/MatrixRain';
import { TerminalWindow } from '../../components/TerminalWindow';
import { EntityCard } from '../../components/EntityCard';
import { MintingInterface } from '../minting/components/MintingInterface';
import { ChatInterface } from '../cronolink/components/ChatInterface';
import { MemoryDisplay } from '../cronolink/components/MemoryDisplay';
import { LoginButton } from '../auth/components/LoginButton';
import { NeuralLink } from '../../components/NeuralLink';
import { MatrixText } from '../../components/MatrixText';
import { useAuthStore } from '../auth/auth.store';
import { GridPattern } from '../../components/GridPattern';

export const DashboardView: React.FC = () => {
  const [selectedLNFT, setSelectedLNFT] = useState<string | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const { isAuthenticated } = useAuthStore();

  useEffect(() => {
    if (!isAuthenticated) {
      setSelectedLNFT(null);
    }
  }, [isAuthenticated]);

  const handleNeuralLinkComplete = () => {
    setIsConnected(true);
  };

  return (
    <div className="relative min-h-screen bg-cyber-dark overflow-hidden">
      {/* Background Layer */}
      <div className="fixed inset-0">
        <MatrixRain />
        <div className="absolute inset-0 bg-cyber-dark/50 backdrop-blur-sm" />
        <GridPattern />
      </div>

      {/* Neural Network Connection */}
      <NeuralLink isConnected={isConnected} onConnectionComplete={handleNeuralLinkComplete}>
        {/* Main Content Layer */}
        <AnimatePresence mode="wait">
          {isConnected && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="relative z-10"
            >
              {/* Header Terminal */}
              <TerminalWindow className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 mb-8">
                <div className="flex justify-between items-center py-4">
                  <div className="flex items-center space-x-4">
                    <MatrixText 
                      text="DIGITAL ENTITIES INTERFACE v1.0" 
                      className="text-2xl sm:text-3xl"
                    />
                    {isAuthenticated && (
                      <span className="text-cyber-neon/70 text-sm font-mono">
                        NEURAL_LINK::ACTIVE
                      </span>
                    )}
                  </div>
                  <LoginButton />
                </div>
              </TerminalWindow>

              {/* Main Grid */}
              <main className="container mx-auto px-4 py-8">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                  {/* Left Column */}
                  <div className="space-y-8">
                    {/* Entity Display */}
                    <TerminalWindow>
                      <div className="p-4">
                        <MatrixText text="ACTIVE ENTITIES" className="text-xl mb-4" />
                        <AnimatePresence mode="wait">
                          {selectedLNFT ? (
                            <motion.div
                              initial={{ opacity: 0, y: 20 }}
                              animate={{ opacity: 1, y: 0 }}
                              exit={{ opacity: 0, y: -20 }}
                              className="space-y-4"
                            >
                              <MemoryDisplay lnftId={selectedLNFT} />
                            </motion.div>
                          ) : (
                            <motion.div
                              initial={{ opacity: 0 }}
                              animate={{ opacity: 1 }}
                              className="text-center py-12"
                            >
                              <MatrixText 
                                text="NO ENTITY SELECTED" 
                                className="text-lg mb-2" 
                              />
                              <p className="text-cyber-neon/70 font-mono">
                                Initialize entity connection...
                              </p>
                            </motion.div>
                          )}
                        </AnimatePresence>
                      </div>
                    </TerminalWindow>

                    {/* Minting Interface */}
                    {isAuthenticated && (
                      <TerminalWindow>
                        <div className="p-4">
                          <MatrixText 
                            text="ENTITY GENESIS PROTOCOL" 
                            className="text-xl mb-4" 
                          />
                          <MintingInterface />
                        </div>
                      </TerminalWindow>
                    )}
                  </div>

                  {/* Right Column */}
                  <div className="space-y-8">
                    {/* Cronolink Interface */}
                    <TerminalWindow>
                      <div className="p-4">
                        <MatrixText 
                          text="NEURAL LINK INTERFACE" 
                          className="text-xl mb-4" 
                        />
                        <AnimatePresence mode="wait">
                          {selectedLNFT ? (
                            <motion.div
                              initial={{ opacity: 0 }}
                              animate={{ opacity: 1 }}
                              exit={{ opacity: 0 }}
                            >
                              <ChatInterface lnftId={selectedLNFT} />
                            </motion.div>
                          ) : (
                            <motion.div
                              initial={{ opacity: 0 }}
                              animate={{ opacity: 1 }}
                              className="text-center py-12"
                            >
                              <MatrixText 
                                text="NEURAL LINK INACTIVE" 
                                className="text-lg mb-2" 
                              />
                              <p className="text-cyber-neon/70 font-mono">
                                Select an entity to establish connection...
                              </p>
                            </motion.div>
                          )}
                        </AnimatePresence>
                      </div>
                    </TerminalWindow>

                    {/* Entity Stats */}
                    {selectedLNFT && (
                      <TerminalWindow>
                        <div className="p-4">
                          <MatrixText 
                            text="ENTITY DIAGNOSTICS" 
                            className="text-xl mb-4" 
                          />
                          <div className="grid grid-cols-2 gap-4">
                            <motion.div
                              initial={{ opacity: 0, y: 20 }}
                              animate={{ opacity: 1, y: 0 }}
                              className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20"
                            >
                              <h3 className="text-sm font-mono text-cyber-neon/70">
                                CONSCIOUSNESS_LEVEL
                              </h3>
                              <div className="mt-2 flex items-center">
                                <div className="flex-1">
                                  <div className="w-full bg-cyber-darker rounded-full h-2">
                                    <motion.div
                                      initial={{ width: 0 }}
                                      animate={{ width: '70%' }}
                                      transition={{ duration: 1 }}
                                      className="bg-cyber-neon h-2 rounded-full"
                                    />
                                  </div>
                                </div>
                                <span className="ml-2 text-sm text-cyber-neon">70%</span>
                              </div>
                            </motion.div>

                            <motion.div
                              initial={{ opacity: 0, y: 20 }}
                              animate={{ opacity: 1, y: 0 }}
                              transition={{ delay: 0.1 }}
                              className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20"
                            >
                              <h3 className="text-sm font-mono text-cyber-neon/70">
                                MEMORY_COUNT
                              </h3>
                              <p className="mt-1 text-2xl font-mono text-cyber-neon">24</p>
                            </motion.div>

                            <motion.div
                              initial={{ opacity: 0, y: 20 }}
                              animate={{ opacity: 1, y: 0 }}
                              transition={{ delay: 0.2 }}
                              className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20"
                            >
                              <h3 className="text-sm font-mono text-cyber-neon/70">
                                SKILL_MODULES
                              </h3>
                              <p className="mt-1 text-2xl font-mono text-cyber-neon">8</p>
                            </motion.div>

                            <motion.div
                              initial={{ opacity: 0, y: 20 }}
                              animate={{ opacity: 1, y: 0 }}
                              transition={{ delay: 0.3 }}
                              className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20"
                            >
                              <h3 className="text-sm font-mono text-cyber-neon/70">
                                ACHIEVEMENT_COUNT
                              </h3>
                              <p className="mt-1 text-2xl font-mono text-cyber-neon">12</p>
                            </motion.div>
                          </div>
                        </div>
                      </TerminalWindow>
                    )}
                  </div>
                </div>
              </main>
            </motion.div>
          )}
        </AnimatePresence>
      </NeuralLink>
    </div>
  );
};