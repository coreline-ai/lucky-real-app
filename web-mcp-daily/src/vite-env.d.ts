/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_MCP_URL?: string;
  readonly VITE_MCP_AUTH_MODE?: 'none' | 'x-token' | 'bearer';
  readonly VITE_MCP_AUTH_TOKEN?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
