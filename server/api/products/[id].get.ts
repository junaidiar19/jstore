import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  if (!id) {
    throw createError({ statusCode: 400, message: 'Product ID is required' })
  }

  const supabase = await serverSupabaseClient(event)
  
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('id', id)
    .single()

  if (error) {
    throw createError({ statusCode: 404, message: 'Product not found' })
  }

  return data
})
