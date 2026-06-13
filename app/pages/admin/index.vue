<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Package, MousePointerClick, Search, TrendingUp, ExternalLink, Activity } from 'lucide-vue-next'
import UiCard from '~/components/ui/Card.vue'

definePageMeta({
  layout: 'admin'
})

const supabase = useSupabaseClient()

const totalProducts = ref(0)
const totalClicks = ref(0)
const totalViews = ref(0)
const topProducts = ref<any[]>([])
const recentSearches = ref<any[]>([])
const isLoading = ref(true)

const fetchDashboardData = async () => {
  isLoading.value = true
  try {
    // 1. Fetch aggregate metrics
    const { data: products, error: prodError } = await supabase
      .from('products')
      .select('id, title, click_count, view_count, image_url, affiliate_url')
      .eq('is_active', true)
      
    if (!prodError && products) {
      totalProducts.value = products.length
      totalClicks.value = products.reduce((acc, p) => acc + (p.click_count || 0), 0)
      totalViews.value = products.reduce((acc, p) => acc + (p.view_count || 0), 0)
      
      // Top 5 products by clicks
      topProducts.value = [...products]
        .sort((a, b) => (b.click_count || 0) - (a.click_count || 0))
        .slice(0, 5)
    }

    // 2. Fetch recent searches
    const { data: searches, error: searchError } = await supabase
      .from('analytics_events')
      .select('search_query, created_at')
      .eq('event_type', 'search')
      .order('created_at', { ascending: false })
      .limit(10)
      
    if (!searchError && searches) {
      // Filter out empty searches and deduplicate slightly for clean display
      const uniqueSearches = []
      const seen = new Set()
      for (const s of searches) {
        if (s.search_query && !seen.has(s.search_query.toLowerCase())) {
          seen.add(s.search_query.toLowerCase())
          uniqueSearches.push(s)
          if (uniqueSearches.length >= 5) break
        }
      }
      recentSearches.value = uniqueSearches
    }

  } catch (err) {
    console.error('Error fetching dashboard data:', err)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<template>
  <div class="p-8">
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-slate-900 tracking-tight">Dashboard Overview</h1>
      <p class="text-slate-500 mt-1">Pantau performa produk afiliasi dan aktivitas pengunjung Anda.</p>
    </div>

    <div v-if="isLoading" class="space-y-8 animate-pulse">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="h-24 bg-slate-200 rounded-2xl"></div>
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="h-96 bg-slate-200 rounded-2xl"></div>
        <div class="h-96 bg-slate-200 rounded-2xl"></div>
      </div>
    </div>

    <div v-else class="space-y-8">
      <!-- Top Metrics -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <UiCard class="border-none shadow-lg shadow-blue-500/20 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 bg-gradient-to-br from-blue-500 to-indigo-600 p-0 overflow-hidden relative group">
          <div class="absolute -right-6 -top-6 w-24 h-24 bg-white/10 rounded-full blur-2xl group-hover:bg-white/20 transition-colors"></div>
          <div class="flex items-center gap-4 relative z-10">
            <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white shrink-0 backdrop-blur-sm border border-white/10">
              <Package class="w-6 h-6" />
            </div>
            <div>
              <p class="text-sm font-medium text-blue-100">Active Products</p>
              <p class="text-3xl font-extrabold text-white tracking-tight">{{ totalProducts }}</p>
            </div>
          </div>
        </UiCard>

        <UiCard class="border-none shadow-lg shadow-orange-500/20 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 bg-gradient-to-br from-orange-500 to-rose-500 p-0 overflow-hidden relative group">
          <div class="absolute -right-6 -top-6 w-24 h-24 bg-white/10 rounded-full blur-2xl group-hover:bg-white/20 transition-colors"></div>
          <div class="flex items-center gap-4 relative z-10">
            <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white shrink-0 backdrop-blur-sm border border-white/10">
              <MousePointerClick class="w-6 h-6" />
            </div>
            <div>
              <p class="text-sm font-medium text-orange-100">Total Clicks</p>
              <p class="text-3xl font-extrabold text-white tracking-tight">{{ totalClicks }}</p>
            </div>
          </div>
        </UiCard>

        <UiCard class="border-none shadow-lg shadow-emerald-500/20 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 bg-gradient-to-br from-emerald-500 to-teal-600 p-0 overflow-hidden relative group">
          <div class="absolute -right-6 -top-6 w-24 h-24 bg-white/10 rounded-full blur-2xl group-hover:bg-white/20 transition-colors"></div>
          <div class="flex items-center gap-4 relative z-10">
            <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-white shrink-0 backdrop-blur-sm border border-white/10">
              <Activity class="w-6 h-6" />
            </div>
            <div>
              <p class="text-sm font-medium text-emerald-100">Total Views</p>
              <p class="text-3xl font-extrabold text-white tracking-tight">{{ totalViews }}</p>
            </div>
          </div>
        </UiCard>
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        <!-- Top Products -->
        <UiCard class="border border-slate-200 shadow-sm shadow-slate-200/50 p-0 overflow-hidden flex flex-col">
          <div class="px-6 py-5 border-b-2 border-slate-100 bg-slate-50/50 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <TrendingUp class="w-5 h-5 text-orange-500" />
              <h2 class="text-lg font-semibold text-slate-900">Top Performing Products</h2>
            </div>
          </div>
          
          <div class="flex-1 p-0">
            <div v-if="topProducts.length === 0" class="p-8 text-center text-slate-500">
              Belum ada data klik.
            </div>
            <ul v-else class="divide-y divide-slate-100">
              <li v-for="(product, idx) in topProducts" :key="product.id" class="p-4 sm:px-6 hover:bg-slate-50 transition-colors flex items-center gap-4">
                <span class="text-lg font-semibold text-slate-300 w-4">{{ idx + 1 }}</span>
                <div class="w-12 h-12 rounded-xl bg-slate-100 border border-slate-200 overflow-hidden shrink-0">
                  <img v-if="product.image_url" :src="product.image_url" class="w-full h-full object-cover" />
                  <Package v-else class="w-6 h-6 text-slate-300 m-auto mt-3" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-bold text-slate-900 truncate">{{ product.title }}</p>
                  <div class="flex items-center gap-3 mt-1 text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-1 text-orange-600 bg-orange-50 px-2 py-0.5 rounded-md"><MousePointerClick class="w-3 h-3"/> {{ product.click_count || 0 }} clicks</span>
                    <span class="flex items-center gap-1"><Activity class="w-3 h-3"/> {{ product.view_count || 0 }} views</span>
                  </div>
                </div>
                <a v-if="product.affiliate_url" :href="product.affiliate_url" target="_blank" class="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors shrink-0">
                  <ExternalLink class="w-4 h-4" />
                </a>
              </li>
            </ul>
          </div>
        </UiCard>

        <!-- Recent Searches -->
        <UiCard class="border border-slate-200 shadow-sm shadow-slate-200/50 p-0 overflow-hidden flex flex-col">
          <div class="px-6 py-5 border-b-2 border-slate-100 bg-slate-50/50 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <Search class="w-5 h-5 text-blue-500" />
              <h2 class="text-lg font-semibold text-slate-900">What People Are Searching</h2>
            </div>
          </div>
          
          <div class="flex-1 p-0">
            <div v-if="recentSearches.length === 0" class="p-8 text-center text-slate-500 flex flex-col items-center">
              <Search class="w-8 h-8 text-slate-300 mb-2" />
              Belum ada data pencarian.
            </div>
            <ul v-else class="divide-y divide-slate-100">
              <li v-for="search in recentSearches" :key="search.created_at" class="px-6 py-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center shrink-0">
                    <Search class="w-4 h-4" />
                  </div>
                  <span class="font-medium text-slate-800">"{{ search.search_query }}"</span>
                </div>
                <span class="text-xs text-slate-500">{{ formatDate(search.created_at) }}</span>
              </li>
            </ul>
          </div>
          
          <div class="px-6 py-4 bg-slate-50/50 border-t border-slate-100 mt-auto">
            <p class="text-xs text-slate-500 text-center">Gunakan data ini untuk mencari ide produk baru yang diinginkan audiens.</p>
          </div>
        </UiCard>

      </div>
    </div>
  </div>
</template>
