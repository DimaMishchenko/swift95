import type { APIRoute } from 'astro';

export const GET: APIRoute = ({ site }) => {
	const origin = site ?? new URL('https://swift95.dimasike.com');
	const body = `User-agent: *
Allow: /

User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: GPTBot
Allow: /

User-agent: PerplexityBot
Allow: /

Sitemap: ${new URL('/sitemap-index.xml', origin).href}

# Machine-readable documentation: ${new URL('/llms.txt', origin).href}
`;

	return new Response(body, {
		headers: { 'Content-Type': 'text/plain; charset=utf-8' },
	});
};
