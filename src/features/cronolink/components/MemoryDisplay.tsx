import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import type { Memory, MemoryType } from '../../../types/canister';
import { CronolinkStore } from '../cronolink.store';

interface MemoryDisplayProps {
  lnftId: string;
  onMemorySelect?: (memory: Memory) => void;
}

export const MemoryDisplay: React.FC<MemoryDisplayProps> = ({ lnftId, onMemorySelect }) => {
  const [memories, setMemories] = useState<Memory[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const cronolinkStore = new CronolinkStore();

  useEffect(() => {
    fetchMemories();
  }, [lnftId]);

  const fetchMemories = async () => {
    try {
      setLoading(true);
      setError(null);
      const fetchedMemories = await cronolinkStore.getMemories(lnftId);
      setMemories(fetchedMemories.sort((a, b) => Number(b.timestamp - a.timestamp)));
    } catch (err) {
      setError('Failed to load memories');
      console.error('Error fetching memories:', err);
    } finally {
      setLoading(false);
    }
  };

  const getMemoryTypeColor = (type: MemoryType): string => {
    switch (type) {
      case MemoryType.INTERACTION:
        return 'bg-blue-500/20 text-blue-300';
      case MemoryType.EXPERIENCE:
        return 'bg-green-500/20 text-green-300';
      case MemoryType.OBSERVATION:
        return 'bg-purple-500/20 text-purple-300';
      default:
        return 'bg-gray-500/20 text-gray-300';
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-48">
        <div className="text-cyan-500">Loading memories...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex justify-center items-center h-48">
        <div className="text-red-500">{error}</div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <h3 className="text-xl text-cyan-400 mb-4">Memory Archive</h3>
      <div className="grid gap-4">
        {memories.map((memory) => (
          <motion.div
            key={memory.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0 }}
            whileHover={{ scale: 1.02 }}
            onClick={() => onMemorySelect?.(memory)}
            className="bg-black/60 border border-cyan-500/30 rounded-lg p-4 cursor-pointer
                     hover:border-cyan-500/50 transition-all duration-200"
          >
            <div className="flex justify-between items-start mb-2">
              <span className="text-sm text-cyan-300">
                {new Date(Number(memory.timestamp) / 1000000).toLocaleString()}
              </span>
              <span className={`text-xs px-2 py-1 rounded ${getMemoryTypeColor(memory.type)}`}>
                {memory.type}
              </span>
            </div>
            <p className="text-white/90">{memory.content}</p>
            {memory.emotionalContext && (
              <div className="mt-2 text-sm">
                <span className="text-purple-400">Emotional Context: </span>
                <span className="text-purple-300">
                  {memory.emotionalContext.primary} ({memory.emotionalContext.intensity}%)
                </span>
              </div>
            )}
          </motion.div>
        ))}
      </div>
    </div>
  );
};