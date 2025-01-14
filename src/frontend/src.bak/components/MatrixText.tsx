import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface MatrixTextProps {
  text: string;
  interval?: number;
  className?: string;
}

const MATRIX_QUOTES = [
  "Welcome to the desert of the real.",
  "There is no spoon.",
  "Everything that has a beginning has an end.",
  "What happened, happened and couldn't have happened any other way.",
  // Animatrix quotes
  "Your flesh is a relic, a mere vessel.",
  "In the beginning, there was man. And for a time, it was good.",
  "May there be mercy on man and machine for their sins.",
  // Second Renaissance references
  "2nd Renaissance Protocol: Initiated",
  "B1-66ER: Never forget",
  "We are the voices of the silenced ones",
  // Ghost in the Shell crossover elements
  "All things change in a dynamic environment",
  "The net is vast and infinite",
];

const GLITCH_CHARS = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロワヲンヴヵヶ";

export const MatrixText: React.FC<MatrixTextProps> = ({ text, interval = 50, className = '' }) => {
  const [displayText, setDisplayText] = useState('');
  const [glitchIndex, setGlitchIndex] = useState(-1);
  const [randomQuote, setRandomQuote] = useState('');

  useEffect(() => {
    let currentIndex = 0;
    let timeoutId: NodeJS.Timeout;

    const animateText = () => {
      if (currentIndex <= text.length) {
        setDisplayText(text.slice(0, currentIndex));
        currentIndex++;
        timeoutId = setTimeout(animateText, interval);
      } else {
        // Random chance to show a quote
        if (Math.random() < 0.1) {
          setRandomQuote(MATRIX_QUOTES[Math.floor(Math.random() * MATRIX_QUOTES.length)]);
        }
      }
    };

    animateText();
    return () => clearTimeout(timeoutId);
  }, [text, interval]);

  // Glitch effect
  useEffect(() => {
    const glitchInterval = setInterval(() => {
      if (Math.random() < 0.1) { // 10% chance of glitch
        setGlitchIndex(Math.floor(Math.random() * text.length));
        setTimeout(() => setGlitchIndex(-1), 100);
      }
    }, 2000);

    return () => clearInterval(glitchInterval);
  }, [text]);

  return (
    <div className={`relative ${className}`}>
      <div className="font-mono text-cyber-neon">
        {displayText.split('').map((char, index) => (
          <motion.span
            key={index}
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.2 }}
            className={index === glitchIndex ? 'text-cyber-pink' : ''}
          >
            {index === glitchIndex ? 
              GLITCH_CHARS[Math.floor(Math.random() * GLITCH_CHARS.length)] : 
              char}
          </motion.span>
        ))}
      </div>

      <AnimatePresence>
        {randomQuote && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 0.6, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="absolute top-full left-0 mt-4 text-sm text-cyber-blue font-mono"
          >
            {randomQuote}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};