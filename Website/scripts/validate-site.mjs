import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { select, selectAll } from 'hast-util-select';
import rehypeParse from 'rehype-parse';
import sharp from 'sharp';
import { unified } from 'unified';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(scriptDirectory, '..');
const outputRoot = path.join(websiteRoot, 'dist');
const site = new URL(process.env.SITE_URL ?? 'https://swift95.dimasike.com');
const requireApi = process.argv.includes('--require-api');
const htmlParser = unified().use(rehypeParse);

async function filesBelow(directory) {
	const entries = await readdir(directory, { withFileTypes: true });
	const nested = await Promise.all(
		entries.map((entry) => {
			const entryPath = path.join(directory, entry.name);
			return entry.isDirectory() ? filesBelow(entryPath) : [entryPath];
		}),
	);
	return nested.flat();
}

function textFrom(node) {
	if (!node) return '';
	if (node.type === 'text') return node.value;
	return (node.children ?? []).map(textFrom).join('');
}

function property(node, name) {
	const value = node?.properties?.[name];
	return typeof value === 'string' ? value : '';
}

async function pathExists(filePath) {
	try {
		return (await stat(filePath)).isFile();
	} catch {
		return false;
	}
}

const allFiles = await filesBelow(outputRoot);
const humanHtml = allFiles.filter((file) => {
	const relative = path.relative(outputRoot, file).split(path.sep).join('/');
	return file.endsWith('.html') && relative !== '404.html' && !relative.startsWith('api/');
});
if (humanHtml.length < 49) throw new Error(`Expected at least 49 human pages, found ${humanHtml.length}.`);

const titles = new Set();
const descriptions = new Set();
const canonicals = [];
const internalLinks = [];
for (const file of humanHtml) {
	const relative = path.relative(outputRoot, file).split(path.sep).join('/');
	const html = await readFile(file, 'utf8');
	if (/https?:\/\/(?:localhost|127\.0\.0\.1)/.test(html)) {
		throw new Error(`${relative} contains a local-only URL.`);
	}
	const tree = htmlParser.parse(html);
	const titleNodes = selectAll('title', tree);
	const descriptionNodes = selectAll('meta[name="description"]', tree);
	const canonicalNodes = selectAll('link[rel="canonical"]', tree);
	const headings = selectAll('h1', tree);
	const jsonLd = selectAll('script[type="application/ld+json"]', tree);
	if (titleNodes.length !== 1) throw new Error(`${relative} must have exactly one title.`);
	if (descriptionNodes.length !== 1) throw new Error(`${relative} must have exactly one description.`);
	if (canonicalNodes.length !== 1) throw new Error(`${relative} must have exactly one canonical URL.`);
	if (headings.length !== 1) throw new Error(`${relative} must have exactly one h1.`);
	if (jsonLd.length !== 1) throw new Error(`${relative} must have exactly one JSON-LD block.`);
	const title = textFrom(titleNodes[0]).trim();
	const description = property(descriptionNodes[0], 'content').trim();
	const canonical = property(canonicalNodes[0], 'href');
	if (!title || titles.has(title)) throw new Error(`${relative} has a missing or duplicate title: ${title}`);
	if (!description || descriptions.has(description)) {
		throw new Error(`${relative} has a missing or duplicate description: ${description}`);
	}
	if (!canonical.startsWith(site.href)) throw new Error(`${relative} has an invalid canonical: ${canonical}`);
	titles.add(title);
	descriptions.add(description);
	canonicals.push(canonical);
	for (const selector of [
		'meta[property="og:title"]',
		'meta[property="og:description"]',
		'meta[property="og:url"]',
		'meta[property="og:image"]',
		'meta[name="twitter:card"]',
		'meta[name="twitter:image"]',
		'meta[name="robots"]',
		'link[rel="alternate"][type="text/plain"]',
		'link[rel="alternate"][type="text/markdown"]',
	]) {
		if (!select(selector, tree)) throw new Error(`${relative} is missing ${selector}.`);
	}
	for (const image of selectAll('img', tree)) {
		if (!property(image, 'alt')) throw new Error(`${relative} contains an image without alt text.`);
		if (!image.properties?.width || !image.properties?.height) {
			throw new Error(`${relative} contains an image without intrinsic dimensions.`);
		}
	}
	for (const link of selectAll('a[href]', tree)) {
		const href = property(link, 'href');
		if (href.startsWith('/') && !href.startsWith('//')) {
			internalLinks.push({ href, source: relative });
		}
	}
	JSON.parse(textFrom(jsonLd[0]));
}

for (const { href, source } of internalLinks) {
	const url = new URL(href, site);
	if (!requireApi && url.pathname.startsWith('/api/')) continue;
	const relative = decodeURIComponent(url.pathname).replace(/^\/+/, '');
	const candidates = relative.endsWith('/')
		? [path.join(outputRoot, relative, 'index.html')]
		: [
				path.join(outputRoot, relative),
				path.join(outputRoot, `${relative}.html`),
				path.join(outputRoot, relative, 'index.html'),
			];
	let targetExists = false;
	for (const candidate of candidates) {
		if (await pathExists(candidate)) {
			targetExists = true;
			break;
		}
	}
	if (!targetExists) {
		throw new Error(`${source} links to missing internal page ${href}.`);
	}
}

const sitemapIndex = await readFile(path.join(outputRoot, 'sitemap-index.xml'), 'utf8');
if (!sitemapIndex.includes('sitemap-0.xml')) throw new Error('Sitemap index is missing the human sitemap.');
const humanSitemap = await readFile(path.join(outputRoot, 'sitemap-0.xml'), 'utf8');
for (const canonical of canonicals) {
	if (!humanSitemap.includes(canonical)) throw new Error(`Human sitemap is missing ${canonical}.`);
}

const robots = await readFile(path.join(outputRoot, 'robots.txt'), 'utf8');
for (const agent of ['Googlebot', 'Bingbot', 'OAI-SearchBot', 'ChatGPT-User', 'GPTBot', 'PerplexityBot']) {
	if (!robots.includes(`User-agent: ${agent}`)) throw new Error(`robots.txt is missing ${agent}.`);
}
if (!robots.includes(new URL('/sitemap-index.xml', site).href)) {
	throw new Error('robots.txt does not advertise the sitemap index.');
}

for (const file of [
	'llms.txt',
	'llms-small.txt',
	'llms-full.txt',
]) {
	if (!(await pathExists(path.join(outputRoot, file)))) throw new Error(`Missing agent resource: ${file}`);
}

const socialMetadata = await sharp(path.join(outputRoot, 'social/swift95-social.png')).metadata();
if (socialMetadata.width !== 1200 || socialMetadata.height !== 630) {
	throw new Error('Social image must be exactly 1200×630.');
}

if (requireApi) {
	const apiSitemapPath = path.join(outputRoot, 'sitemap-api.xml');
	if (!(await pathExists(apiSitemapPath))) throw new Error('Missing DocC sitemap.');
	const apiSitemap = await readFile(apiSitemapPath, 'utf8');
	const apiUrls = [...apiSitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((match) => match[1]);
	if (apiUrls.length < 1000) throw new Error(`Expected at least 1000 first-party DocC URLs, found ${apiUrls.length}.`);
	for (const relative of [
		'api/documentation/swift95/button95/index.html',
		'api/documentation/swift95icons/icon95/name-swift.enum/access110/index.html',
	]) {
		const html = await readFile(path.join(outputRoot, relative), 'utf8');
		if (
			!html.includes('swift95-docc-seo') ||
			!html.includes('data-swift95-seo-keeper') ||
			!html.includes('index,follow')
		) {
			throw new Error(`${relative} is missing indexable DocC metadata.`);
		}
	}
	const inherited = await readFile(
		path.join(outputRoot, 'api/documentation/swift95icons/icon95/kerning(_:)/index.html'),
		'utf8',
	);
	if (!inherited.includes('noindex,follow')) throw new Error('Inherited DocC APIs must be noindex.');
}

console.log(
	`Validated SEO and ${internalLinks.length} internal page links for ${humanHtml.length} human pages${requireApi ? ' and the first-party DocC index' : ''}.`,
);
