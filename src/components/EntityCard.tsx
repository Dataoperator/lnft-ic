import { motion } from 'framer-motion';
import { LNFT } from '../types/canister';

interface EntityCardProps extends LNFT {}

export const EntityCard = ({ id, consciousness, memories, traits, emotionalState }: EntityCardProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="relative p-6 bg-black/80 rounded-lg border border-cyan-500/50 shadow-lg hover:shadow-cyan-500/20"
    >
      <div className="flex flex-col space-y-4">
        <div className="text-cyan-500 text-xl">ID: {id}</div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <span className="text-cyan-300">Consciousness:</span>
            <span className="ml-2 text-white">{consciousness}%</span>
          </div>
          <div>
            <span className="text-cyan-300">Emotional State:</span>
            <span className="ml-2 text-white">{emotionalState.primary}</span>
            <span className="ml-1 text-cyan-400">({emotionalState.intensity}%)</span>
          </div>
        </div>
        
        <div className="border-t border-cyan-500/30 pt-4">
          <h3 className="text-cyan-400 mb-2">Traits</h3>
          <div className="grid grid-cols-2 gap-2">
            {traits.map((trait, index) => (
              <motion.div
                key={`${trait.type}-${index}`}
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                transition={{ delay: index * 0.1 }}
                className={`text-sm p-2 rounded ${getRarityColor(trait.rarity)}`}
              >
                <span className="font-medium">{trait.type}:</span> {trait.value}
              </motion.div>
            ))}
          </div>
        </div>

        {memories && memories.length > 0 && (
          <div className="border-t border-cyan-500/30 pt-4">
            <h3 className="text-cyan-400 mb-2">Recent Memories</h3>
            <div className="space-y-2">
              {memories.slice(0, 3).map((memory) => (
                <motion.div
                  key={memory.id}
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-sm text-white/70 bg-black/40 p-2 rounded"
                >
                  {memory.content}
                </motion.div>
              ))}
            </div>
          </div>
        )}
      </div>
    </motion.div>
  );
};

const getRarityColor = (rarity: string): string => {
  switch (rarity) {
    case 'LEGENDARY':
      return 'bg-yellow-500/20 text-yellow-300';
    case 'RARE':
      return 'bg-purple-500/20 text-purple-300';
    case 'UNCOMMON':
      return 'bg-blue-500/20 text-blue-300';
    default:
      return 'bg-gray-500/20 text-gray-300';
  }
};