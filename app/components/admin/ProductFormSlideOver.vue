<script setup lang="ts">
import { ref, watch } from 'vue'
import { z } from 'zod'
import { X, Upload, Loader2, CheckCircle2, Image as ImageIcon, Copy, Wand2, HardDrive } from 'lucide-vue-next'
import UiInput from '~/components/ui/Input.vue'
import UiSelect from '~/components/ui/Select.vue'
import UiTextarea from '~/components/ui/Textarea.vue'
import { useToast } from '~/composables/useToast'
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionRoot,
  TransitionChild,
} from '@headlessui/vue'

const props = defineProps<{
  isOpen: boolean
  product: any | null
  categories?: string[]
}>()

const emit = defineEmits(['close', 'saved'])
const { addToast } = useToast()

const supabase = useSupabaseClient()
const isSaving = ref(false)
const isUploading = ref(false)
const isGeneratingCaption = ref(false)
const isCopiedTiktok = ref(false)
const isCopiedShopee = ref(false)
const imageFile = ref<File | null>(null)
const errors = ref<Record<string, string>>({})
const globalError = ref('')
const activeTab = ref('public')

const form = ref({
  title: '',
  slug: '',
  category: '',
  price_text: '',
  image_url: '',
  affiliate_url: '',
  gdrive_link: '',
  ai_caption_tiktok: '',
  ai_caption_shopee: '',
  short_description: '',
  tags: '',
  is_active: true,
  sort_order: 0
})

const schema = z.object({
  title: z.string().min(1, "Title is required"),
  slug: z.string().min(1, "Slug is required").regex(/^[a-z0-9-]+$/, "Invalid slug format (lowercase letters, numbers, and dashes only)"),
  category: z.string().min(1, 'Category is required'),
  price_text: z.string().optional().nullable(),
  image_url: z.string().url("Must be a valid URL").or(z.literal('')).optional().nullable(),
  affiliate_url: z.string().url("Must be a valid URL").or(z.literal('')).optional().nullable(),
  gdrive_link: z.string().url('Invalid URL').or(z.literal('')),
  ai_caption_tiktok: z.string().optional(),
  ai_caption_shopee: z.string().optional(),
  short_description: z.string().optional().nullable(),
  tags: z.string().optional().nullable(),
  is_active: z.boolean(),
  sort_order: z.number().int()
})

// Auto slug generation
watch(() => form.value.title, (newTitle) => {
  if (!props.product) {
    form.value.slug = newTitle.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '')
  }
})

// Auto-format price_text to Rupiah format
watch(() => form.value.price_text, (newVal) => {
  if (newVal === null || newVal === undefined) return
  const strVal = String(newVal)
  const digits = strVal.replace(/\D/g, '')
  if (digits === '') {
    form.value.price_text = ''
    return
  }
  const formatted = new Intl.NumberFormat('id-ID').format(Number(digits))
  if (strVal !== formatted) {
    form.value.price_text = formatted
  }
})

// Initialize form
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    errors.value = {}
    globalError.value = ''
    activeTab.value = 'public'
    if (props.product) {
      form.value = { 
        ...props.product, 
        tags: props.product.tags ? props.product.tags.join(', ') : '',
        gdrive_link: props.product.gdrive_link || '',
        ai_caption_tiktok: props.product.ai_caption_tiktok || '',
        ai_caption_shopee: props.product.ai_caption_shopee || ''
      }
    } else {
      form.value = {
        title: '', slug: '', category: '', price_text: '', image_url: '', 
        affiliate_url: '', gdrive_link: '', ai_caption_tiktok: '', ai_caption_shopee: '', short_description: '', tags: '', is_active: true, sort_order: 0
      }
    }
  }
})

const handleFileUpload = async (event: Event) => {
  const e = event as any
  if (e.target.files && e.target.files[0]) {
    imageFile.value = e.target.files[0]
    
    isUploading.value = true
    const file = imageFile.value
    const fileExt = file.name.split('.').pop()
    const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
    const filePath = `${fileName}`

    const { error: uploadError } = await supabase.storage
      .from('products')
      .upload(filePath, file)

    if (uploadError) {
      globalError.value = 'Failed to upload image'
      isUploading.value = false
      return
    }

    const { data } = supabase.storage.from('products').getPublicUrl(filePath)
    form.value.image_url = data.publicUrl
    isUploading.value = false
  }
}

const generateCaption = async () => {
  try {
    isGeneratingCaption.value = true
    const { title, short_description, price_text, category } = form.value
    
    const response = await $fetch('/api/generate-caption', {
      method: 'POST',
      body: { title, short_description, price_text, category }
    })
    
    form.value.ai_caption_tiktok = response.caption_tiktok
    form.value.ai_caption_shopee = response.caption_shopee
    addToast({ type: 'success', message: 'Captions generated with AI!' })
  } catch (err: any) {
    globalError.value = err.data?.message || 'Failed to generate captions'
    addToast({ type: 'error', message: 'Failed to generate captions' })
  } finally {
    isGeneratingCaption.value = false
  }
}

const copyTiktokCaption = () => {
  if (form.value.ai_caption_tiktok) {
    navigator.clipboard.writeText(form.value.ai_caption_tiktok)
    isCopiedTiktok.value = true
    setTimeout(() => isCopiedTiktok.value = false, 2000)
    addToast({ type: 'success', message: 'TikTok caption copied!' })
  }
}

const copyShopeeCaption = () => {
  if (form.value.ai_caption_shopee) {
    navigator.clipboard.writeText(form.value.ai_caption_shopee)
    isCopiedShopee.value = true
    setTimeout(() => isCopiedShopee.value = false, 2000)
    addToast({ type: 'success', message: 'Shopee caption copied!' })
  }
}

const save = async () => {
  try {
    errors.value = {}
    
    const parsed = schema.parse({
      ...form.value,
      sort_order: Number(form.value.sort_order)
    })
    
    isSaving.value = true
    
    const tagsArray = parsed.tags ? parsed.tags.split(',').map(t => t.trim()).filter(Boolean) : []
    
    const dataToSave = { 
      ...parsed, 
      tags: tagsArray 
    }

    if (props.product) {
      const { error } = await supabase.from('products').update(dataToSave).eq('id', props.product.id)
      if (error) throw error
      addToast({ type: 'success', message: 'Product updated successfully!' })
    } else {
      const { error } = await supabase.from('products').insert(dataToSave)
      if (error) throw error
      addToast({ type: 'success', message: 'Product created successfully!' })
    }

    emit('saved')
    emit('close')
  } catch (err: any) {
    if (err instanceof z.ZodError) {
      err.errors.forEach(e => {
        if (e.path[0]) {
          errors.value[e.path[0] as string] = e.message
        }
      })
    } else {
      globalError.value = err.message
    }
  } finally {
    isSaving.value = false
  }
}
</script>

<template>
  <TransitionRoot as="template" :show="isOpen">
    <Dialog as="div" class="relative z-50" @close="emit('close')">
      <!-- Backdrop -->
      <TransitionChild
        as="template"
        enter="ease-in-out duration-300"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="ease-in-out duration-300"
        leave-from="opacity-100"
        leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm transition-opacity" />
      </TransitionChild>

      <div class="fixed inset-0 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full sm:pl-10">
            <!-- Slide-over panel -->
            <TransitionChild
              as="template"
              enter="transform transition ease-in-out duration-300"
              enter-from="translate-x-full"
              enter-to="translate-x-0"
              leave="transform transition ease-in-out duration-300"
              leave-from="translate-x-0"
              leave-to="translate-x-full"
            >
              <DialogPanel class="pointer-events-auto w-screen sm:w-[50vw]">
                <div class="flex h-full flex-col bg-white shadow-2xl">
                  
                  <!-- Header -->
                  <div class="px-6 py-6 border-b border-slate-100 flex items-center justify-between">
                    <DialogTitle as="h2" class="text-xl font-semibold text-slate-900">
                      {{ product ? 'Edit Product' : 'Add New Product' }}
                    </DialogTitle>
                    <button 
                      @click="emit('close')"
                      class="p-2 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition-colors focus:outline-none cursor-pointer"
                    >
                      <X class="w-5 h-5" />
                    </button>
                  </div>

                  <!-- Body (Scrollable form) -->
                  <div class="flex-1 overflow-y-auto p-6">
                    
                    <div v-if="globalError" class="p-3 mb-6 rounded-lg bg-red-50 border border-red-100 text-sm text-red-600 flex items-center gap-2">
                      <X class="w-4 h-4 shrink-0" />
                      {{ globalError }}
                    </div>

                    <!-- Tabs Header -->
                    <div class="flex items-center gap-6 border-b border-slate-200 mb-6">
                      <button 
                        @click.prevent="activeTab = 'public'"
                        :class="['pb-3 px-1 text-sm font-semibold transition-colors border-b-2 cursor-pointer outline-none', activeTab === 'public' ? 'border-primary-600 text-primary-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']"
                      >
                        Public Landing Page
                      </button>
                      <button 
                        @click.prevent="activeTab = 'affiliate'"
                        :class="['pb-3 px-1 text-sm font-semibold transition-colors border-b-2 cursor-pointer outline-none', activeTab === 'affiliate' ? 'border-primary-600 text-primary-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']"
                      >
                        Konten Video Affiliate
                      </button>
                    </div>

                    <!-- Tab 1: Public Landing Page -->
                    <div v-show="activeTab === 'public'" class="space-y-6">

                      <!-- Image Upload -->
                      <div class="space-y-1.5">
                        <label class="block text-sm font-medium text-slate-700">Image</label>
                        <div class="flex items-start gap-4">
                          <div class="w-24 h-24 rounded-xl border border-slate-200 overflow-hidden shrink-0 bg-slate-50 flex items-center justify-center relative group">
                            <img v-if="form.image_url" :src="form.image_url" class="w-full h-full object-cover" />
                            <ImageIcon v-else class="w-8 h-8 text-slate-300" />
                            <div class="absolute inset-0 bg-slate-900/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                              <label class="cursor-pointer p-2 text-white hover:text-primary-200 transition-colors">
                                <Upload class="w-5 h-5" />
                                <input type="file" accept="image/*" class="hidden" @change="handleFileUpload" :disabled="isUploading">
                              </label>
                            </div>
                          </div>
                          <div class="flex-1 space-y-2">
                            <UiInput v-model="form.image_url" placeholder="Or paste image URL here" :error="errors.image_url" />
                            <p class="text-xs text-slate-500">Upload an image (max 2MB) atau paste direct image URL.</p>
                            <div v-if="isUploading" class="flex items-center gap-2 text-sm text-primary-600 font-medium">
                              <Loader2 class="w-4 h-4 animate-spin" /> Uploading...
                            </div>
                          </div>
                        </div>
                      </div>

                      <div class="grid grid-cols-1 gap-6">
                        <UiInput label="Title *" v-model="form.title" placeholder="Product name" :error="errors.title" />
                        
                        <UiInput label="Slug *" v-model="form.slug" placeholder="product-slug" :error="errors.slug" />

                        <div class="grid grid-cols-2 gap-4">
                          <div class="space-y-1.5">
                            <UiInput 
                              label="Category"
                              v-model="form.category" 
                              list="categories-list" 
                              placeholder="E.g. Electronics"
                              :error="errors.category"
                            />
                            <datalist id="categories-list">
                              <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                            </datalist>
                          </div>
                          
                          <UiInput label="Price (Rp)" v-model="form.price_text" placeholder="100.000" :error="errors.price_text" />
                        </div>

                        <UiInput label="Affiliate URL" v-model="form.affiliate_url" placeholder="https://..." :error="errors.affiliate_url" />

                        <div class="space-y-1.5">
                          <label class="block text-sm font-medium text-slate-700">Short Description</label>
                          <textarea 
                            v-model="form.short_description" 
                            rows="5" 
                            class="w-full px-4 py-3 bg-white border border-slate-300 rounded-xl focus:outline-none focus:ring-3 focus:ring-primary-200 focus:border-primary-500 transition-all resize-none text-sm text-slate-900"
                            placeholder="Brief description of the product"
                          ></textarea>
                          <p v-if="errors.short_description" class="text-xs text-red-500">{{ errors.short_description }}</p>
                        </div>

                        <div class="flex items-center gap-4 py-2">
                          <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" v-model="form.is_active" class="sr-only peer">
                            <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                            <span class="ml-3 text-sm font-medium text-slate-700">Active Status</span>
                          </label>
                        </div>
                        
                        <UiInput label="Sort Order" type="number" v-model="form.sort_order" :error="errors.sort_order" />
                      </div>
                    </div>

                    <!-- Tab 2: Konten Video Affiliate -->
                    <div v-show="activeTab === 'affiliate'" class="space-y-6">
                      <div class="grid grid-cols-1 gap-6">
                        <div class="space-y-1.5">
                          <UiInput label="Google Drive Link" v-model="form.gdrive_link" placeholder="https://drive.google.com/..." :error="errors.gdrive_link" />
                          <div v-if="form.gdrive_link" class="pt-1">
                            <a :href="form.gdrive_link" target="_blank" rel="noopener noreferrer" class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-slate-50 hover:bg-slate-100 text-slate-700 hover:text-primary-600 text-xs font-semibold rounded border border-slate-200 transition-colors shadow-sm">
                              <HardDrive class="w-3.5 h-3.5" /> Buka Link Google Drive
                            </a>
                          </div>
                        </div>

                        <!-- AI Caption Generator -->
                        <div class="space-y-4 p-4 bg-primary-50/50 rounded-xl border border-primary-100">
                          <div class="flex items-center justify-between">
                            <label class="block text-sm font-semibold text-slate-700">Auto Caption & Hashtags</label>
                            <button @click.prevent="generateCaption" :disabled="isGeneratingCaption" class="text-xs font-semibold px-2 py-1.5 bg-primary-600 text-white hover:bg-primary-700 shadow-sm rounded-md transition-colors flex items-center gap-1 cursor-pointer disabled:opacity-50">
                              <Loader2 v-if="isGeneratingCaption" class="w-3.5 h-3.5 animate-spin" />
                              <Wand2 v-else class="w-3.5 h-3.5" /> 
                              {{ isGeneratingCaption ? 'Generating...' : 'Generate' }}
                            </button>
                          </div>
                          
                          <div class="space-y-2">
                            <div class="flex items-center justify-between">
                              <label class="block text-xs font-medium text-slate-600">TikTok / Instagram</label>
                              <button v-if="form.ai_caption_tiktok" @click.prevent="copyTiktokCaption" class="text-xs font-semibold px-2 py-1.5 bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 shadow-sm rounded-md transition-colors flex items-center gap-1 cursor-pointer w-24 justify-center">
                                <template v-if="isCopiedTiktok">
                                  <CheckCircle2 class="w-3.5 h-3.5 text-green-500" /> <span class="text-green-600">Copied!</span>
                                </template>
                                <template v-else>
                                  <Copy class="w-3.5 h-3.5" /> Copy
                                </template>
                              </button>
                            </div>
                            <UiTextarea v-model="form.ai_caption_tiktok" :rows="4" placeholder="Klik Generate untuk membuat caption TikTok otomatis..." />
                          </div>

                          <div class="space-y-2">
                            <div class="flex items-center justify-between">
                              <label class="block text-xs font-medium text-slate-600">Shopee (Max 150 chars)</label>
                              <button v-if="form.ai_caption_shopee" @click.prevent="copyShopeeCaption" class="text-xs font-semibold px-2 py-1.5 bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 shadow-sm rounded-md transition-colors flex items-center gap-1 cursor-pointer w-24 justify-center">
                                <template v-if="isCopiedShopee">
                                  <CheckCircle2 class="w-3.5 h-3.5 text-green-500" /> <span class="text-green-600">Copied!</span>
                                </template>
                                <template v-else>
                                  <Copy class="w-3.5 h-3.5" /> Copy
                                </template>
                              </button>
                            </div>
                            <UiTextarea v-model="form.ai_caption_shopee" :rows="3" placeholder="Klik Generate untuk membuat caption Shopee otomatis..." />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Footer -->
                  <div class="px-6 py-4 border-t border-slate-100 flex items-center justify-end gap-3 bg-slate-50/50">
                    <button @click="emit('close')" :disabled="isSaving" class="px-4 py-2 text-sm font-medium text-slate-500 hover:text-slate-800 hover:bg-slate-200/50 rounded-lg transition-colors cursor-pointer focus:outline-none disabled:opacity-50">
                      Cancel
                    </button>
                    <UiButton @click="save" :disabled="isSaving" class="cursor-pointer relative overflow-hidden min-w-[120px]">
                      <span :class="{'opacity-0': isSaving}">Save Product</span>
                      <div v-if="isSaving" class="absolute inset-0 flex items-center justify-center">
                        <Loader2 class="w-5 h-5 animate-spin" />
                      </div>
                    </UiButton>
                  </div>

                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>
