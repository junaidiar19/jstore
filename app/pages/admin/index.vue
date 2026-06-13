<script setup lang="ts">
const supabase = useSupabaseClient()
const router = useRouter()
const user = useSupabaseUser()

const handleLogout = async () => {
  await supabase.auth.signOut()
  router.push('/login')
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 p-8">
    <UiCard class="max-w-4xl mx-auto border-none shadow-xl shadow-slate-200/50">
      <template #header>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-blue-600 text-white shadow-md shadow-blue-200">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-store"><path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7"/><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4"/><path d="M2 7h20"/><path d="M22 7v3a2 2 0 0 1-2 2v0a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12v0a2 2 0 0 1-2-2V7"/></svg>
            </div>
            <h1 class="text-2xl font-bold text-slate-900 tracking-tight">JStore Admin</h1>
          </div>
          <div class="flex items-center gap-4">
            <span class="text-sm font-medium text-slate-600">{{ user?.email }}</span>
            <UiButton @click="handleLogout" variant="ghost">Logout</UiButton>
          </div>
        </div>
      </template>
      
      <div class="p-12 border-2 border-dashed border-slate-200 rounded-xl bg-slate-50/50 flex flex-col items-center justify-center text-slate-500">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-package-open text-slate-300 mb-4"><path d="M12 22v-9"/><path d="M15.17 2.38a2 2 0 0 0-6.34 0l-5.6 4.86a2 2 0 0 0-.73 1.63v10.1A2 2 0 0 0 4.5 21h15a2 2 0 0 0 2-2v-10.1a2 2 0 0 0-.73-1.63z"/><path d="M2.5 8 12 11l9.5-3"/><path d="M15 11l-3 3-3-3"/></svg>
        <p class="font-medium">Product Listing</p>
        <p class="text-sm">Produk akan ditampilkan di sini (Phase 3)</p>
      </div>
    </UiCard>
  </div>
</template>
