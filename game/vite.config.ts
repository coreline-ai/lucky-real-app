import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '../engine/src'),
    },
  },
  server: {
    proxy: {
      '/mcp': {
        target: 'http://127.0.0.1:3100',
        changeOrigin: false,
      },
    },
    fs: {
      allow: [
        path.resolve(__dirname),
        path.resolve(__dirname, '..'),
      ],
    },
  },
});
