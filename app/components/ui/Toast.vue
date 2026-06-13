<script setup lang="ts">
import { CheckCircle, XCircle, Info, X } from 'lucide-vue-next'
import type { Toast } from '~/composables/useToast'

const props = defineProps<{
  toast: Toast
}>()

const emit = defineEmits(['close'])
</script>

<template>
  <div class="pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg bg-white shadow-lg border-1 border-slate-200">
    <div class="p-4">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <CheckCircle v-if="toast.type === 'success'" class="h-6 w-6 text-green-400" aria-hidden="true" />
          <XCircle v-else-if="toast.type === 'error'" class="h-6 w-6 text-red-400" aria-hidden="true" />
          <Info v-else class="h-6 w-6 text-blue-400" aria-hidden="true" />
        </div>
        <div class="ml-3 w-0 flex-1 pt-0.5">
          <p class="text-sm font-medium text-slate-900">{{ toast.message }}</p>
        </div>
        <div class="ml-4 flex flex-shrink-0">
          <button @click="$emit('close')" type="button" class="inline-flex rounded-lg bg-white p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-600 focus:outline-none focus:ring-2 focus:ring-primary-500 cursor-pointer transition-colors">
            <span class="sr-only">Close</span>
            <X class="h-4 w-4" aria-hidden="true" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
