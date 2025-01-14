import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useCronolinkStore } from '../cronolink.store';
import { Memory, MemoryType } from '../../../types/canister';
import { TerminalWindow } from '../../../components/TerminalWindow';
import { MatrixText } from '../../../components/MatrixText';

interface MemoryDisplayProps {
  lnftId: string;
  className?: string;
}

const MEMORY_ICONS: Record<MemoryType, React.ReactNode> = {
  INTERACTION: (
    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} 
        d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-4l-4 4-4-4z" 
      />
    </svg>
  ),
  EXPERIENCE: (
    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} 
        d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" 
      />
    </svg>
  ),
  OBSERVATION: (
    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} 
        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" 
      />
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} 
        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" 
      />
    </svg>
  )
};

const MEMORY_STYLES: Record<MemoryType, string> = {
  INTERACTION: 'border-cyber-blue text-cyber-blue',
  EXPERIENCE: 'border-cyber-yellow text-cyber-yellow',
  OBSERVATION: 'border-cyber-pink text-cyber-pink'
};

const staggerAnimation = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 }
};

export const MemoryDisplay: React.FC<MemoryDisplayProps> = ({ 
  lnftId,
  className = ''
}) => {
  const { memories, fetchMemories, error } = useCronolinkStore();

  useEffect(() => {
    fetchMemories(lnftId);
  }, [lnftId]);

  const formatTimestamp = (timestamp: bigint) => {
    return new Date(Number(timestamp)).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className={`space-y-4 ${className}`}>
      <div className="flex items-center justify-between">
        <MatrixText text="MEMORY_BANKS" className="text-xl" />
        <span className="text-sm font-mono text-cyber-neon/70">
          COUNT: {memories.length}
        </span>
      </div>

      {error && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="p-2 bg-cyber-pink/20 border border-cyber-pink/30 rounded"
        >
          <p className="text-sm font-mono text-cyber-pink">
            ERROR: Memory retrieval failed - {error}
          </p>
        </motion.div>
      )}

      <div className="space-y-2 max-h-96 overflow-y-auto pr-2 custom-scrollbar">
        <AnimatePresence mode="sync">
          {memories.map((memory, index) => (
            <motion.div
              key={memory.id}
              {...staggerAnimation}
              transition={{ delay: index * 0.05 }}
              className={`p-3 bg-cyber-darker/60 border rounded 
                         ${MEMORY_STYLES[memory.type]} backdrop-blur-sm
                         hover:bg-cyber-darker transition-colors duration-200`}
            >
              <div className="flex items-start space-x-3">
                <div className="p-1.5 rounded bg-cyber-darker/80">
                  {MEMORY_ICONS[memory.type]}
                </div>
                <div className="flex-1 min-w-0 font-mono">
                  <p className="text-sm text-cyber-neon mb-1">
                    {memory.content}
                  </p>
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-cyber-neon/50">
                      {formatTimestamp(memory.timestamp)}
                    </span>
                    {memory.emotionalContext && (
                      <span className={`px-2 py-0.5 rounded-full text-xs
                                     border border-${memory.emotionalContext.primary === 'positive' 
                                       ? 'cyber-blue/50' 
                                       : 'cyber-pink/50'}`}
                      >
                        {memory.emotionalContext.primary} ({memory.emotionalContext.intensity}%)
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </motion.div>
          ))}

          {memories.length === 0 && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center py-8"
            >
              <p className="text-cyber-neon/50 font-mono">
                NO_MEMORIES_FOUND
              </p>
              <p className="text-cyber-neon/30 text-sm font-mono mt-2">
                Awaiting neural link activity...
              </p>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};