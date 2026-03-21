export default {
  async fetch(request) {

    const allowedOrigins = [
      'https://kenny-mineral.github.io',
      'https://endearing-empanada-68c8c7.netlify.app',
      'http://localhost'
    ];

    const origin = request.headers.get('Origin') || '';
    const corsOrigin = allowedOrigins.includes(origin)
      ? origin
      : allowedOrigins[0];

    const corsHeaders = {
      'Access-Control-Allow-Origin': corsOrigin,
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    // TOKEN EXCHANGE ENDPOINT
    if (path === '/token' && request.method === 'POST') {
      try {
        const body = await request.text();
        const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: body
        });
        const tokenData = await tokenRes.text();
        return new Response(tokenData, {
          status: tokenRes.status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      } catch (err) {
        return new Response(
          JSON.stringify({ error: err.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
        );
      }
    }

    // TOKEN REFRESH ENDPOINT
    if (path === '/refresh' && request.method === 'POST') {
      try {
        const body = await request.text();
        const refreshRes = await fetch('https://oauth2.googleapis.com/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: body
        });
        const refreshData = await refreshRes.text();
        return new Response(refreshData, {
          status: refreshRes.status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      } catch (err) {
        return new Response(
          JSON.stringify({ error: err.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
        );
      }
    }

    // HEALTH CHECK - use this to verify worker is updated
    if (path === '/health') {
      return new Response(
        JSON.stringify({ status: 'ok', version: '2.0', endpoints: ['/', '/token', '/refresh', '/health'] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
      );
    }

    // PRODUCT PAGE SCRAPER
    const targetUrl = url.searchParams.get('url');

    if (!targetUrl) {
      return new Response(
        JSON.stringify({ error: 'No URL provided', version: '2.0' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
      );
    }

    try {
      const response = await fetch(targetUrl, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'no-cache',
        },
        redirect: 'follow'
      });

      const html = await response.text();

      const titleMatch = html.match(/<title[^>]*>([^<]{3,})<\/title>/i);
      const descMatch =
        html.match(/<meta[^>]+name=["']description["'][^>]+content=["']([^"']{10,})/i) ||
        html.match(/<meta[^>]+content=["']([^"']{10,})["'][^>]+name=["']description["']/i) ||
        html.match(/<meta[^>]+property=["']og:description["'][^>]+content=["']([^"']{10,})/i);
      const priceMatch =
        html.match(/itemprop=["']price["'][^>]+content=["']([\d\.]+)/i) ||
        html.match(/<span[^>]+class=["'][^"']*price[^"']*["'][^>]*>[\$£€NZ\s]*([\d,\.]+)/i) ||
        html.match(/["']price["']:\s*["']([\d\.]+)/i);
      const ogImageMatch =
        html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)/i) ||
        html.match(/<meta[^>]+content=["']([^"']+)["'][^>]+property=["']og:image["']/i);
      const imgTagMatch = html.match(
        /<img[^>]+(?:id|class)=["'][^"']*(?:main|primary|product|hero|featured)[^"']*["'][^>]+src=["'](https?:[^"']+)/i
      ) || html.match(
        /<img[^>]+src=["'](https?:[^"']{20,})["'][^>]*(?:width=["']([4-9]\d{2}|\d{4,}))/i
      );
      const imageUrl = ogImageMatch ? ogImageMatch[1] : imgTagMatch ? imgTagMatch[1] : '';
      const plainText = html
        .replace(/<script[\s\S]*?<\/script>/gi, '')
        .replace(/<style[\s\S]*?<\/style>/gi, '')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim()
        .slice(0, 3000);

      return new Response(
        JSON.stringify({
          title: titleMatch ? titleMatch[1].trim() : '',
          description: descMatch ? descMatch[1].trim() : '',
          price: priceMatch ? priceMatch[1].replace(',', '') : '',
          image_url: imageUrl,
          text: plainText,
          url: targetUrl
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
      );

    } catch (err) {
      return new Response(
        JSON.stringify({ error: err.message, url: targetUrl }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }}
      );
    }
  }
};
