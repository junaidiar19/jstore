<script setup lang="ts">
import { watch, ref } from 'vue'
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild } from '@headlessui/vue'
import { X, ExternalLink, Store, Share2, Check } from 'lucide-vue-next'
import { useToast } from '~/composables/useToast'

const props = defineProps<{
  isOpen: boolean
  productId: string | null
}>()

const emit = defineEmits(['close'])
const { addToast } = useToast()

const { data: product, pending, execute } = useFetch(() => `/api/products/${props.productId}`, {
  immediate: false,
  watch: false
})

watch(() => props.isOpen, (newVal) => {
  if (newVal && props.productId) {
    execute()
  }
})

const copied = ref(false)
const copyLink = () => {
  if (product.value?.affiliate_url) {
    navigator.clipboard.writeText(product.value.affiliate_url)
    copied.value = true
    addToast({ type: 'success', message: 'Link copied to clipboard!' })
    setTimeout(() => { copied.value = false }, 2000)
  }
}

const formatPrice = (price: string) => {
  if (!price) return ''
  return `Rp ${price}`
}
</script>

<template>
  <TransitionRoot as="template" :show="isOpen">
    <Dialog as="div" class="relative z-50" @close="emit('close')">
      <!-- Backdrop -->
      <TransitionChild
        as="template"
        enter="ease-out duration-300"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="ease-in duration-200"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity" />
      </TransitionChild>

      <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
          <TransitionChild
            as="template"
            enter="ease-out duration-300"
            enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enter-to="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leave-from="opacity-100 translate-y-0 sm:scale-100"
            leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <DialogPanel class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-2xl border border-slate-100">
              
              <!-- Close button -->
              <div class="absolute right-4 top-4 z-10 bg-white/80 backdrop-blur-sm rounded-full p-1 shadow-sm">
                <button @click="emit('close')" class="p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors cursor-pointer focus:outline-none">
                  <X class="w-5 h-5" />
                </button>
              </div>

              <!-- Loading State -->
              <div v-if="pending" class="p-12 flex flex-col items-center justify-center min-h-[400px]">
                <div class="w-10 h-10 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin mb-4"></div>
                <p class="text-slate-500 font-medium animate-pulse">Loading detail produk...</p>
              </div>

              <!-- Content -->
              <div v-else-if="product" class="flex flex-col sm:flex-row">
                <!-- Image Section -->
                <div class="w-full sm:w-2/5 bg-slate-100 relative shrink-0">
                  <div class="aspect-square sm:aspect-auto sm:h-full relative overflow-hidden">
                    <img v-if="product.image_url" :src="product.image_url" :alt="product.title" class="w-full h-full object-cover" />
                    <div v-else class="w-full h-full flex items-center justify-center min-h-[300px]">
                      <Store class="w-16 h-16 text-slate-300" />
                    </div>
                  </div>
                </div>

                <!-- Info Section -->
                <div class="p-6 sm:p-8 flex flex-col flex-1">
                  <!-- Category & Tags -->
                  <div class="flex items-center gap-2 mb-3">
                    <span v-if="product.category" class="px-2.5 py-1 bg-primary-50 text-primary-700 text-xs font-semibold rounded-full">
                      {{ product.category }}
                    </span>
                  </div>

                  <!-- Title -->
                  <DialogTitle as="h3" class="text-xl sm:text-2xl font-bold text-slate-900 mb-2 leading-tight">
                    {{ product.title }}
                  </DialogTitle>

                  <!-- Price -->
                  <div v-if="product.price_text" class="text-2xl font-extrabold text-primary-600 mb-6">
                    {{ formatPrice(product.price_text) }}
                  </div>

                  <!-- Description -->
                  <div class="prose prose-sm prose-slate text-slate-600 mb-8 whitespace-pre-wrap flex-1">
                    {{ product.short_description || 'Belum ada deskripsi untuk produk ini.' }}
                  </div>

                  <!-- Action Buttons -->
                  <div class="flex items-center gap-3 mt-auto pt-6 border-t border-slate-100">
                    <a :href="product.affiliate_url" target="_blank" rel="noopener noreferrer" class="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-primary-600 hover:bg-primary-700 text-white font-semibold rounded-xl transition-all shadow-md shadow-primary-600/20 active:scale-[0.98]">
                      Beli Sekarang <ExternalLink class="w-4 h-4" />
                    </a>
                    
                    <button @click="copyLink" class="p-3 text-slate-600 bg-slate-100 hover:bg-slate-200 hover:text-primary-600 rounded-xl transition-colors cursor-pointer focus:outline-none flex-shrink-0" title="Copy Affiliate Link">
                      <Check v-if="copied" class="w-5 h-5 text-emerald-600" />
                      <Share2 v-else class="w-5 h-5" />
                    </button>
                  </div>
                </div>
              </div>

            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>
