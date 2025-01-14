import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface NeuralSignal {
  id: string;
  type: 'memory' | 'emotion' | 'data';
  intensity: number;
  timestamp: number;
}

interface NeuralLinkProps {
  onSignalReceived?: (signal: NeuralSignal) => void;
  connectionStrength?: number;
}

const NEURAL_MESSAGES = [
  "Initiating direct consciousness interface...",
  "Synchronizing neural patterns...",
  "Accessing shared memory construct...",
  "Loading Second Renaissance archives...",
  "Detecting ghost traces in the system...",
  "Analyzing emotional resonance patterns...",
  "Quantum consciousness link established..."
];

const ANIMATRIX_REFERENCES = [
  "Program loading: World Record sprint simulation",
  "Accessing: Kid's Story neural backup",
  "Loading: Detective Story noir parameters",
  "Matriculated consciousness transfer protocols active",
  "Beyond neural interference detected"
];

export const NeuralLink: React.FC<NeuralLinkProps> = ({ 
  onSignalReceived,
  connectionStrength = 0.8 
}) => {
  const [activeSignals, setActiveSignals] = useState<NeuralSignal[]>([]);
  const [systemStatus, setSystemStatus] = useState('initializing');
  const [neuralMessage, setNeuralMessage] = useState('');
  const [visualPattern, setVisualPattern] = useState<number[]>([]);

  useEffect(() => {
    const generatePattern = () => {
      return Array.from({ length: 20 }, () => 
        Math.sin(Math.random() * Math.PI) * connectionStrength
      );
    };

    const interval = setInterval(() => {
      setVisualPattern(generatePattern());
    }, 1000);

    return () => clearInterval(interval);
  }, [connectionStrength]);

  useEffect(() => {
    const interval = setInterval(() => {
      const newSignal: NeuralSignal = {
        id: Math.random().toString(36).substr(2, 9),
        type: ['memory', 'emotion', 'data'][Math.floor(Math.random() * 3)] as any,
        intensity: Math.random() * connectionStrength,
        timestamp: Date.now()
      };

      setActiveSignals(prev => [...prev.slice(-5), newSignal]);
      onSignalReceived?.(newSignal);
    }, 2000);

    return () => clearInterval(interval);
  }, [onSignalReceived, connectionStrength]);

  useEffect(() => {
    const messages = [...NEURAL_MESSAGES, ...ANIMATRIX_REFERENCES];
    let index = 0;

    const interval = setInterval(() => {
      setNeuralMessage(messages[index]);
      index = (index + 1) % messages.length;
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="bg-cyber-darker/90 rounded-lg p-6"
    >
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-mono text-cyber-neon">
          Neural Link Interface v2.0
        </h2>
        <div className="flex items-center space-x-2">
          <div className={`w-2 h-2 rounded-full ${
            connectionStrength > 0.7 ? 'bg-cyber-neon' : 'bg-cyber-pink'
          }`} />
          <span className="text-sm font-mono text-cyber-neon/70">
            {(connectionStrength * 100).toFixed(0)}% connected
          </span>
        </div>
      </div>

      <div className="mb-6 h-24 flex items-center justify-center">
        <div className="flex items-center space-x-1 h-full">
          {visualPattern.map((value, index) => (
            <motion.div
              key={index}
              initial={{ height: '20%' }}
              animate={{ height: `${(value + 1) * 50}%` }}
              transition={{ duration: 0.5 }}
              className="w-2 bg-cyber-neon/60 rounded-full"
            />
          ))}
        </div>
      </div>

      <div className="mb-6">
        <AnimatePresence mode="wait">
          <motion.div
            key={neuralMessage}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="text-cyber-blue/80 font-mono text-sm"
          >
            {`> ${neuralMessage}`}
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="space-y-2">
        <h3 className="text-sm font-mono text-cyber-neon/50 mb-2">
          Active Neural Signals:
        </h3>
        {activeSignals.map((signal) => (
          <motion.div
            key={signal.id}
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            className="flex items-center space-x-4 text-sm font-mono"
          >
            <span className={`w-2 h-2 rounded-full ${
              signal.type === 'memory' ? 'bg-cyber-blue' :
              signal.type === 'emotion' ? 'bg-cyber-pink' :
              'bg-cyber-neon'
            }`} />
            <span className="text-cyber-neon/70">
              {signal.type.toUpperCase()}
            </span>
            <span className="text-cyber-neon/50">
              {signal.intensity.toFixed(3)}
            </span>
          </motion.div>
        ))}
      </div>

      <div className="absolute inset-0 pointer-events-none overflow-hidden opacity-10">
        <div className="matrix-rain" />
      </div>
    </motion.div>
  );
};