<script setup lang="ts">
</script>

<template>
  <div class="rounded-xl border border-slate-200 bg-white text-slate-950 shadow-sm">
    <div v-if="$slots.header" class="flex flex-col space-y-1.5 p-6 border-b border-slate-100">
      <slot name="header" />
    </div>
    <div class="p-6">
      <slot />
    </div>
    <div v-if="$slots.footer" class="flex items-center p-6 pt-0">
      <slot name="footer" />
    </div>
  </div>
</template>
