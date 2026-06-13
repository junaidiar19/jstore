<script setup lang="ts">
import { ref, watch } from 'vue'
import { z } from 'zod'
import { X, Upload, Loader2, Image as ImageIcon } from 'lucide-vue-next'
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

const supabase = useSupabaseClient()
const isSaving = ref(false)
const isUploading = ref(false)
const errors = ref<Record<string, string>>({})
const globalError = ref('')

const form = ref({
  title: '',
  slug: '',
  category: '',
  price_text: '',
  image_url: '',
  affiliate_url: '',
  short_description: '',
  tags: '',
  is_active: true,
  sort_order: 0
})

const schema = z.object({
  title: z.string().min(1, "Title is required"),
  slug: z.string().min(1, "Slug is required").regex(/^[a-z0-9-]+$/, "Invalid slug format (lowercase letters, numbers, and dashes only)"),
  category: z.string().optional().nullable(),
  price_text: z.string().optional().nullable(),
  image_url: z.string().url("Must be a valid URL").or(z.literal('')).optional().nullable(),
  affiliate_url: z.string().url("Must be a valid URL").or(z.literal('')).optional().nullable(),
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
    if (props.product) {
      form.value = { 
        ...props.product, 
        tags: props.product.tags ? props.product.tags.join(', ') : '' 
      }
    } else {
      form.value = {
        title: '', slug: '', category: '', price_text: '', image_url: '', 
        affiliate_url: '', short_description: '', tags: '', is_active: true, sort_order: 0
      }
    }
  }
})

const handleFileUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  isUploading.value = true
  const fileExt = file.name.split('.').pop()
  const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
  const filePath = `${fileName}`

  const { error: uploadError } = await supabase.storage
    .from('products')
    .upload(filePath, file)

  if (uploadError) {
    console.error('Upload error', uploadError)
    globalError.value = 'Failed to upload image'
    isUploading.value = false
    return
  }

  const { data } = supabase.storage.from('products').getPublicUrl(filePath)
  form.value.image_url = data.publicUrl
  isUploading.value = false
}

const save = async () => {
  try {
    errors.value = {}
    
    // Parse tags to array before validation to ensure we validate the raw object form correctly
    // Wait, the schema expects strings for tags, so we parse tags AFTER zod validation.
    
    const parsed = schema.parse({
      ...form.value,
      sort_order: Number(form.value.sort_order)
    })
    
    isSaving.value = true
    
    // Process tags string to array
    const tagsArray = parsed.tags ? parsed.tags.split(',').map(t => t.trim()).filter(Boolean) : []
    
    const dataToSave = { 
      ...parsed, 
      tags: tagsArray 
    }

    if (props.product) {
      // Update
      const { error } = await supabase.from('products').update(dataToSave).eq('id', props.product.id)
      if (error) throw error
    } else {
      // Insert
      const { error } = await supabase.from('products').insert(dataToSave)
      if (error) throw error
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
                  <div class="flex-1 overflow-y-auto p-6 space-y-6">
                    
                    <div v-if="globalError" class="p-3 rounded-lg bg-red-50 border border-red-100 text-sm text-red-600 flex items-center gap-2">
                      <X class="w-4 h-4 shrink-0" />
                      {{ globalError }}
                    </div>

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
                          <p class="text-xs text-slate-500">Upload an image (max 2MB) or paste a direct image URL.</p>
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
                          rows="3" 
                          class="w-full px-4 py-3 bg-white border border-slate-300 rounded-xl focus:outline-none focus:ring-3 focus:ring-primary-200 focus:border-primary-500 transition-all resize-none text-sm text-slate-900"
                          placeholder="Brief description of the product"
                        ></textarea>
                        <p v-if="errors.short_description" class="text-xs text-red-500">{{ errors.short_description }}</p>
                      </div>

                      <div class="space-y-1.5" v-if="false">
                        <UiInput label="Tags" v-model="form.tags" placeholder="tag1, tag2, tag3" :error="errors.tags" />
                        <p class="text-xs text-slate-500">Comma separated</p>
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
