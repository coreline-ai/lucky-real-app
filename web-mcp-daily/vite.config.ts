import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const target = env.MCP_HTTP_TARGET || 'http://127.0.0.1:3100';

  return {
    server: {
      proxy: {
        '/mcp': {
          target,
          changeOrigin: true,
        },
      },
    },
  };
});
