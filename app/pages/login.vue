<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({
  layout: 'auth'
})

const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')

const supabase = useSupabaseClient()
const router = useRouter()

const handleLogin = async () => {
  loading.value = true
  errorMsg.value = ''
  
  try {
    const { error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })

    if (error) throw error

    // Redirect to home/dashboard after successful login
    router.push('/admin')
  } catch (error: any) {
    errorMsg.value = error.message || 'Login failed. Please check your credentials.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="text-center mb-8">
    <div class="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-blue-600 text-white mb-4 shadow-lg shadow-blue-200">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-store"><path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7"/><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4"/><path d="M2 7h20"/><path d="M22 7v3a2 2 0 0 1-2 2v0a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12v0a2 2 0 0 1-2-2V7"/></svg>
    </div>
    <h1 class="text-3xl font-bold text-slate-900 tracking-tight">JStore</h1>
    <p class="text-slate-500 mt-2">Login to your admin dashboard</p>
  </div>

  <UiCard class="border-none shadow-sm shadow-slate-200/50">
    <form @submit.prevent="handleLogin" class="space-y-4">
      <UiInput 
        v-model="email" 
        label="Email Address" 
        type="email" 
        placeholder="admin@jstore.com" 
        required
      />
      <UiInput 
        v-model="password" 
        label="Password" 
        type="password" 
        placeholder="••••••••" 
        required
      />
      
      <div v-if="errorMsg" class="p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
        {{ errorMsg }}
      </div>

      <UiButton type="submit" variant="primary" block :loading="loading" class="mt-4">
        Continue
      </UiButton>
    </form>
  </UiCard>
</template>
