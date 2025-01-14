import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface GridPatternProps {
  className?: string;
  size?: number;
  spacing?: number;
  dotSize?: number;
  dotColor?: string;
}

export const GridPattern: React.FC<GridPatternProps> = ({
  className,
  size = 32,
  spacing = 24,
  dotSize = 1.5,
  dotColor = 'rgb(0 255 255 / 0.3)'
}) => {
  return (
    <div className={cn('absolute inset-0 z-0 overflow-hidden', className)}>
      <svg className="absolute h-full w-full" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <pattern
            id="grid-pattern"
            width={spacing}
            height={spacing}
            patternUnits="userSpaceOnUse"
          >
            <circle
              cx={spacing / 2}
              cy={spacing / 2}
              r={dotSize}
              fill={dotColor}
            />
          </pattern>
        </defs>
        <motion.rect
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1.5 }}
          width="100%"
          height="100%"
          fill="url(#grid-pattern)"
        />
      </svg>
    </div>
  );
};