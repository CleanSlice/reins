import { fileURLToPath } from 'url'
import tailwindcss from '@tailwindcss/vite'

const currentDir = fileURLToPath(new URL('.', import.meta.url))

export default defineNuxtConfig({
  modules: ['@pinia/nuxt'],

  alias: {
    '#reins': currentDir,
    '#theme': `${currentDir}/theme`,
  },

  components: [
    { path: `${currentDir}/components`, pathPrefix: false },
  ],

  imports: {
    dirs: [`${currentDir}/stores`],
  },

  vite: {
    plugins: [tailwindcss()],
  },

  devServer: {
    port: 3001,
  },

  devtools: { enabled: false },
})
