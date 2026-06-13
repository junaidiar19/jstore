import tailwindcss from "@tailwindcss/vite";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  runtimeConfig: {
    openRouterKey: process.env.OPEN_ROUTER_KEY
  },
  css: ['./app/assets/css/main.css'],
  modules: [
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    '@vueuse/nuxt'
  ],
  supabase: {
    redirectOptions: {
      login: '/banjarmasin',
      callback: '/confirm',
      exclude: ['/banjarmasin', '/']
    }
  },
  vite: {
    plugins: [
      tailwindcss(),
    ],
  },
})
