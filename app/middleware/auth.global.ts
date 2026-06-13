export default defineNuxtRouteMiddleware((to, from) => {
  const user = useSupabaseUser()
  
  // Hanya lindungi rute yang diawali dengan /kalimantan (termasuk sub-route nya)
  if (to.path.startsWith('/kalimantan')) {
    if (!user.value) {
      // Redirect ke login jika belum login
      return navigateTo('/banjarmasin')
    }
  }

  // Jika user sudah login dan mencoba mengakses halaman login lagi, redirect ke kalimantan
  if (to.path === '/banjarmasin' && user.value) {
    return navigateTo('/kalimantan')
  }
})
