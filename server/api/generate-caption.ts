export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const config = useRuntimeConfig()

  if (!config.openRouterKey) {
    throw createError({ statusCode: 500, message: 'OPEN_ROUTER_KEY is missing in server configuration' })
  }

  const { title, short_description, price_text, category } = body

  const prompt = `You are a professional social media manager for an e-commerce affiliate platform. Write an engaging and casual caption for Instagram/TikTok promoting the following product.

Product Name: ${title}
Short Description: ${short_description || 'No description provided'}
Price: Rp ${price_text || 'Not specified'}
Category: ${category}

Rules:
1. Make the caption enthusiastic and persuasive.
2. Include emojis.
3. Include a call to action asking them to check the link in bio or visit the link.
4. Include 3-5 relevant hashtags based on the product name and category.
5. ALL hashtags MUST be entirely in lowercase.
6. DO NOT include the hashtag #jstore under any circumstances.
7. Output ONLY the caption text, no extra markdown formatting or explanations. Write in Indonesian.`

  try {
    const response = await $fetch<any>('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.openRouterKey}`,
        'Content-Type': 'application/json'
      },
      body: {
        model: 'openrouter/free',
        messages: [
          { role: 'user', content: prompt }
        ]
      }
    })

    const caption = response.choices?.[0]?.message?.content || ''
    
    return {
      caption: caption.trim()
    }
  } catch (err: any) {
    console.error('OpenRouter API Error:', err)
    throw createError({ statusCode: 500, message: 'Failed to generate caption from AI' })
  }
})
