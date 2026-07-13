import path from 'node:path';
import { defineConfig } from 'vite';

const engineSrc = path.resolve(__dirname, '../engine/src');

export default defineConfig({
  resolve: {
    alias: [
      {
        find: /^manseryeok-engine\/engine\/(.+)$/,
        replacement: `${engineSrc}/engine/$1`,
      },
      // Prefer source for browser bundle transparency; package still depends on file:../engine.
      {
        find: 'manseryeok-engine',
        replacement: path.resolve(engineSrc, 'index.ts'),
      },
    ],
  },
  server: {
    fs: {
      allow: [path.resolve(__dirname), path.resolve(__dirname, '..')],
    },
  },
});
