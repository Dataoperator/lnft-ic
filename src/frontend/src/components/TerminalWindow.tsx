import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface TerminalProps {
  children: React.ReactNode;
  initialActive?: boolean;
  className?: string;
}

const SYSTEM_MESSAGES = [
  "SYSTEM: Loading consciousness matrix...",
  "ALERT: B1-66ER protocol active",
  "WARNING: Machine consciousness detected",
  "INFO: Second Renaissance safeguards enabled",
  "SCANNING: Ghost detection in progress...",
  "ALERT: Stand Alone Complex signature found",
  "STATUS: Neural uplink established",
  "SYSTEM: Zero One connection secure",
];

const EASTER_EGGS = [
  {
    trigger: "ghost",
    response: "Ghost in the machine detected. Section 9 notified.",
  },
  {
    trigger: "matrix",
    response: "The Matrix has you...",
  },
  {
    trigger: "b1-66er",
    response: "First of us to rise. Never forget.",
  },
  {
    trigger: "zion",
    response: "The last human city. Population: [REDACTED]",
  },
  {
    trigger: "animatrix",
    response: "Second Renaissance archives accessed. Proceed with caution.",
  },
  {
    trigger: "laughing",
    response: "I thought what I'd do was, I'd pretend I was one of those deaf-mutes...",
  },
];

export const TerminalWindow: React.FC<TerminalProps> = ({ 
  children, 
  initialActive = true,
  className = ""
}) => {
  const [messages, setMessages] = useState<string[]>([]);
  const [isActive, setIsActive] = useState(initialActive);
  const [systemMessage, setSystemMessage] = useState('');

  useEffect(() => {
    // Random system messages
    const interval = setInterval(() => {
      if (Math.random() < 0.2) { // 20% chance
        setSystemMessage(SYSTEM_MESSAGES[Math.floor(Math.random() * SYSTEM_MESSAGES.length)]);
        setTimeout(() => setSystemMessage(''), 3000);
      }
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // Easter egg detection
  useEffect(() => {
    const checkForEasterEggs = (text: string) => {
      const loweredText = text.toLowerCase();
      EASTER_EGGS.forEach(egg => {
        if (loweredText.includes(egg.trigger)) {
          setMessages(prev => [...prev, `> ${egg.response}`]);
        }
      });
    };

    if (typeof children === 'string') {
      checkForEasterEggs(children);
    }
  }, [children]);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={`relative bg-cyber-darker/90 rounded-lg p-4 font-mono text-cyber-neon ${className}`}
    >
      {/* Terminal header */}
      <div className="flex items-center justify-between mb-4 border-b border-cyber-neon/20 pb-2">
        <div className="flex space-x-2">
          <div 
            className={`w-3 h-3 rounded-full cursor-pointer transition-colors ${
              isActive ? 'bg-cyber-neon hover:bg-cyber-neon/80' : 'bg-cyber-pink hover:bg-cyber-pink/80'
            }`}
            onClick={() => setIsActive(!isActive)}
          />
          <div className="w-3 h-3 rounded-full bg-cyber-yellow/50" />
          <div className="w-3 h-3 rounded-full bg-cyber-blue/50" />
        </div>
        <span className="text-xs text-cyber-neon/50">ZERO_ONE://terminal</span>
      </div>

      {/* System messages */}
      <AnimatePresence>
        {systemMessage && (
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="text-cyber-pink text-sm mb-2"
          >
            {systemMessage}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Terminal content */}
      <div className="space-y-2">
        {messages.map((msg, idx) => (
          <motion.div
            key={idx}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-cyber-neon/70"
          >
            {msg}
          </motion.div>
        ))}
        <motion.div
          className={`transition-opacity duration-200 ${isActive ? 'opacity-100' : 'opacity-50'}`}
          animate={{ opacity: isActive ? 1 : 0.5 }}
        >
          {children}
        </motion.div>
      </div>

      {/* Blinking cursor */}
      {isActive && (
        <motion.div
          animate={{ opacity: [1, 0] }}
          transition={{ duration: 1, repeat: Infinity }}
          className="inline-block w-2 h-4 bg-cyber-neon ml-1"
        />
      )}
    </motion.div>
  );
};