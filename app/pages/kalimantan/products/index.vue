<script setup lang="ts">
import { Plus, Edit, Trash2, Tag, Image as ImageIcon, Package, Search, ChevronLeft, ChevronRight, Filter, Copy, Check } from 'lucide-vue-next'
import { ref, onMounted, computed, watch } from 'vue'

import AdminProductFormSlideOver from '~/components/admin/ProductFormSlideOver.vue'
import { useToast } from '~/composables/useToast'

definePageMeta({
  layout: 'admin'
})

const supabase = useSupabaseClient()
const products = ref<any[]>([])
const isLoading = ref(true)
const { addToast } = useToast()

// Pagination & Filter State
const searchInput = ref('')
const searchQuery = ref('')
const selectedCategory = ref('')
const page = ref(1)
const perPage = ref(10)
const totalItems = ref(0)
const totalPages = computed(() => Math.ceil(totalItems.value / perPage.value))

// Form state
const isFormOpen = ref(false)
const selectedProduct = ref<any>(null)

let searchTimeout: ReturnType<typeof setTimeout>
const handleSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    searchQuery.value = searchInput.value
    page.value = 1
    fetchProducts()
  }, 300)
}

watch([selectedCategory, perPage], () => {
  page.value = 1
  fetchProducts()
})

const prevPage = () => {
  if (page.value > 1) {
    page.value--
    fetchProducts()
  }
}

const nextPage = () => {
  if (page.value < totalPages.value) {
    page.value++
    fetchProducts()
  }
}

const openCreateForm = () => {
  selectedProduct.value = null
  isFormOpen.value = true
}

const openEditForm = (product: any) => {
  selectedProduct.value = product
  isFormOpen.value = true
}

const handleFormSaved = () => {
  fetchCategories()
  fetchProducts()
}

const categories = ref<string[]>([])
const fetchCategories = async () => {
  const { data } = await supabase.from('products').select('category')
  if (data) {
    const unique = [...new Set(data.map(d => d.category).filter(Boolean))]
    categories.value = unique as string[]
  }
}

const fetchProducts = async () => {
  isLoading.value = true
  let query = supabase
    .from('products')
    .select('*', { count: 'exact' })
    
  if (searchQuery.value) {
    query = query.ilike('title', `%${searchQuery.value}%`)
  }
  if (selectedCategory.value) {
    query = query.eq('category', selectedCategory.value)
  }

  const from = (page.value - 1) * perPage.value
  const to = from + perPage.value - 1
  query = query.range(from, to).order('created_at', { ascending: false })

  const { data, count, error } = await query
  
  if (!error && data) {
    products.value = data
    totalItems.value = count || 0
  }
  isLoading.value = false
}

onMounted(() => {
  fetchCategories()
  fetchProducts()
})

const copiedLinkId = ref<string | null>(null)
const copyToClipboard = (product: any) => {
  if (product.affiliate_url) {
    navigator.clipboard.writeText(product.affiliate_url)
    copiedLinkId.value = product.id
    addToast({ type: 'success', message: 'Affiliate link copied!' })
    setTimeout(() => {
      copiedLinkId.value = null
    }, 2000)
  }
}

const isToggling = ref<string | null>(null)
const toggleActiveStatus = async (product: any) => {
  isToggling.value = product.id
  const newStatus = !product.is_active
  const { error } = await supabase.from('products').update({ is_active: newStatus }).eq('id', product.id)
  if (!error) {
    product.is_active = newStatus
    addToast({ type: 'success', message: `Product ${newStatus ? 'activated' : 'deactivated'} successfully` })
  } else {
    addToast({ type: 'error', message: 'Failed to update product status' })
  }
  isToggling.value = null
}

const handleDelete = (id: string) => {
  // To be implemented in next step
  console.log('Delete', id)
}
</script>

<template>
  <div class="p-8">
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-slate-900 tracking-tight">Products</h1>
        <p class="text-sm text-slate-500 mt-1">Manage your storefront products and affiliates.</p>
      </div>
      <UiButton class="cursor-pointer" @click="openCreateForm">
        <Plus class="w-4 h-4 mr-2" />
        Add New Product
      </UiButton>
    </div>

    <!-- Filters Bar -->
    <div class="flex flex-col sm:flex-row gap-4 mb-6">
      <UiInput 
        v-model="searchInput" 
        @input="handleSearch"
        placeholder="Search products..." 
        class="flex-1 max-w-md"
      >
        <template #icon>
          <Search class="h-4 w-4" />
        </template>
      </UiInput>

      <UiSelect v-model="selectedCategory" class="w-full sm:w-48">
        <template #icon>
          <Filter class="h-4 w-4" />
        </template>
        <option value="">All Categories</option>
        <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
      </UiSelect>
    </div>

    <!-- Loading State -->
    <UiCard v-if="isLoading">
      <div class="py-12 flex items-center justify-center">
        <div class="w-8 h-8 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin"></div>
      </div>
    </UiCard>

    <!-- Empty State -->
    <UiCard v-else-if="products.length === 0">
      <div class="py-16 flex flex-col items-center justify-center text-center max-w-md mx-auto">
        <div class="w-20 h-20 aspect-square shrink-0 rounded-full bg-slate-100 flex items-center justify-center mb-6 ring-8 ring-slate-50">
          <Package class="w-12 h-12 text-slate-400" />
        </div>
        <h3 class="text-xl font-bold text-slate-900 mb-2">No products found</h3>
        <p class="text-slate-500 leading-relaxed">
          {{ searchQuery || selectedCategory ? 'No products match your current filters.' : 'You haven\'t added any products yet. Create your first product to start selling and managing your store.' }}
        </p>
        <UiButton v-if="!searchQuery && !selectedCategory" class="cursor-pointer mt-4" @click="openCreateForm">
          <Plus class="w-4 h-4 mr-2" />
          Add New Product
        </UiButton>
        <UiButton v-else variant="outline" class="cursor-pointer mt-4" @click="searchInput = ''; searchQuery = ''; selectedCategory = ''; fetchProducts()">
          Clear Filters
        </UiButton>
      </div>
    </UiCard>

    <!-- Data Table -->
    <div v-else class="space-y-4">
      <UiCard class="overflow-hidden p-0">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="bg-slate-50/50 border-b border-slate-100 text-slate-500">
              <tr>
                <th class="font-medium px-6 py-4 w-0">Actions</th>
                <th class="font-medium px-6 py-4">Product</th>
                <th class="font-medium px-6 py-4">Category</th>
                <th class="font-medium px-6 py-4">Price</th>
                <th class="font-medium px-6 py-4">Active</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr 
                v-for="product in products" 
                :key="product.id"
                class="hover:bg-slate-50 transition-colors group"
              >
                <td class="px-6 py-4">
                  <div class="flex items-center gap-2 transition-opacity">
                    <button @click="openEditForm(product)" class="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors cursor-pointer focus:outline-none" title="Edit Product">
                      <Edit class="w-4 h-4" />
                    </button>
                    <button v-if="product.affiliate_url" @click="copyToClipboard(product)" class="p-2 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-lg transition-colors cursor-pointer focus:outline-none" title="Copy Affiliate Link">
                      <Check v-if="copiedLinkId === product.id" class="w-4 h-4 text-emerald-600" />
                      <Copy v-else class="w-4 h-4" />
                    </button>
                    <button v-if="false" @click="handleDelete(product.id)" class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors cursor-pointer focus:outline-none" title="Delete Product">
                      <Trash2 class="w-4 h-4" />
                    </button>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-lg bg-slate-100 border border-slate-200 flex items-center justify-center overflow-hidden shrink-0">
                      <img v-if="product.image_url" :src="product.image_url" :alt="product.title" class="w-full h-full object-cover" />
                      <ImageIcon v-else class="w-5 h-5 text-slate-400" />
                    </div>
                    <div>
                      <p class="font-medium text-slate-900">{{ product.title }}</p>
                      <p class="text-xs text-slate-500 mt-0.5 line-clamp-1 max-w-[200px]" :title="product.short_description || product.slug">{{ product.short_description || product.slug }}</p>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-slate-100 text-slate-600 text-xs font-medium border border-slate-200">
                    <Tag class="w-3 h-3" />
                    {{ product.category || 'Uncategorized' }}
                  </span>
                </td>
                <td class="px-6 py-4 text-slate-600">
                  Rp. {{ product.price_text || '-' }}
                </td>
                <td class="px-6 py-4">
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" :checked="product.is_active" @change="toggleActiveStatus(product)" class="sr-only peer" :disabled="isToggling === product.id">
                    <div class="w-9 h-5 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-primary-600" :class="{'opacity-50': isToggling === product.id}"></div>
                  </label>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </UiCard>

      <!-- Pagination Footer -->
      <div class="flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-slate-600">
        <div class="flex items-center gap-3">
          <span>Show</span>
          <select v-model="perPage" class="border border-slate-200 rounded-md py-1 px-2 focus:outline-none focus:ring-2 focus:ring-primary-500 cursor-pointer">
            <option :value="10">10</option>
            <option :value="25">25</option>
            <option :value="50">50</option>
          </select>
          <span>per page</span>
        </div>
        
        <div>
          Showing {{ ((page - 1) * perPage) + 1 }} to {{ Math.min(page * perPage, totalItems) }} of {{ totalItems }} results
        </div>
        
        <div class="flex items-center gap-1">
          <button 
            @click="prevPage" 
            :disabled="page === 1"
            class="p-1 rounded-md hover:bg-slate-100 text-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
          >
            <ChevronLeft class="w-5 h-5" />
          </button>
          
          <div class="flex items-center gap-1 px-2">
            <span v-for="p in totalPages" :key="p" 
              @click="page = p; fetchProducts()"
              class="w-8 h-8 flex items-center justify-center rounded-md text-sm cursor-pointer transition-colors"
              :class="p === page ? 'bg-primary-50 text-primary-600 font-medium' : 'hover:bg-slate-100 text-slate-600'"
            >
              {{ p }}
            </span>
          </div>

          <button 
            @click="nextPage" 
            :disabled="page >= totalPages"
            class="p-1 rounded-md hover:bg-slate-100 text-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
          >
            <ChevronRight class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>

    <AdminProductFormSlideOver 
      :is-open="isFormOpen" 
      :product="selectedProduct" 
      :categories="categories"
      @close="isFormOpen = false" 
      @saved="handleFormSaved" 
    />
  </div>
</template>
