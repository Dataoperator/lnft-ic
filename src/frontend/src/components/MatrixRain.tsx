import React, { useEffect, useRef, memo } from 'react';
import * as THREE from 'three';

interface MatrixRainConfig {
  fontSize: number;
  color: string;
  density: number;
  speed: number;
}

const DEFAULT_CONFIG: MatrixRainConfig = {
  fontSize: 16,
  color: '#00ff9f',
  density: 0.975,
  speed: 1
};

const createMatrixRain = (canvas: HTMLCanvasElement, config: MatrixRainConfig = DEFAULT_CONFIG) => {
  // Performance optimization: Create objects once
  const scene = new THREE.Scene();
  const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
  const renderer = new THREE.WebGLRenderer({ 
    canvas, 
    alpha: true,
    antialias: false,
    powerPreference: 'high-performance'
  });

  const chars = new Uint8Array([
    ...Array.from('ゴーストシェル012345 GHOST_IN_THE_SHELL あなたを笑う男 LAUGHING_MAN').map(c => c.charCodeAt(0))
  ]);

  let columns = Math.floor(window.innerWidth / config.fontSize);
  let dropsArray = new Float32Array(columns).fill(1);

  // Create and configure texture canvas
  const textCanvas = document.createElement('canvas');
  const textCtx = textCanvas.getContext('2d', {
    alpha: true,
    desynchronized: true
  })!;
  
  textCanvas.width = Math.min(2048, window.innerWidth);
  textCanvas.height = Math.min(2048, window.innerHeight);
  
  textCtx.font = `${config.fontSize}px "Share Tech Mono"`;
  textCtx.fillStyle = config.color;

  const charBuffer = new Uint8Array(columns);

  const drawText = () => {
    textCtx.clearRect(0, 0, textCanvas.width, textCanvas.height);
    
    for (let i = 0; i < dropsArray.length; i++) {
      charBuffer[i] = chars[Math.floor(Math.random() * chars.length)];
      const x = i * config.fontSize;
      const y = dropsArray[i] * config.fontSize;
      
      textCtx.fillText(String.fromCharCode(charBuffer[i]), x, y);
      
      if (y > canvas.height && Math.random() > config.density) {
        dropsArray[i] = 0;
      }
      dropsArray[i] += config.speed;
    }
  };

  // Laughing Man easter egg
  const laughingManSymbol = new Image();
  const svgString = encodeURIComponent(`
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="45" fill="none" stroke="${config.color}" stroke-width="2"/>
      <text x="50" y="55" font-family="monospace" font-size="8" fill="${config.color}" text-anchor="middle">
        I thought what I'd do was, I'd pretend I was one of those deaf-mutes
      </text>
    </svg>
  `);
  laughingManSymbol.src = 'data:image/svg+xml,' + svgString;

  const addLaughingMan = () => {
    if (Math.random() < 0.001) {
      const x = Math.random() * (canvas.width - 100);
      const y = Math.random() * (canvas.height - 100);
      textCtx.drawImage(laughingManSymbol, x, y, 100, 100);
    }
  };

  let lastTime = 0;
  const FRAME_RATE = 30;
  const FRAME_TIME = 1000 / FRAME_RATE;

  const animate = (currentTime: number) => {
    if (currentTime - lastTime > FRAME_TIME) {
      drawText();
      addLaughingMan();
      renderer.render(scene, camera);
      lastTime = currentTime;
    }
    animationFrameId = requestAnimationFrame(animate);
  };

  let resizeTimeout: number;
  const handleResize = () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = window.setTimeout(() => {
      const width = window.innerWidth;
      const height = window.innerHeight;
      renderer.setSize(width, height);
      camera.updateProjectionMatrix();
      
      // Update columns and drops arrays
      columns = Math.floor(width / config.fontSize);
      const newDrops = new Float32Array(columns).fill(1);
      newDrops.set(dropsArray.slice(0, Math.min(dropsArray.length, columns)));
      dropsArray = newDrops;
    }, 250);
  };

  window.addEventListener('resize', handleResize);
  handleResize();

  let animationFrameId = requestAnimationFrame(animate);

  return () => {
    window.removeEventListener('resize', handleResize);
    clearTimeout(resizeTimeout);
    cancelAnimationFrame(animationFrameId);
    renderer.dispose();
    textCanvas.remove();
  };
};

export const MatrixRain: React.FC<Partial<MatrixRainConfig>> = memo(({ 
  fontSize,
  color,
  density,
  speed 
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const config = {
    ...DEFAULT_CONFIG,
    fontSize: fontSize ?? DEFAULT_CONFIG.fontSize,
    color: color ?? DEFAULT_CONFIG.color,
    density: density ?? DEFAULT_CONFIG.density,
    speed: speed ?? DEFAULT_CONFIG.speed
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const cleanup = createMatrixRain(canvas, config);
    return cleanup;
  }, [config.fontSize, config.color, config.density, config.speed]);

  return (
    <canvas
      ref={canvasRef}
      className="fixed top-0 left-0 w-full h-full pointer-events-none"
      style={{ 
        zIndex: 0, 
        opacity: 0.7,
        imageRendering: 'pixelated'
      }}
    />
  );
});

MatrixRain.displayName = 'MatrixRain';