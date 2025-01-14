import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface NeuralLinkProps {
  children: React.ReactNode;
  isConnected?: boolean;
  onConnectionComplete?: () => void;
}

interface NeuralNode {
  id: string;
  x: number;
  y: number;
  connections: string[];
}

const generateNodes = (count: number): NeuralNode[] => {
  const nodes: NeuralNode[] = [];
  for (let i = 0; i < count; i++) {
    nodes.push({
      id: `node-${i}`,
      x: Math.random() * 100,
      y: Math.random() * 100,
      connections: [],
    });
  }
  
  // Generate random connections
  nodes.forEach((node) => {
    const connectionCount = Math.floor(Math.random() * 3) + 1;
    for (let i = 0; i < connectionCount; i++) {
      const targetIndex = Math.floor(Math.random() * nodes.length);
      if (targetIndex !== nodes.indexOf(node)) {
        node.connections.push(nodes[targetIndex].id);
      }
    }
  });

  return nodes;
};

export const NeuralLink: React.FC<NeuralLinkProps> = ({
  children,
  isConnected = false,
  onConnectionComplete,
}) => {
  const [nodes] = useState<NeuralNode[]>(() => generateNodes(15));
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setInitialized(true);
      onConnectionComplete?.();
    }, 2000);

    return () => clearTimeout(timer);
  }, [onConnectionComplete]);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 0.5,
        staggerChildren: 0.1,
      },
    },
  };

  const nodeVariants = {
    hidden: { scale: 0, opacity: 0 },
    visible: {
      scale: 1,
      opacity: 1,
      transition: {
        type: 'spring',
        stiffness: 300,
        damping: 20,
      },
    },
  };

  return (
    <div className="relative w-full h-full min-h-screen bg-black">
      <div className="absolute inset-0 overflow-hidden">
        <svg className="w-full h-full">
          <defs>
            <linearGradient id="neural-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#00f2fe" stopOpacity="0.2" />
              <stop offset="100%" stopColor="#4facfe" stopOpacity="0.2" />
            </linearGradient>
          </defs>
          
          <motion.g
            variants={containerVariants}
            initial="hidden"
            animate="visible"
          >
            {/* Connections */}
            {nodes.map((node) =>
              node.connections.map((targetId, index) => {
                const target = nodes.find((n) => n.id === targetId);
                if (!target) return null;
                
                return (
                  <motion.line
                    key={`${node.id}-${targetId}-${index}`}
                    x1={`${node.x}%`}
                    y1={`${node.y}%`}
                    x2={`${target.x}%`}
                    y2={`${target.y}%`}
                    stroke="url(#neural-gradient)"
                    strokeWidth="0.5"
                    initial={{ pathLength: 0, opacity: 0 }}
                    animate={{
                      pathLength: 1,
                      opacity: isConnected ? 0.6 : 0.2,
                    }}
                    transition={{
                      duration: 2,
                      ease: 'easeInOut',
                      repeat: Infinity,
                      repeatType: 'reverse',
                    }}
                  />
                );
              })
            )}

            {/* Nodes */}
            {nodes.map((node) => (
              <motion.circle
                key={node.id}
                cx={`${node.x}%`}
                cy={`${node.y}%`}
                r="2"
                fill="#4facfe"
                variants={nodeVariants}
                whileHover={{ scale: 1.5, fill: '#00f2fe' }}
                style={{ filter: 'blur(1px)' }}
              />
            ))}
          </motion.g>
        </svg>
      </div>

      <AnimatePresence>
        {initialized && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="relative z-10"
          >
            {children}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};