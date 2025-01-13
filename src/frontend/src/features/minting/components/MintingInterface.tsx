import React, { useEffect, useState } from 'react';
import { useMintingStore } from '../minting.store';
import { Trait, TraitType, Rarity } from '../../../types';

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
        return '👤';
      case TraitType.Mental:
        return '🧠';
      case TraitType.Special:
        return '✨';
      case TraitType.Skill:
        return '⚡';
      case TraitType.Event:
        return '🎯';
      default:
        return '❓';
    }
  };

  const getRarityColor = (rarity: Rarity) => {
    switch (rarity) {
      case Rarity.Common:
        return 'bg-gray-100 text-gray-800 border-gray-200';
      case Rarity.Uncommon:
        return 'bg-green-100 text-green-800 border-green-200';
      case Rarity.Rare:
        return 'bg-blue-100 text-blue-800 border-blue-200';
      case Rarity.Epic:
        return 'bg-purple-100 text-purple-800 border-purple-200';
      case Rarity.Legendary:
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case Rarity.Event:
        return 'bg-red-100 text-red-800 border-red-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  return (
    <div className="max-w-2xl mx-auto bg-white rounded-lg shadow-lg overflow-hidden">
      <div className="p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Mint Your LNFT</h2>
        
        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-sm text-red-600">{error}</p>
          </div>
        )}

        {step === 'name' && (
          <div className="space-y-4">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                Name your LNFT
              </label>
              <input
                type="text"
                id="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="Enter a name..."
                disabled={isLoading}
              />
            </div>
            <button
              onClick={() => setStep('traits')}
              disabled={!name.trim() || isLoading}
              className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
            >
              Continue
            </button>
          </div>
        )}

        {step === 'traits' && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              {traits.map((trait) => (
                <div
                  key={trait.id}
                  onClick={() => handleTraitSelection(trait.id)}
                  className={`p-4 rounded-lg border-2 cursor-pointer transition-colors ${
                    selectedTraits.includes(trait.id)
                      ? 'ring-2 ring-blue-500'
                      : ''
                  } ${getRarityColor(trait.rarity)}`}
                >
                  <div className="flex items-center space-x-2">
                    <span className="text-2xl">{getTraitTypeIcon(trait.type)}</span>
                    <span className="font-medium">{trait.name}</span>
                  </div>
                  <div className="mt-2 text-xs">
                    <span className="uppercase tracking-wide">{trait.rarity}</span>
                  </div>
                </div>
              ))}
            </div>
            <div className="flex space-x-4">
              <button
                onClick={() => setStep('name')}
                className="flex-1 py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Back
              </button>
              <button
                onClick={() => setStep('confirm')}
                disabled={selectedTraits.length === 0 || isLoading}
                className="flex-1 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
              >
                Continue
              </button>
            </div>
          </div>
        )}

        {step === 'confirm' && (
          <div className="space-y-4">
            <div className="bg-gray-50 rounded-lg p-4">
              <h3 className="text-lg font-medium text-gray-900">Summary</h3>
              <dl className="mt-4 space-y-2">
                <div className="flex justify-between">
                  <dt className="text-sm font-medium text-gray-500">Name</dt>
                  <dd className="text-sm text-gray-900">{name}</dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-sm font-medium text-gray-500">Selected Traits</dt>
                  <dd className="text-sm text-gray-900">{selectedTraits.length}</dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-sm font-medium text-gray-500">Price</dt>
                  <dd className="text-sm text-gray-900">{currentPrice.toString()} ICP</dd>
                </div>
              </dl>
            </div>
            <div className="flex space-x-4">
              <button
                onClick={() => setStep('traits')}
                className="flex-1 py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Back
              </button>
              <button
                onClick={handleMint}
                disabled={isLoading}
                className="flex-1 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
              >
                {isLoading ? (
                  <div className="flex items-center justify-center">
                    <svg className="animate-spin h-5 w-5 mr-3 text-white" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    Minting...
                  </div>
                ) : (
                  'Mint LNFT'
                )}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};