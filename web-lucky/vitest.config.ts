import path from 'node:path';
import { defineConfig } from 'vitest/config';

const engineSrc = path.resolve(__dirname, '../engine/src');

export default defineConfig({
  resolve: {
    alias: [
      {
        find: /^manseryeok-engine\/engine\/(.+)$/,
        replacement: `${engineSrc}/engine/$1`,
      },
      {
        find: 'manseryeok-engine',
        replacement: path.resolve(engineSrc, 'index.ts'),
      },
    ],
  },
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
});
