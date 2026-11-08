import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig(({ mode, command }) => ({
  base: command === 'build' ? '/DNDSheetAPP/' : '/',
  plugins: [
    react(),
    // 'single' mode → alles in eine index.html, kein /assets/ Ordner
    ...(mode === 'single' ? [viteSingleFile()] : []),
  ],
  server: {
    port: 3000,
    open: false,
  },
  build: {
    // Für Single-File: kein Chunk-Splitting
    ...(mode === 'single' && {
      assetsInlineLimit: 100_000_000,
      cssCodeSplit: false,
    }),
  },
}))
