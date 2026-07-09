import path from 'node:path';
import { defineConfig } from 'vite';

export default defineConfig({
  resolve: {
    alias: {
      // Prefer source for browser bundle transparency; package still depends on file:../engine.
      'manseryeok-engine': path.resolve(__dirname, '../engine/src/index.ts'),
    },
  },
  server: {
    fs: {
      allow: [path.resolve(__dirname), path.resolve(__dirname, '..')],
    },
  },
});
