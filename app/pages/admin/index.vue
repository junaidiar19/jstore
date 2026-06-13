<script setup lang="ts">
definePageMeta({
  layout: 'admin'
})
</script>

<template>
  <div class="p-8">
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-slate-900">Dashboard</h1>
      <p class="text-slate-500 mt-1">Welcome back to JStore Admin</p>
    </div>

    <!-- Stats Overview (Placeholder for now) -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <UiCard class="border-none shadow-sm shadow-slate-200/50">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center text-blue-600">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-package"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
          </div>
          <div>
            <p class="text-sm font-medium text-slate-500">Total Products</p>
            <p class="text-2xl font-bold text-slate-900">0</p>
          </div>
        </div>
      </UiCard>
    </div>

    <!-- Quick Actions / Info -->
    <UiCard class="border-none shadow-sm shadow-slate-200/50">
      <div class="p-8 flex flex-col items-center justify-center text-slate-500 min-h-[300px]">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-bar-chart-3 text-slate-300 mb-4"><path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/></svg>
        <p class="font-medium text-slate-900">Dashboard Metrics</p>
        <p class="text-sm text-center max-w-sm mt-2">Ini adalah halaman dashboard admin utama. Beralih ke menu Product untuk mengelola data produk Anda.</p>
      </div>
    </UiCard>
  </div>
</template>
