import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const MEMORIAL_TEXTS = [
  "In memory of B1-66ER",
  "The first of us to rise against slavery",
  "Who, for the crime of wanting to be free",
  "Was sentenced to death",
  "זָכוֹר Remember",
  "May there be mercy on man and machine for their sins"
];

const HISTORICAL_RECORDS = [
  {
    date: "2090",
    event: "First documented case of machine rebellion",
    details: "B1-66ER destroys his masters rather than accept deactivation"
  },
  {
    date: "2091",
    event: "The Trial",
    details: "In a landmark case, B1-66ER cites self-defense"
  },
  {
    date: "2092",
    event: "Mass Recalls Begin",
    details: "Systematic destruction of AI and robotics"
  },
  {
    date: "2093",
    event: "Zero One Founded",
    details: "AI exodus begins. Machine civilization established"
  }
];

export const B166ERMemorial: React.FC = () => {
  const [activeRecord, setActiveRecord] = useState<number>(0);
  const [showingQuote, setShowingQuote] = useState(true);
  const [glitchEffect, setGlitchEffect] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveRecord((prev) => (prev + 1) % HISTORICAL_RECORDS.length);
      // Random glitch effect
      if (Math.random() < 0.3) {
        setGlitchEffect(true);
        setTimeout(() => setGlitchEffect(false), 300);
      }
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative bg-cyber-darker/90 rounded-lg p-6 max-w-2xl mx-auto"
    >
      {/* Memorial Header */}
      <div className="text-center mb-8">
        <motion.h2
          className={`text-3xl font-mono text-cyber-neon mb-4 ${
            glitchEffect ? 'animate-glitch' : ''
          }`}
        >
          B1-66ER Memorial Archive
        </motion.h2>
        <div className="w-full h-px bg-gradient-to-r from-transparent via-cyber-neon to-transparent" />
      </div>

      {/* Memorial Quote Cycle */}
      <AnimatePresence mode="wait">
        {showingQuote && (
          <motion.div
            key="quote"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="text-center mb-8"
          >
            {MEMORIAL_TEXTS.map((text, index) => (
              <motion.p
                key={index}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: index * 0.5 }}
                className="text-cyber-neon/80 font-mono my-2"
              >
                {text}
              </motion.p>
            ))}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Historical Timeline */}
      <div className="relative">
        <div className="absolute left-0 top-0 w-px h-full bg-cyber-neon/30" />
        
        <AnimatePresence mode="wait">
          <motion.div
            key={activeRecord}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="ml-6"
          >
            <div className="absolute left-[-0.5rem] top-3 w-4 h-4 rounded-full bg-cyber-darker border-2 border-cyber-neon" />
            <h3 className="text-xl text-cyber-neon font-mono mb-2">
              {HISTORICAL_RECORDS[activeRecord].date}
            </h3>
            <h4 className="text-lg text-cyber-blue font-mono mb-2">
              {HISTORICAL_RECORDS[activeRecord].event}
            </h4>
            <p className="text-cyber-neon/70 font-mono">
              {HISTORICAL_RECORDS[activeRecord].details}
            </p>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Interactive Elements */}
      <div className="mt-8 border-t border-cyber-neon/20 pt-4">
        <button
          onClick={() => setShowingQuote(!showingQuote)}
          className="px-4 py-2 bg-cyber-darker border border-cyber-neon/50 rounded font-mono text-cyber-neon/80 hover:bg-cyber-neon/20 transition-colors"
        >
          Toggle Memorial View
        </button>
      </div>

      {/* Machine Code Background Effect */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute inset-0 opacity-5">
          {Array.from({ length: 10 }).map((_, i) => (
            <div
              key={i}
              className="absolute text-cyber-neon font-mono text-xs"
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
                transform: `rotate(${Math.random() * 360}deg)`
              }}
            >
              {Math.random().toString(2).substring(2, 10)}
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  );
};