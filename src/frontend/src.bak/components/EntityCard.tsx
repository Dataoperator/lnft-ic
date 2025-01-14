import React, { useRef, useEffect } from 'react';
import { motion, useMotionValue, useTransform, useAnimation } from 'framer-motion';
import * as THREE from 'three';

interface EntityCardProps {
  id: string;
  name: string;
  consciousness: number;
  memories: string[];
  traits: string[];
  emotionalState: string;
}

export const EntityCard = ({ id, name, consciousness, memories, traits, emotionalState }: EntityCardProps) => {
  const cardRef = useRef<HTMLDivElement>(null);
  const controls = useAnimation();
  
  // Holographic effect values
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);
  const rotateX = useTransform(mouseY, [-0.5, 0.5], ["-15deg", "15deg"]);
  const rotateY = useTransform(mouseX, [-0.5, 0.5], ["-15deg", "15deg"]);

  // Ghost lines effect
  useEffect(() => {
    if (!cardRef.current) return;
    
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d')!;
    const width = cardRef.current.offsetWidth;
    const height = cardRef.current.offsetHeight;
    
    canvas.width = width;
    canvas.height = height;
    
    const drawGhostLines = () => {
      ctx.clearRect(0, 0, width, height);
      ctx.strokeStyle = '#00ff9f20';
      
      // Draw glitch lines
      for (let i = 0; i < 5; i++) {
        const y = Math.random() * height;
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        ctx.stroke();
      }
    };

    const interval = setInterval(drawGhostLines, 2000);
    return () => clearInterval(interval);
  }, []);

  // Handle mouse movement for holographic effect
  const handleMouseMove = (event: React.MouseEvent<HTMLDivElement>) => {
    const rect = cardRef.current?.getBoundingClientRect();
    if (!rect) return;
    
    const x = (event.clientX - rect.left) / rect.width - 0.5;
    const y = (event.clientY - rect.top) / rect.height - 0.5;
    
    mouseX.set(x);
    mouseY.set(y);
  };

  // Laughing Man easter egg - rare random appearance
  const [showLaughingMan, setShowLaughingMan] = React.useState(false);
  useEffect(() => {
    const interval = setInterval(() => {
      if (Math.random() < 0.01) { // 1% chance every check
        setShowLaughingMan(true);
        setTimeout(() => setShowLaughingMan(false), 2000);
      }
    }, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <motion.div
      ref={cardRef}
      className="relative w-72 h-96 rounded-lg overflow-hidden"
      style={{
        rotateX,
        rotateY,
        transformStyle: "preserve-3d",
        perspective: 1000,
      }}
      whileHover={{ scale: 1.05 }}
      onMouseMove={handleMouseMove}
      onMouseLeave={() => {
        mouseX.set(0);
        mouseY.set(0);
      }}
    >
      {/* Holographic background */}
      <div className="absolute inset-0 bg-gradient-to-br from-cyber-dark/80 to-cyber-darker/80 backdrop-blur-sm">
        <div className="absolute inset-0 bg-grid-pattern opacity-10" />
      </div>

      {/* Ghost in the Shell-style interface */}
      <div className="relative p-4 h-full flex flex-col">
        {/* Header */}
        <div className="border-b border-cyber-neon/30 pb-2 mb-4">
          <h3 className="text-xl font-mono text-cyber-neon">
            {`<entity_${id}>`}
          </h3>
          <p className="text-sm font-mono text-cyber-neon/70">
            {`consciousness_level: ${consciousness}%`}
          </p>
        </div>

        {/* Memory fragments */}
        <div className="flex-grow space-y-2 mb-4">
          <p className="text-xs font-mono text-cyber-neon/50">MEMORY_FRAGMENTS:</p>
          <div className="space-y-1">
            {memories.map((memory, index) => (
              <div key={index} className="text-xs font-mono text-cyber-neon/70 truncate">
                {`> ${memory}`}
              </div>
            ))}
          </div>
        </div>

        {/* Traits */}
        <div className="mb-4">
          <p className="text-xs font-mono text-cyber-neon/50">TRAITS:</p>
          <div className="flex flex-wrap gap-1 mt-1">
            {traits.map((trait, index) => (
              <span 
                key={index}
                className="px-2 py-1 rounded-sm text-xs font-mono bg-cyber-neon/10 text-cyber-neon/90"
              >
                {trait}
              </span>
            ))}
          </div>
        </div>

        {/* Emotional state */}
        <div className="absolute bottom-4 right-4">
          <p className="text-xs font-mono text-cyber-neon/70">
            {`emotional_state: ${emotionalState}`}
          </p>
        </div>

        {/* Laughing Man easter egg */}
        {showLaughingMan && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 flex items-center justify-center bg-black/80 z-10"
          >
            <div className="w-24 h-24 relative">
              <div className="absolute inset-0 animate-spin-slow">
                <svg viewBox="0 0 100 100" className="w-full h-full">
                  <path
                    d="M50 10 A40 40 0 1 1 49.9999 10"
                    fill="none"
                    stroke="#00ff9f"
                    strokeWidth="2"
                  />
                  <text
                    x="50"
                    y="50"
                    fontSize="4"
                    fill="#00ff9f"
                    textAnchor="middle"
                    className="font-mono"
                  >
                    I thought what I'd do was, I'd pretend I was one of those deaf-mutes
                  </text>
                </svg>
              </div>
            </div>
          </motion.div>
        )}
      </div>
    </motion.div>
  );
};
