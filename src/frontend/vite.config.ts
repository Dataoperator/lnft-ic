import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    plugins: [react()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@components': path.resolve(__dirname, './src/components'),
        '@features': path.resolve(__dirname, './src/features'),
        '@lib': path.resolve(__dirname, './src/lib'),
        '@utils': path.resolve(__dirname, './src/utils'),
        '@declarations': path.resolve(__dirname, './src/declarations'),
      },
    },
    define: {
      'process.env.DFX_NETWORK': JSON.stringify(env.VITE_DFX_NETWORK || 'local'),
      'process.env.NODE_ENV': JSON.stringify(env.NODE_ENV || 'development'),
      'process.env.INTERNET_IDENTITY_URL': JSON.stringify(env.VITE_INTERNET_IDENTITY_URL),
      'process.env.IC_HOST': JSON.stringify(env.VITE_IC_HOST),
      global: 'window',
    },
    build: {
      target: 'esnext',
      outDir: 'dist',
      emptyOutDir: true,
      sourcemap: true,
    },
    optimizeDeps: {
      esbuildOptions: {
        define: {
          global: 'globalThis',
        },
      },
    },
    server: {
      proxy: {
        '/api': {
          target: env.VITE_IC_HOST || 'http://127.0.0.1:8001',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
  };
});