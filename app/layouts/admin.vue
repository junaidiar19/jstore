<script setup lang="ts">
import { ref } from 'vue'
import { 
  LayoutDashboard, 
  Package, 
  ExternalLink, 
  ChevronDown, 
  LogOut,
  Store,
  X,
  Menu as MenuIcon
} from 'lucide-vue-next'
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const isSidebarOpen = ref(true)

useHead({
  titleTemplate: '%s - JStore Admin',
  title: 'Dashboard',
  meta: [
    { name: 'robots', content: 'noindex, nofollow' },
    { name: 'description', content: 'Admin dashboard for JStore affiliate product management.' }
  ]
})

const handleLogout = async () => {
  await supabase.auth.signOut()
  router.push('/banjarmasin')
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex relative">
    <!-- Background Pattern Grid -->
    <div class="absolute inset-0 z-0 bg-grid-subtle pointer-events-none"></div>

    <!-- Sidebar Toggle (When Closed) -->
    <button 
      v-if="!isSidebarOpen"
      @click="isSidebarOpen = true"
      class="fixed top-4 left-4 z-20 p-2 bg-white border border-slate-200 shadow-sm rounded-lg text-slate-600 hover:bg-slate-50 transition-colors focus:outline-none focus:ring-2 focus:ring-primary-500 cursor-pointer"
    >
      <MenuIcon class="w-5 h-5" />
    </button>

    <!-- Sidebar -->
    <aside 
      class="bg-[#0b1943] flex flex-col fixed inset-y-0 z-30 transition-all duration-300 shadow-xl"
      :class="isSidebarOpen ? 'w-64 translate-x-0' : 'w-64 -translate-x-full'"
    >
      <!-- Head -->
      <div class="h-14 flex items-center justify-between px-6 border-b border-white/5">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-[#df672f] to-orange-400 flex items-center justify-center text-white shadow-lg shadow-[#df672f]/20">
            <Store class="w-4 h-4" />
          </div>
          <span class="font-extrabold text-xl tracking-tight bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">JStore</span>
        </div>
        <button 
          @click="isSidebarOpen = false" 
          class="p-1 rounded-lg text-slate-400 hover:bg-white/5 hover:text-white transition-colors focus:outline-none cursor-pointer"
        >
          <X class="w-5 h-5" />
        </button>
      </div>

      <!-- Menu -->
      <nav class="flex-1 overflow-y-auto py-6 px-3 space-y-1">
        <UiNavLink to="/kalimantan" label="Dashboard">
          <template #icon><LayoutDashboard class="w-5 h-5" /></template>
        </UiNavLink>
        <UiNavLink to="/kalimantan/products" label="Product">
          <template #icon><Package class="w-5 h-5" /></template>
        </UiNavLink>
        <UiNavLink to="/" label="Link Website" target="_blank">
          <template #icon><ExternalLink class="w-5 h-5" /></template>
        </UiNavLink>
      </nav>

      <!-- Fixed Bottom: User Profile -->
      <div class="border-t border-white/5 p-4">
        <Menu as="div" class="relative">
          <MenuButton class="w-full flex items-center gap-3 p-2 rounded-xl hover:bg-white/5 transition-colors border border-transparent focus:outline-none cursor-pointer">
            <div class="w-9 h-9 rounded-full bg-[#df672f] text-white flex items-center justify-center font-bold text-sm">
              {{ user?.email?.charAt(0).toUpperCase() || 'A' }}
            </div>
            <div class="flex-1 text-left overflow-hidden">
              <p class="text-sm font-medium text-white truncate">{{ user?.email || 'admin@jstore.com' }}</p>
              <p class="text-xs text-slate-400">Administrator</p>
            </div>
            <ChevronDown class="w-4 h-4 text-slate-500" />
          </MenuButton>

          <transition 
            enter-active-class="transition duration-100 ease-out" 
            enter-from-class="transform scale-95 opacity-0" 
            enter-to-class="transform scale-100 opacity-100" 
            leave-active-class="transition duration-75 ease-out" 
            leave-from-class="transform scale-100 opacity-100" 
            leave-to-class="transform scale-95 opacity-0"
          >
            <MenuItems class="absolute bottom-full left-0 right-0 mb-2 bg-white rounded-xl border border-slate-200 shadow-lg py-1 z-40 focus:outline-none">
              <MenuItem v-slot="{ active }">
                <button 
                  @click="handleLogout" 
                  :class="[
                    active ? 'bg-red-50 text-red-600' : 'text-red-600',
                    'w-full text-left px-4 py-2.5 text-sm flex items-center gap-2 transition-colors focus:outline-none cursor-pointer'
                  ]"
                >
                  <LogOut class="w-4 h-4" />
                  Logout
                </button>
              </MenuItem>
            </MenuItems>
          </transition>
        </Menu>
      </div>
    </aside>

    <!-- Overlay for mobile when sidebar is open (optional but good practice) -->
    <div 
      v-if="isSidebarOpen" 
      @click="isSidebarOpen = false"
      class="fixed inset-0 bg-slate-900/50 z-20 md:hidden"
    ></div>

    <!-- Main Content -->
    <main 
      class="flex-1 min-w-0 transition-all duration-300 relative z-10"
      :class="isSidebarOpen ? 'md:ml-64' : 'ml-0'"
    >
      <slot />
    </main>
  </div>
</template>
