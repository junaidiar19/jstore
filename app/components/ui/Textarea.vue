<script setup lang="ts">
const props = defineProps<{
  modelValue: string | number
  placeholder?: string
  rows?: number
}>()

const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <div class="relative w-full">
    <textarea 
      :value="modelValue" 
      @input="emit('update:modelValue', ($event.target as HTMLTextAreaElement).value)"
      :placeholder="placeholder"
      :rows="rows || 4"
      class="w-full bg-slate-50 border border-slate-200 text-slate-900 text-sm rounded-lg focus:ring-3 focus:ring-primary-500/20 focus:border-primary-500 block py-3 px-4 transition-all duration-100 placeholder:text-slate-400"
    ></textarea>
  </div>
</template>
