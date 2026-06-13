<script setup lang="ts">
import { ref } from 'vue'
import { Store, ArrowRight, ShieldCheck } from 'lucide-vue-next'

definePageMeta({
  layout: false
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
    router.push('/kalimantan')
  } catch (error: any) {
    errorMsg.value = error.message || 'Login failed. Please check your credentials.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-white flex font-sans">
    <!-- Left Pane: Branding & Visuals (Hidden on mobile) -->
    <div class="hidden lg:flex lg:w-1/2 bg-[#0b1943] relative overflow-hidden flex-col p-12 lg:p-20">
      <!-- Decorative background grid -->
      <div class="absolute inset-0 z-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMjAiIGN5PSIyMCIgcj0iMSIgZmlsbD0icmdiYSgyNTUsIDI1NSwgMjU1LCAwLjE1KSIvPjwvc3ZnPg==')] [mask-image:linear-gradient(to_bottom,white,transparent)] opacity-40"></div>
      
      <!-- Glowing Orbs -->
      <div class="absolute top-0 right-0 w-96 h-96 bg-primary-500 rounded-full mix-blend-screen filter blur-[100px] opacity-40 animate-pulse"></div>
      <div class="absolute bottom-0 left-0 w-[500px] h-[500px] bg-orange-500 rounded-full mix-blend-screen filter blur-[120px] opacity-30" style="animation: pulse 8s cubic-bezier(0.4, 0, 0.6, 1) infinite;"></div>
      
      <!-- Header -->
      <div class="relative z-10">
        <NuxtLink to="/" class="inline-flex items-center gap-3 group">
          <div class="w-14 h-14 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center text-white border border-white/20 shadow-xl group-hover:scale-105 transition-all">
            <Store class="w-7 h-7" />
          </div>
          <span class="font-extrabold text-4xl tracking-tight text-white group-hover:text-primary-200 transition-colors">JStore</span>
        </NuxtLink>
      </div>

      <!-- Main Copy -->
      <div class="relative z-10 mt-24 max-w-xl">
        <h2 class="text-5xl font-bold text-white leading-[1.15] mb-6 tracking-tight">Kendalikan Pusat Bisnis Afiliasi Anda</h2>
        <p class="text-slate-300 text-xl leading-relaxed font-light">Sistem manajemen cerdas untuk memantau klik, menganalisis konversi, dan memperluas jangkauan produk Anda dalam satu dashboard yang elegan.</p>
      </div>
      
      <!-- Glassmorphism Stats Preview -->
      <div class="relative z-10 mt-auto grid grid-cols-2 gap-4">
        <div class="bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl p-6 hover:bg-white/10 transition-colors">
          <div class="w-10 h-10 rounded-full bg-emerald-500/20 flex items-center justify-center text-emerald-400 mb-4">
            <ShieldCheck class="w-5 h-5" />
          </div>
          <h4 class="text-white font-semibold mb-1">Aman & Privat</h4>
          <p class="text-slate-400 text-sm">Data dilindungi autentikasi ketat.</p>
        </div>
        <div class="bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl p-6 hover:bg-white/10 transition-colors">
          <div class="w-10 h-10 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400 mb-4">
            <ArrowRight class="w-5 h-5" />
          </div>
          <h4 class="text-white font-semibold mb-1">Real-time Analytics</h4>
          <p class="text-slate-400 text-sm">Pantau CTR masuk secara langsung.</p>
        </div>
      </div>
    </div>

    <!-- Right Pane: Login Form -->
    <div class="w-full lg:w-1/2 bg-slate-50 relative flex flex-col justify-center px-6 sm:px-16 xl:px-32">
      <!-- Background Graphic for Right Pane -->
      <div class="absolute inset-0 z-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTU5LjkgNjBIMHYtLjFoNTkuOVY2MHpNMCAwaC4xdjU5LjlIMHYtNTkuOXoiIGZpbGw9IiNlNWEwY2MiIGZpbGwtb3BhY2l0eT0iMC41IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48L3N2Zz4=')] opacity-40 [mask-image:linear-gradient(to_bottom,transparent,white_20%,white_80%,transparent)]"></div>
      
      <!-- Mobile Logo -->
      <div class="absolute top-8 left-6 lg:hidden z-20">
        <NuxtLink to="/" class="inline-flex items-center gap-2 group">
          <div class="w-10 h-10 rounded-xl bg-[#0b1943] flex items-center justify-center text-white shadow-md">
            <Store class="w-5 h-5" />
          </div>
          <span class="font-bold text-2xl tracking-tight text-slate-900 group-hover:text-primary-600 transition-colors">JStore</span>
        </NuxtLink>
      </div>

      <div class="relative z-10 w-full max-w-md mx-auto mt-12 lg:mt-0">
        <!-- Floating Element Behind Card -->
        <!-- <div class="absolute -top-12 -right-12 w-32 h-32 bg-primary-200 rounded-full mix-blend-multiply filter blur-2xl opacity-70 animate-pulse"></div> -->
        <!-- <div class="absolute -bottom-8 -left-8 w-40 h-40 bg-orange-200 rounded-full mix-blend-multiply filter blur-2xl opacity-70" style="animation: pulse 4s infinite;"></div> -->
        
        <div class="bg-white/80 backdrop-blur-2xl rounded-3xl border border-slate-200/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] p-8 sm:p-12 relative overflow-hidden">
          <!-- Subtle top gradient line -->
          <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary-400 to-orange-400"></div>

          <div class="text-center sm:text-left mb-8">
            <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Welcome Back</h1>
            <p class="text-slate-500 mt-2 text-sm">Masuk ke ruang kontrol JStore Anda.</p>
          </div>

          <form @submit.prevent="handleLogin" class="space-y-6">
            <div class="space-y-2">
              <label class="text-sm font-semibold text-slate-700">Email Address</label>
              <div class="relative mt-2">
                <input 
                  v-model="email" 
                  type="email" 
                  placeholder="admin@jstore.com" 
                  required
                  class="w-full pl-4 pr-4 py-3 bg-slate-50/50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500/50 focus:border-primary-500 transition-all sm:text-sm"
                />
              </div>
            </div>
            
            <div class="space-y-2">
              <div class="flex items-center justify-between">
                <label class="text-sm font-semibold text-slate-700">Password</label>
              </div>
              <div class="relative">
                <input 
                  v-model="password" 
                  type="password" 
                  placeholder="••••••••" 
                  required
                  class="w-full pl-4 pr-4 py-3 bg-slate-50/50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500/50 focus:border-primary-500 transition-all sm:text-sm"
                />
              </div>
            </div>
            
            <div v-if="errorMsg" class="p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100 flex items-start gap-2">
              <span>{{ errorMsg }}</span>
            </div>

            <button type="submit" :disabled="loading" class="w-full flex items-center justify-center gap-2 py-3.5 px-4 bg-[#0b1943] hover:bg-[#1a2f6c] text-white font-semibold rounded-xl transition-all shadow-lg shadow-[#0b1943]/20 disabled:opacity-70 disabled:cursor-not-allowed group cursor-pointer mt-2">
              <span v-if="loading">Processing...</span>
              <template v-else>
                Sign In to Dashboard
                <ArrowRight class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </template>
            </button>
          </form>
        </div>
        
        <p class="text-center text-xs font-medium text-slate-400 mt-8">
          &copy; {{ new Date().getFullYear() }} JStore Affiliate Management.
        </p>
      </div>
    </div>
  </div>
</template>

<style>
@keyframes blob {
  0% { transform: translate(0px, 0px) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}
.animate-blob {
  animation: blob 7s infinite;
}
</style>
