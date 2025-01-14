import React from 'react';

export const GridPattern = () => {
  return (
    <svg
      className="absolute inset-0 w-full h-full"
      xmlns="http://www.w3.org/2000/svg"
      width="100%"
      height="100%"
    >
      <defs>
        <pattern
          id="grid"
          width="40"
          height="40"
          patternUnits="userSpaceOnUse"
        >
          <path
            d="M 40 0 L 0 0 0 40"
            fill="none"
            stroke="currentColor"
            strokeWidth="0.5"
            opacity="0.2"
          />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#grid)" />
      
      {/* Ghost in the Shell-inspired circuit patterns */}
      <g stroke="currentColor" strokeWidth="0.5" opacity="0.1">
        <path d="M0 20h100M20 0v100" />
        <circle cx="20" cy="20" r="2" fill="currentColor" />
        <path d="M18 20h4M20 18v4" />
      </g>
    </svg>
  );
};
