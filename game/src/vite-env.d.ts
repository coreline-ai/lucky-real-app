/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_MCP_URL?: string;
  readonly VITE_USE_MCP?: string;
  readonly VITE_MCP_STRICT?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
