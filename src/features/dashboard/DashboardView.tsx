import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { EntityCard } from '../../components/EntityCard';
import { ChatInterface, MemoryDisplay } from '../cronolink';
import { LNFT, EmotionalState, Memory } from '../../types/canister';
import { MintingStore } from '../minting/minting.store';
import { CronolinkStore } from '../cronolink/cronolink.store';

export const DashboardView = () => {
  const [selectedLNFT, setSelectedLNFT] = useState<LNFT | null>(null);
  const [ownedLNFTs, setOwnedLNFTs] = useState<LNFT[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const mintingStore = new MintingStore();
  const cronolinkStore = new CronolinkStore();

  useEffect(() => {
    fetchOwnedLNFTs();
  }, []);

  const fetchOwnedLNFTs = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Implementation will depend on your backend structure
      const response = await fetch('/api/owned-lnfts');
      const data = await response.json();
      setOwnedLNFTs(data);
    } catch (err) {
      setError('Failed to load your LNFTs');
      console.error('Error fetching LNFTs:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleEmotionalUpdate = async (lnftId: string, update: EmotionalState) => {
    const updatedLNFTs = ownedLNFTs.map(lnft => {
      if (lnft.id === lnftId) {
        return { ...lnft, emotionalState: update };
      }
      return lnft;
    });
    setOwnedLNFTs(updatedLNFTs);

    if (selectedLNFT?.id === lnftId) {
      setSelectedLNFT(prev => prev ? { ...prev, emotionalState: update } : null);
    }
  };

  const handleNewMemory = async (lnftId: string, memory: Memory) => {
    const updatedLNFTs = ownedLNFTs.map(lnft => {
      if (lnft.id === lnftId) {
        return { ...lnft, memories: [memory, ...(lnft.memories || [])] };
      }
      return lnft;
    });
    setOwnedLNFTs(updatedLNFTs);

    if (selectedLNFT?.id === lnftId) {
      setSelectedLNFT(prev => 
        prev ? { ...prev, memories: [memory, ...(prev.memories || [])] } : null
      );
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-black/95">
        <div className="text-cyan-500 text-xl">Loading your digital entities...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-black/95">
        <div className="text-red-500 text-xl">{error}</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black/95 p-6">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-4xl text-cyan-500 mb-8">Your Living NFTs</h1>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="space-y-6">
            <AnimatePresence mode="wait">
              {ownedLNFTs.map((lnft) => (
                <motion.div
                  key={lnft.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0 }}
                  onClick={() => setSelectedLNFT(lnft)}
                  className="cursor-pointer"
                >
                  <EntityCard {...lnft} />
                </motion.div>
              ))}
            </AnimatePresence>
          </div>

          <div className="space-y-8">
            {selectedLNFT && (
              <AnimatePresence mode="wait">
                <motion.div
                  key="interaction-panel"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0 }}
                  className="space-y-8"
                >
                  <div className="bg-black/80 rounded-lg border border-cyan-500/30 p-6">
                    <h2 className="text-2xl text-cyan-400 mb-6">Interact with {selectedLNFT.name}</h2>
                    <ChatInterface
                      lnftId={selectedLNFT.id}
                      onEmotionalUpdate={(update) => handleEmotionalUpdate(selectedLNFT.id, update)}
                      onNewMemory={(memory) => handleNewMemory(selectedLNFT.id, memory)}
                    />
                  </div>

                  <div className="bg-black/80 rounded-lg border border-cyan-500/30 p-6">
                    <MemoryDisplay
                      lnftId={selectedLNFT.id}
                      onMemorySelect={(memory) => console.log('Memory selected:', memory)}
                    />
                  </div>
                </motion.div>
              </AnimatePresence>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};