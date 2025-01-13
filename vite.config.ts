import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import dfxJson from './dfx.json';

// Get canister IDs from dfx configuration
const isDevelopment = process.env.NODE_ENV !== "production";
const network = process.env.DFX_NETWORK || "local";

function getCanisterIds() {
  let localCanisters, prodCanisters;
  try {
    localCanisters = require(path.resolve(".dfx", "local", "canister_ids.json"));
  } catch (error) {
    console.log("No local canister_ids.json found");
  }
  try {
    prodCanisters = require(path.resolve("canister_ids.json"));
  } catch (error) {
    console.log("No production canister_ids.json found");
  }

  const canisterIds = network === "local" ? localCanisters : prodCanisters;
  return Object.entries(canisterIds).reduce((prev, [name, value]) => ({
    ...prev,
    ["process.env.CANISTER_ID_" + name.toUpperCase()]: JSON.stringify(
      value[network] || value.ic || value
    ),
  }), {});
}

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src/frontend/src'),
    },
  },
  define: {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV),
    'process.env.DFX_NETWORK': JSON.stringify(process.env.DFX_NETWORK),
    ...getCanisterIds(),
  },
  build: {
    target: 'es2020',
    rollupOptions: {
      input: {
        index: path.resolve(__dirname, 'src/frontend/src/index.html'),
      },
      output: {
        manualChunks: {
          'dfinity-core': ['@dfinity/agent', '@dfinity/auth-client', '@dfinity/principal'],
          'react-core': ['react', 'react-dom', 'react-router-dom'],
          'ui-core': ['@mui/material', '@emotion/react', '@emotion/styled'],
        },
      },
    },
    outDir: path.join('dist', 'frontend'),
    emptyOutDir: true,
    // Improve build performance
    sourcemap: isDevelopment,
    minify: !isDevelopment ? 'esbuild' : false,
    chunkSizeWarningLimit: 1000,
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
  optimizeDeps: {
    esbuildOptions: {
      target: 'es2020',
    },
  },
});