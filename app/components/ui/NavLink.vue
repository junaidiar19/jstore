<script setup lang="ts">
import { useRoute } from 'vue-router'
import { computed } from 'vue'

const props = defineProps<{
  to: string
  label: string
  target?: string
}>()

const route = useRoute()
const isActive = computed(() => {
  if (props.target === '_blank') return false
  return route.path === props.to
})
</script>

<template>
  <NuxtLink 
    :to="to" 
    :target="target"
    class="relative flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors"
    :class="[
      isActive 
        ? 'text-white bg-white/10' 
        : 'text-slate-400 hover:bg-white/5 hover:text-white'
    ]"
  >
    <span v-if="isActive" class="absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-5 bg-[#df672f] rounded-r-full"></span>
    <span :class="[isActive ? 'text-[#df672f]' : 'currentColor']" class="flex items-center justify-center">
      <slot name="icon" />
    </span>
    {{ label }}
  </NuxtLink>
</template>
