import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useMintingStore } from '../minting.store';
import { Trait, TraitType, Rarity } from '../../../types';
import { MatrixText } from '../../../components/MatrixText';

export const MintingInterface: React.FC = () => {
  const { 
    isLoading,
    error,
    currentPrice,
    traits,
    mint,
    fetchCurrentPrice,
    fetchAvailableTraits
  } = useMintingStore();

  const [name, setName] = useState('');
  const [selectedTraits, setSelectedTraits] = useState<string[]>([]);
  const [step, setStep] = useState<'name' | 'traits' | 'confirm'>('name');

  useEffect(() => {
    fetchCurrentPrice();
    fetchAvailableTraits();
  }, []);

  const handleTraitSelection = (traitId: string) => {
    setSelectedTraits(prev => 
      prev.includes(traitId)
        ? prev.filter(id => id !== traitId)
        : [...prev, traitId]
    );
  };

  const handleMint = async () => {
    try {
      await mint(name, selectedTraits);
      setName('');
      setSelectedTraits([]);
      setStep('name');
    } catch (error) {
      // Error is handled by the store
    }
  };

  const getTraitTypeIcon = (type: TraitType) => {
    switch (type) {
      case TraitType.Physical:
        return '⚡';
      case TraitType.Mental:
        return '🧠';
      case TraitType.Special:
        return '💫';
      case TraitType.Skill:
        return '⚔️';
      case TraitType.Event:
        return '🎯';
      default:
        return '❓';
    }
  };

  const getRarityColor = (rarity: Rarity) => {
    switch (rarity) {
      case Rarity.Common:
        return 'border-cyber-neon/30 text-cyber-neon/70';
      case Rarity.Uncommon:
        return 'border-cyber-blue/30 text-cyber-blue';
      case Rarity.Rare:
        return 'border-cyber-yellow/30 text-cyber-yellow';
      case Rarity.Epic:
        return 'border-cyber-pink/30 text-cyber-pink';
      case Rarity.Legendary:
        return 'border-cyber-neon/50 text-cyber-neon animate-pulse-glow';
      case Rarity.Event:
        return 'border-cyber-pink/50 text-cyber-pink animate-pulse-glow';
      default:
        return 'border-cyber-neon/30 text-cyber-neon/70';
    }
  };

  return (
    <div className="max-w-2xl mx-auto bg-cyber-darker/90 rounded-lg border border-cyber-neon/30 overflow-hidden">
      <AnimatePresence mode="wait">
        {error && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="p-4 bg-cyber-pink/20 border-b border-cyber-pink/30"
          >
            <p className="text-sm font-mono text-cyber-pink">{`ERROR: ${error}`}</p>
          </motion.div>
        )}

        <motion.div
          key={step}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="p-6"
        >
          {step === 'name' && (
            <div className="space-y-4">
              <div>
                <label htmlFor="name" className="block text-sm font-mono text-cyber-neon/70">
                  INITIALIZE_ENTITY_DESIGNATION
                </label>
                <input
                  type="text"
                  id="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="mt-1 block w-full bg-cyber-dark/90 text-cyber-neon font-mono border border-cyber-neon/30 rounded-lg 
                           px-4 py-2 focus:outline-none focus:border-cyber-neon focus:ring-1 focus:ring-cyber-neon/50 
                           placeholder-cyber-neon/30"
                  placeholder="ENTER_DESIGNATION://"
                  disabled={isLoading}
                />
              </div>
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => setStep('traits')}
                disabled={!name.trim() || isLoading}
                className="w-full flex justify-center py-2 px-4 bg-cyber-neon/20 border border-cyber-neon 
                         font-mono text-cyber-neon rounded-lg transition-colors duration-200 
                         hover:bg-cyber-neon/30 focus:outline-none focus:ring-2 focus:ring-cyber-neon/50 
                         disabled:opacity-50 disabled:cursor-not-allowed"
              >
                PROCEED_TO_TRAITS
              </motion.button>
            </div>
          )}

          {step === 'traits' && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                {traits.map((trait) => (
                  <motion.div
                    key={trait.id}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => handleTraitSelection(trait.id)}
                    className={`p-4 rounded-lg border cursor-pointer transition-all duration-200
                              bg-cyber-darker/90 ${getRarityColor(trait.rarity)} 
                              ${selectedTraits.includes(trait.id) 
                                ? 'ring-2 ring-cyber-neon' 
                                : 'hover:bg-cyber-dark/50'}`}
                  >
                    <div className="flex items-center space-x-2">
                      <span className="text-2xl">{getTraitTypeIcon(trait.type)}</span>
                      <span className="font-mono">{trait.name}</span>
                    </div>
                    <div className="mt-2 text-xs font-mono opacity-70">
                      <span className="uppercase tracking-wide">{trait.rarity}</span>
                    </div>
                  </motion.div>
                ))}
              </div>
              <div className="flex space-x-4">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setStep('name')}
                  className="flex-1 py-2 px-4 bg-cyber-darker border border-cyber-neon/30 
                           font-mono text-cyber-neon/70 rounded-lg transition-colors duration-200 
                           hover:bg-cyber-dark/50 focus:outline-none focus:ring-2 focus:ring-cyber-neon/50"
                >
                  RETURN
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setStep('confirm')}
                  disabled={selectedTraits.length === 0 || isLoading}
                  className="flex-1 py-2 px-4 bg-cyber-neon/20 border border-cyber-neon 
                           font-mono text-cyber-neon rounded-lg transition-colors duration-200 
                           hover:bg-cyber-neon/30 focus:outline-none focus:ring-2 focus:ring-cyber-neon/50 
                           disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  CONFIRM_SELECTION
                </motion.button>
              </div>
            </div>
          )}

          {step === 'confirm' && (
            <div className="space-y-4">
              <div className="bg-cyber-dark/50 rounded-lg p-4 border border-cyber-neon/30">
                <MatrixText text="ENTITY_SUMMARY" className="text-lg mb-4" />
                <dl className="space-y-2 font-mono">
                  <div className="flex justify-between">
                    <dt className="text-cyber-neon/70">DESIGNATION</dt>
                    <dd className="text-cyber-neon">{name}</dd>
                  </div>
                  <div className="flex justify-between">
                    <dt className="text-cyber-neon/70">TRAIT_COUNT</dt>
                    <dd className="text-cyber-neon">{selectedTraits.length}</dd>
                  </div>
                  <div className="flex justify-between">
                    <dt className="text-cyber-neon/70">CREATION_COST</dt>
                    <dd className="text-cyber-neon">{currentPrice.toString()} ICP</dd>
                  </div>
                </dl>
              </div>
              <div className="flex space-x-4">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setStep('traits')}
                  className="flex-1 py-2 px-4 bg-cyber-darker border border-cyber-neon/30 
                           font-mono text-cyber-neon/70 rounded-lg transition-colors duration-200 
                           hover:bg-cyber-dark/50 focus:outline-none focus:ring-2 focus:ring-cyber-neon/50"
                >
                  RETURN
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleMint}
                  disabled={isLoading}
                  className="flex-1 py-2 px-4 bg-cyber-neon/20 border border-cyber-neon 
                           font-mono text-cyber-neon rounded-lg transition-colors duration-200 
                           hover:bg-cyber-neon/30 focus:outline-none focus:ring-2 focus:ring-cyber-neon/50 
                           disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isLoading ? (
                    <div className="flex items-center justify-center">
                      <svg className="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                      </svg>
                      INITIALIZING...
                    </div>
                  ) : (
                    'GENERATE_ENTITY'
                  )}
                </motion.button>
              </div>
            </div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  );
};