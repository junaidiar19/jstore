<script setup lang="ts">
</script>

<template>
  <div class="rounded-xl border border-slate-200 bg-white text-slate-950 shadow-sm">
    <div v-if="$slots.header" class="flex flex-col space-y-1.5 p-4 border-b border-slate-100">
      <slot name="header" />
    </div>
    <div class="p-4">
      <slot />
    </div>
    <div v-if="$slots.footer" class="flex items-center p-4 pt-0">
      <slot name="footer" />
    </div>
  </div>
</template>
