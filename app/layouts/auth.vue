<template>
  <div class="min-h-screen bg-slate-100 flex items-center justify-center p-4 selection:bg-blue-100">
    <!-- Subtle background pattern or gradient mimicking modern soft UI -->
    <!-- <div class="absolute inset-0 z-0 bg-gradient-to-b from-blue-100/60 via-slate-50 to-slate-100"></div> -->
    
    <div class="relative z-10 w-full max-w-md">
      <slot />
    </div>
  </div>
</template>
