<template>
  <div class="min-h-screen bg-slate-50 flex items-center justify-center p-4 selection:bg-primary-100 relative">
    <!-- Background Pattern Grid -->
    <div class="absolute inset-0 z-0 bg-grid-subtle pointer-events-none"></div>
    
    <div class="relative z-10 w-full max-w-md">
      <slot />
    </div>
  </div>
</template>
