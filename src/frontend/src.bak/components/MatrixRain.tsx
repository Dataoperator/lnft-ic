import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';

const createMatrixRain = (canvas: HTMLCanvasElement) => {
  const scene = new THREE.Scene();
  const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
  const renderer = new THREE.WebGLRenderer({ canvas, alpha: true });

  // Matrix characters
  const chars = 'ゴーストシェル012345 GHOST_IN_THE_SHELL あなたを笑う男 LAUGHING_MAN';
  const fontSize = 16;
  const columns = Math.floor(window.innerWidth / fontSize);
  const drops: number[] = new Array(columns).fill(1);

  // Create texture from canvas
  const textCanvas = document.createElement('canvas');
  const textCtx = textCanvas.getContext('2d')!;
  textCanvas.width = 1024;
  textCanvas.height = 1024;
  textCtx.font = `${fontSize}px "Share Tech Mono"`;
  textCtx.fillStyle = '#00ff9f';

  const drawText = () => {
    textCtx.clearRect(0, 0, textCanvas.width, textCanvas.height);
    drops.forEach((drop, i) => {
      const text = chars[Math.floor(Math.random() * chars.length)];
      const x = i * fontSize;
      const y = drop * fontSize;
      textCtx.fillText(text, x, y);
      
      if (y > canvas.height && Math.random() > 0.975) {
        drops[i] = 0;
      }
      drops[i]++;
    });
  };

  // Laughing Man easter egg
  const laughingManSymbol = new Image();
  laughingManSymbol.src = 'data:image/svg+xml,' + encodeURIComponent(`
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="45" fill="none" stroke="#00ff9f" stroke-width="2"/>
      <text x="50" y="55" font-family="monospace" font-size="8" fill="#00ff9f" text-anchor="middle">
        I thought what I'd do was, I'd pretend I was one of those deaf-mutes
      </text>
    </svg>
  `);

  // Add occasional Laughing Man symbol
  const addLaughingMan = () => {
    if (Math.random() < 0.001) { // 0.1% chance per frame
      const x = Math.random() * canvas.width;
      const y = Math.random() * canvas.height;
      textCtx.drawImage(laughingManSymbol, x, y, 100, 100);
    }
  };

  // Animation loop
  const animate = () => {
    drawText();
    addLaughingMan();
    renderer.render(scene, camera);
    requestAnimationFrame(animate);
  };

  // Start animation
  animate();

  // Handle resize
  const handleResize = () => {
    const width = window.innerWidth;
    const height = window.innerHeight;
    renderer.setSize(width, height);
    camera.updateProjectionMatrix();
  };

  window.addEventListener('resize', handleResize);
  handleResize();

  // Cleanup
  return () => {
    window.removeEventListener('resize', handleResize);
    renderer.dispose();
  };
};

export const MatrixRain: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!canvasRef.current) return;
    const cleanup = createMatrixRain(canvasRef.current);
    return cleanup;
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className="fixed top-0 left-0 w-full h-full pointer-events-none"
      style={{ zIndex: 0, opacity: 0.7 }}
    />
  );
};