<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Search, Filter, ExternalLink, Share2, Check, Store, X } from 'lucide-vue-next'
import { useIntersectionObserver } from '@vueuse/core'
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild } from '@headlessui/vue'
import { useToast } from '~/composables/useToast'
import ProductDetailModal from '~/components/ProductDetailModal.vue'

definePageMeta({
  layout: false
})

useHead({
  title: 'JStore - Temukan Produk Afiliasi Pilihan Terbaik',
  meta: [
    { name: 'description', content: 'JStore adalah platform kurasi produk afiliasi terbaik. Temukan berbagai macam produk berkualitas dengan harga terbaik dari berbagai kategori.' },
    { name: 'keywords', content: 'jstore, produk afiliasi, rekomendasi produk, belanja online, kurasi produk' },
    { property: 'og:title', content: 'JStore - Temukan Produk Afiliasi Pilihan Terbaik' },
    { property: 'og:description', content: 'JStore adalah platform kurasi produk afiliasi terbaik. Temukan berbagai macam produk berkualitas dengan harga terbaik dari berbagai kategori.' },
    { property: 'og:type', content: 'website' },
    { property: 'og:site_name', content: 'JStore' },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:title', content: 'JStore - Produk Afiliasi Terbaik' },
    { name: 'twitter:description', content: 'Temukan berbagai macam produk berkualitas dengan harga terbaik di JStore.' }
  ]
})

const supabase = useSupabaseClient()
const { addToast } = useToast()

const products = ref<any[]>([])
const categories = ref<string[]>([])
const isLoading = ref(true)
const isLoadingMore = ref(false)
const hasMore = ref(true)

const searchQuery = ref('')
const searchInput = ref('')
const selectedCategory = ref('')
const page = ref(1)
const perPage = ref(12)

const isFilterDrawerOpen = ref(false)
const loadMoreRef = ref(null)

const isDetailModalOpen = ref(false)
const selectedProductId = ref<string | null>(null)

const openProductDetail = (id: string) => {
  selectedProductId.value = id
  isDetailModalOpen.value = true
  trackEvent('click', id)
}

const trackEvent = async (eventType: string, productId?: string, query?: string) => {
  try {
    // @ts-expect-error - RPC types might not be generated yet
    await supabase.rpc('track_event', {
      p_event_type: eventType,
      p_product_id: productId || null,
      p_search_query: query || null,
      p_session_id: null
    })
  } catch (err) {
    console.error('Failed to track event', err)
  }
}

let searchTimeout: ReturnType<typeof setTimeout>
const handleSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    searchQuery.value = searchInput.value
    page.value = 1
    hasMore.value = true
    products.value = []
    if (searchQuery.value) {
      trackEvent('search', undefined, searchQuery.value)
    }
    fetchProducts()
  }, 300)
}

const selectCategory = (cat: string) => {
  selectedCategory.value = cat
  page.value = 1
  hasMore.value = true
  products.value = []
  isFilterDrawerOpen.value = false
  fetchProducts()
}

const fetchCategories = async () => {
  const { data } = await supabase.from('products').select('category').eq('is_active', true)
  if (data) {
    const unique = [...new Set(data.map(d => d.category).filter(Boolean))]
    categories.value = unique as string[]
  }
}

const fetchProducts = async () => {
  if (page.value === 1) isLoading.value = true
  else isLoadingMore.value = true

  let query = supabase
    .from('products')
    .select('*')
    .eq('is_active', true)
    
  if (searchQuery.value) {
    query = query.ilike('title', `%${searchQuery.value}%`)
  }
  if (selectedCategory.value) {
    query = query.eq('category', selectedCategory.value)
  }

  const from = (page.value - 1) * perPage.value
  const to = from + perPage.value - 1
  query = query.range(from, to).order('created_at', { ascending: false })

  const { data, error } = await query
  
  if (!error && data) {
    if (page.value === 1) {
      products.value = data
    } else {
      products.value = [...products.value, ...data]
    }
    hasMore.value = data.length === perPage.value
  }
  
  isLoading.value = false
  isLoadingMore.value = false
}

useIntersectionObserver(loadMoreRef, ([{ isIntersecting }]) => {
  if (isIntersecting && hasMore.value && !isLoading.value && !isLoadingMore.value) {
    page.value++
    fetchProducts()
  }
}, { threshold: 0.5 })

onMounted(() => {
  fetchCategories()
  fetchProducts()
})

const copiedLinkId = ref<string | null>(null)
const shareProduct = async (product: any) => {
  if (navigator.share) {
    try {
      await navigator.share({
        title: product.title,
        text: product.short_description || `Check out ${product.title}`,
        url: product.affiliate_url
      })
    } catch (err) {
      console.log('Share cancelled or failed', err)
    }
    trackEvent('copy', product.id)
  } else if (product.affiliate_url) {
    navigator.clipboard.writeText(product.affiliate_url)
    copiedLinkId.value = product.id
    addToast({ type: 'success', message: 'Link copied to clipboard!' })
    setTimeout(() => {
      copiedLinkId.value = null
    }, 2000)
    trackEvent('copy', product.id)
  }
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 font-sans">
    <!-- Header -->
    <header class="bg-white border-b border-slate-200 sticky top-0 z-20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-[#df672f] to-orange-400 flex items-center justify-center text-white shadow-lg shadow-[#df672f]/20">
            <Store class="w-4 h-4" />
          </div>
          <span class="font-extrabold text-xl tracking-tight bg-gradient-to-r from-slate-900 to-slate-600 bg-clip-text text-transparent hidden sm:block">JStore</span>
        </div>
        
        <!-- Search Bar -->
        <UiInput 
          v-model="searchInput" 
          @input="handleSearch"
          placeholder="Search amazing products..." 
          class="flex-1 max-w-2xl"
        >
          <template #icon>
            <Search class="h-4 w-4" />
          </template>
        </UiInput>

        <!-- Filter Icon (Mobile/Desktop) -->
        <button @click="isFilterDrawerOpen = true" class="p-2 text-slate-500 hover:text-primary-600 hover:bg-primary-50 rounded-full transition-colors focus:outline-none shrink-0 relative cursor-pointer">
          <Filter class="w-5 h-5" />
          <span v-if="selectedCategory" class="absolute top-1 right-1 w-2 h-2 bg-primary-500 rounded-full border border-white"></span>
        </button>
      </div>

      <!-- Horizontal Categories (Desktop) -->
      <div class="hidden sm:block border-t border-slate-100 bg-slate-50/50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center gap-2 py-3 overflow-x-auto no-scrollbar">
            <button 
              @click="selectCategory('')"
              class="whitespace-nowrap px-4 py-1.5 rounded-full text-sm font-medium transition-colors cursor-pointer"
              :class="!selectedCategory ? 'bg-primary-500 text-white shadow-sm' : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'"
            >
              All
            </button>
            <button 
              v-for="cat in categories" :key="cat"
              @click="selectCategory(cat)"
              class="whitespace-nowrap px-4 py-1.5 rounded-full text-sm font-medium transition-colors cursor-pointer"
              :class="selectedCategory === cat ? 'bg-primary-500 text-white shadow-sm' : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'"
            >
              {{ cat }}
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      <!-- Loading State (Initial) -->
      <div v-if="isLoading" class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
        <div v-for="i in 8" :key="i" class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden animate-pulse">
          <div class="aspect-square bg-slate-200 w-full"></div>
          <div class="p-5 space-y-4">
            <div class="h-4 bg-slate-200 rounded w-3/4"></div>
            <div class="h-3 bg-slate-200 rounded w-full"></div>
            <div class="flex justify-between items-center pt-2">
              <div class="h-5 bg-slate-200 rounded w-1/3"></div>
              <div class="h-8 bg-slate-200 rounded-lg w-20"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="products.length === 0" class="py-24 flex flex-col items-center justify-center text-center">
        <div class="w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center mb-6 ring-8 ring-slate-50">
          <Search class="w-10 h-10 text-slate-400" />
        </div>
        <h3 class="text-xl font-bold text-slate-900 mb-2">No products found</h3>
        <p class="text-slate-500 max-w-md">We couldn't find any products matching your search or filter. Try using different keywords.</p>
        <button v-if="searchQuery || selectedCategory" @click="searchInput = ''; searchQuery = ''; selectCategory('')" class="mt-6 px-6 py-2 bg-primary-50 text-primary-600 hover:bg-primary-100 font-medium rounded-full transition-colors cursor-pointer">
          Clear Filters
        </button>
      </div>

      <!-- Product Grid -->
      <div v-else class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
        <div 
          v-for="product in products" 
          :key="product.id"
          @click="openProductDetail(product.id)"
          class="bg-white rounded-2xl shadow-sm hover:shadow-xl border border-slate-100 overflow-hidden transition-all duration-300 group flex flex-col cursor-pointer"
        >
          <!-- Image -->
          <div class="relative aspect-square w-full bg-slate-100 overflow-hidden shrink-0">
            <img v-if="product.image_url" :src="product.image_url" :alt="product.title" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
            <div v-else class="w-full h-full flex items-center justify-center">
              <Store class="w-10 h-10 text-slate-300" />
            </div>
            <!-- Category Badge -->
            <div v-if="product.category" class="absolute top-3 left-3 px-2.5 py-1 bg-white/90 backdrop-blur-sm text-slate-700 text-xs font-semibold rounded-full shadow-sm">
              {{ product.category }}
            </div>
          </div>

          <!-- Content -->
          <div class="p-3 sm:p-5 flex flex-col flex-1">
            <h3 class="font-bold text-slate-900 line-clamp-1 mb-1 text-sm sm:text-base group-hover:text-primary-600 transition-colors" :title="product.title">{{ product.title }}</h3>
            <p class="text-xs sm:text-sm text-slate-500 line-clamp-2 mb-3 sm:mb-4 flex-1" :title="product.short_description">{{ product.short_description }}</p>
            
            <div class="flex flex-wrap items-center justify-end gap-x-2 gap-y-3 mt-auto pt-3 sm:pt-4 border-t border-slate-100" @click.stop>
              <div class="flex items-center gap-2 w-full">
                <a @click="trackEvent('click', product.id)" :href="product.affiliate_url" target="_blank" rel="noopener noreferrer" class="flex items-center justify-center flex-1 gap-1.5 px-3 py-2 bg-slate-900 hover:bg-primary-600 text-white text-sm font-medium rounded-lg transition-colors shadow-sm">
                  Beli <ExternalLink class="w-3.5 h-3.5 hidden sm:block" />
                </a>
                <button @click.stop="shareProduct(product)" class="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors cursor-pointer focus:outline-none group/btn shrink-0" title="Share Product">
                  <Check v-if="copiedLinkId === product.id" class="w-4 h-4 text-emerald-600" />
                  <Share2 v-else class="w-4 h-4 group-hover/btn:scale-110 transition-transform" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Infinite Scroll Loader -->
      <div ref="loadMoreRef" class="py-12 flex justify-center">
        <div v-if="isLoadingMore" class="w-8 h-8 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin"></div>
        <p v-else-if="!hasMore && products.length > 0" class="text-slate-400 text-sm">You've reached the end of the catalog.</p>
      </div>
    </main>

    <!-- Filter Drawer (Mobile & Triggered via button) -->
    <TransitionRoot appear :show="isFilterDrawerOpen" as="template">
      <Dialog as="div" @close="isFilterDrawerOpen = false" class="relative z-50">
        <TransitionChild
          as="template"
          enter="duration-300 ease-out"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="duration-200 ease-in"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto z-50">
          <div class="flex min-h-full items-end justify-center text-center">
            <TransitionChild
              as="template"
              enter="transform transition ease-out duration-300"
              enter-from="translate-y-full"
              enter-to="translate-y-0"
              leave="transform transition ease-in duration-200"
              leave-from="translate-y-0"
              leave-to="translate-y-full"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-t-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
                <div class="flex items-center justify-between mb-6">
                  <DialogTitle as="h3" class="text-lg font-bold leading-6 text-slate-900">
                    Filter Categories
                  </DialogTitle>
                  <button @click="isFilterDrawerOpen = false" class="p-2 text-slate-400 hover:bg-slate-100 rounded-full transition-colors cursor-pointer">
                    <X class="w-5 h-5" />
                  </button>
                </div>
                
                <div class="space-y-2 max-h-[60vh] overflow-y-auto no-scrollbar pb-4">
                  <button 
                    @click="selectCategory('')"
                    class="w-full flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-colors cursor-pointer"
                    :class="!selectedCategory ? 'bg-primary-50 text-primary-700' : 'bg-slate-50 text-slate-700 hover:bg-slate-100'"
                  >
                    <span>All Categories</span>
                    <Check v-if="!selectedCategory" class="w-4 h-4" />
                  </button>
                  <button 
                    v-for="cat in categories" :key="cat"
                    @click="selectCategory(cat)"
                    class="w-full flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-colors cursor-pointer"
                    :class="selectedCategory === cat ? 'bg-primary-50 text-primary-700' : 'bg-slate-50 text-slate-700 hover:bg-slate-100'"
                  >
                    <span>{{ cat }}</span>
                    <Check v-if="selectedCategory === cat" class="w-4 h-4" />
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <ProductDetailModal 
      :is-open="isDetailModalOpen" 
      :product-id="selectedProductId" 
      @close="isDetailModalOpen = false" 
    />
  </div>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
