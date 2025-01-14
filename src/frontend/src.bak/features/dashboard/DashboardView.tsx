import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { MatrixRain } from '../../components/MatrixRain';
import { TerminalWindow } from '../../components/TerminalWindow';
import { EntityCard } from '../../components/EntityCard';
import { MintingInterface } from '../minting/components/MintingInterface';
import { ChatInterface } from '../cronolink/components/ChatInterface';
import { MemoryDisplay } from '../cronolink/components/MemoryDisplay';
import { LoginButton } from '../auth/components/LoginButton';
import { NeuralLink } from '../../components/NeuralLink';
import { MatrixText } from '../../components/MatrixText';

export const DashboardView: React.FC = () => {
  const [selectedLNFT, setSelectedLNFT] = useState<string | null>(null);

  return (
    <div className="relative min-h-screen bg-cyber-dark overflow-hidden">
      {/* Background Effects */}
      <MatrixRain />
      <div className="absolute inset-0 bg-cyber-dark/50 backdrop-blur-sm" />

      {/* Main Content */}
      <div className="relative z-10">
        {/* Header */}
        <TerminalWindow>
          <div className="flex justify-between items-center py-4">
            <MatrixText text="DIGITAL ENTITIES INTERFACE v1.0" className="text-3xl" />
            <LoginButton />
          </div>
        </TerminalWindow>

        {/* Neural Network Connection Lines */}
        <NeuralLink />

        {/* Main Grid */}
        <main className="container mx-auto px-4 py-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Left Column */}
            <div className="space-y-8">
              {/* LNFT Display */}
              <TerminalWindow>
                <div className="p-4">
                  <MatrixText text="ACTIVE ENTITIES" className="text-xl mb-4" />
                  {selectedLNFT ? (
                    <motion.div
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="space-y-4"
                    >
                      <MemoryDisplay lnftId={selectedLNFT} />
                    </motion.div>
                  ) : (
                    <div className="text-center py-12">
                      <MatrixText text="NO ENTITY SELECTED" className="text-lg mb-2" />
                      <p className="text-cyber-neon/70">Initialize entity connection...</p>
                    </div>
                  )}
                </div>
              </TerminalWindow>

              {/* Minting Interface */}
              <TerminalWindow>
                <div className="p-4">
                  <MatrixText text="ENTITY GENESIS PROTOCOL" className="text-xl mb-4" />
                  <MintingInterface />
                </div>
              </TerminalWindow>
            </div>

            {/* Right Column */}
            <div className="space-y-8">
              {/* Cronolink Interface */}
              <TerminalWindow>
                <div className="p-4">
                  <MatrixText text="NEURAL LINK INTERFACE" className="text-xl mb-4" />
                  {selectedLNFT ? (
                    <ChatInterface lnftId={selectedLNFT} />
                  ) : (
                    <div className="text-center py-12">
                      <MatrixText text="NEURAL LINK INACTIVE" className="text-lg mb-2" />
                      <p className="text-cyber-neon/70">Select an entity to establish connection...</p>
                    </div>
                  )}
                </div>
              </TerminalWindow>

              {/* Entity Stats */}
              {selectedLNFT && (
                <TerminalWindow>
                  <div className="p-4">
                    <MatrixText text="ENTITY DIAGNOSTICS" className="text-xl mb-4" />
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20">
                        <h3 className="text-sm font-mono text-cyber-neon/70">CONSCIOUSNESS_LEVEL</h3>
                        <div className="mt-2 flex items-center">
                          <div className="flex-1">
                            <div className="w-full bg-cyber-darker rounded-full h-2">
                              <div
                                className="bg-cyber-neon h-2 rounded-full"
                                style={{ width: '70%' }}
                              />
                            </div>
                          </div>
                          <span className="ml-2 text-sm text-cyber-neon">70%</span>
                        </div>
                      </div>
                      <div className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20">
                        <h3 className="text-sm font-mono text-cyber-neon/70">MEMORY_COUNT</h3>
                        <p className="mt-1 text-2xl font-mono text-cyber-neon">24</p>
                      </div>
                      <div className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20">
                        <h3 className="text-sm font-mono text-cyber-neon/70">SKILL_MODULES</h3>
                        <p className="mt-1 text-2xl font-mono text-cyber-neon">8</p>
                      </div>
                      <div className="bg-cyber-darker/50 p-4 rounded-lg border border-cyber-neon/20">
                        <h3 className="text-sm font-mono text-cyber-neon/70">ACHIEVEMENT_COUNT</h3>
                        <p className="mt-1 text-2xl font-mono text-cyber-neon">12</p>
                      </div>
                    </div>
                  </div>
                </TerminalWindow>
              )}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};