# AI Instructions & Best Practices

The following are the established best practices and "skills" to be used when developing this project:

## Tech Stack
- **Framework**: Nuxt 4 (using `app/` directory structure)
- **Styling**: Tailwind CSS v4 (Component-based architecture, modern soft aesthetics)
- **State Management**: Pinia (`@pinia/nuxt`)
- **Backend & Auth**: Supabase (`@nuxtjs/supabase`)
- **Icons**: `lucide-vue-next` (or similar modern icon set)

## Architectural Guidelines
1. **Component-Based**: Break down UIs into small, reusable dumb/smart components (e.g., `app/components/ui/Button.vue`).
2. **Directory Structure**: 
   - `app/pages/`: File-based routing.
   - `app/layouts/`: Page layouts (e.g., `auth.vue`, `default.vue`).
   - `app/composables/`: Reusable logic and Supabase queries.
   - `app/middleware/`: Route protection (e.g., `auth.global.ts`).
3. **Styling & Theme**:
   - Modern, soft blue theme (Trello-like, premium feel).
   - Use Tailwind CSS v4 effectively (gradients, smooth transitions, glassmorphism if applicable).
4. **State Management**:
   - Use Pinia for complex client-side state.
   - Rely on `useSupabaseUser()` and `useSupabaseClient()` for auth state.

## Rules
- Write clean, strongly typed TypeScript.
- Follow Vue 3 `<script setup lang="ts">` composition API style.
- Maintain a premium aesthetic for all UI components.
