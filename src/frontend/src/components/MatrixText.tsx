import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';

interface MatrixTextProps {
  text: string;
  className?: string;
  delay?: number;
  duration?: number;
  scrambleOnMount?: boolean;
}

export const MatrixText: React.FC<MatrixTextProps> = ({
  text,
  className,
  delay = 0,
  duration = 1,
  scrambleOnMount = true
}) => {
  const [displayText, setDisplayText] = useState(text);
  const [isAnimating, setIsAnimating] = useState(scrambleOnMount);
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*()';

  useEffect(() => {
    if (!isAnimating) return;

    let iterations = 0;
    const maxIterations = 10;
    const interval = (duration * 1000) / maxIterations;

    const timeoutId = setTimeout(() => {
      const intervalId = setInterval(() => {
        const scrambled = text
          .split('')
          .map((char, index) => {
            if (char === ' ') return ' ';
            if (iterations > index) return char;
            return characters[Math.floor(Math.random() * characters.length)];
          })
          .join('');

        setDisplayText(scrambled);
        iterations++;

        if (iterations >= maxIterations) {
          clearInterval(intervalId);
          setDisplayText(text);
          setIsAnimating(false);
        }
      }, interval);

      return () => clearInterval(intervalId);
    }, delay * 1000);

    return () => clearTimeout(timeoutId);
  }, [text, isAnimating, delay, duration]);

  return (
    <AnimatePresence>
      <motion.span
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className={cn("font-mono tracking-wider", className)}
      >
        {displayText}
      </motion.span>
    </AnimatePresence>
  );
};