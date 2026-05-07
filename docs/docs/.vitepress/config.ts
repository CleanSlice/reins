import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Reins',
  description: 'Knowledge / RAG slice for CleanSlice projects',
  themeConfig: {
    nav: [
      { text: 'Getting started', link: '/getting-started' },
      { text: 'GitHub', link: 'https://github.com/CleanSlice/reins' },
    ],
    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'Overview', link: '/' },
          { text: 'Getting started', link: '/getting-started' },
        ],
      },
      {
        text: 'Setup',
        items: [
          { text: 'LightRAG', link: '/lightrag' },
          { text: 'Settings reference', link: '/settings' },
          { text: 'LLM credentials', link: '/credentials' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/CleanSlice/reins' },
    ],
  },
});
