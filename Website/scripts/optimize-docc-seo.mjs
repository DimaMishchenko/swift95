import { readFile, readdir, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { installDocCSEO } from './docc-seo-runtime.mjs';
import { metadataFor } from './docc-seo-metadata.mjs';
import { fileURLToPath } from 'node:url';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(scriptDirectory, '..');
const outputRoot = path.join(websiteRoot, 'dist');
const apiRoot = path.join(outputRoot, 'api');
const dataRoot = path.join(apiRoot, 'data', 'documentation');
const htmlRoot = path.join(apiRoot, 'documentation');
const site = new URL(process.env.SITE_URL ?? 'https://swift95.dimasike.com');
const socialImage = new URL('/social/swift95-social.png', site).href;
const marker = '<!-- swift95-docc-seo -->';

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

function escapeHtml(value) {
	return String(value)
		.replaceAll('&', '&amp;')
		.replaceAll('"', '&quot;')
		.replaceAll('<', '&lt;')
		.replaceAll('>', '&gt;');
}

function xmlEscape(value) {
	return escapeHtml(value).replaceAll("'", '&apos;');
}

function relativeRoute(filePath) {
	return path.relative(dataRoot, filePath).split(path.sep).join('/').replace(/\.json$/, '');
}

function seoHead(metadata) {
	const robots = metadata.indexable
		? 'index,follow,max-image-preview:large,max-snippet:-1'
		: 'noindex,follow';
	const pageTitle = `${metadata.title} | ${metadata.moduleName} API`;
	const schema = {
		'@context': 'https://schema.org',
		'@type': 'TechArticle',
		headline: metadata.title,
		description: metadata.description,
		url: metadata.canonical,
		inLanguage: 'en',
		about: {
			'@type': 'SoftwareSourceCode',
			name: metadata.moduleName,
			programmingLanguage: 'Swift',
			codeRepository: 'https://github.com/dimamishchenko/swift95',
		},
	};
	const managedTags = [
		['link[rel="icon"]', '<link rel="icon" type="image/png" href="/favicon-swift95.png">'],
		['meta[name="description"]', `<meta name="description" content="${escapeHtml(metadata.description)}">`],
		['meta[name="robots"]', `<meta name="robots" content="${robots}">`],
		['link[rel="canonical"]', `<link rel="canonical" href="${metadata.canonical}">`],
		[
			'link[rel="alternate"][type="text/plain"]',
			'<link rel="alternate" type="text/plain" href="/llms.txt" title="Swift95 documentation for language models">',
		],
		['meta[property="og:title"]', `<meta property="og:title" content="${escapeHtml(pageTitle)}">`],
		[
			'meta[property="og:description"]',
			`<meta property="og:description" content="${escapeHtml(metadata.description)}">`,
		],
		['meta[property="og:type"]', '<meta property="og:type" content="article">'],
		['meta[property="og:url"]', `<meta property="og:url" content="${metadata.canonical}">`],
		['meta[property="og:site_name"]', '<meta property="og:site_name" content="Swift95">'],
		['meta[property="og:image"]', `<meta property="og:image" content="${socialImage}">`],
		['meta[name="twitter:card"]', '<meta name="twitter:card" content="summary_large_image">'],
		['meta[name="twitter:title"]', `<meta name="twitter:title" content="${escapeHtml(pageTitle)}">`],
		[
			'meta[name="twitter:description"]',
			`<meta name="twitter:description" content="${escapeHtml(metadata.description)}">`,
		],
		['meta[name="twitter:image"]', `<meta name="twitter:image" content="${socialImage}">`],
		[
			'script[data-swift95-seo-schema]',
			`<script data-swift95-seo-schema="" type="application/ld+json">${JSON.stringify(schema).replaceAll('<', '\\u003c')}<\/script>`,
		],
	];
	const page = {
		pathname: new URL(metadata.canonical).pathname.replace(/\/$/, '').toLowerCase(),
		title: pageTitle,
		tags: managedTags,
	};
	const payload = JSON.stringify(page).replaceAll('<', '\\u003c');
	return `${marker}
${managedTags.map(([, html]) => html).join('\n')}
<script data-swift95-seo-page type="application/json">${payload}</script>
<script data-swift95-seo-keeper>(${installDocCSEO.toString()})(${payload});</script>`;
}

function optimizeHtml(html, metadata) {
	if (html.includes(marker)) return html;
	const pageTitle = `${metadata.title} | ${metadata.moduleName} API`;
	let optimized = html.replace('<title>Documentation</title>', `<title>${escapeHtml(pageTitle)}</title>`);
	optimized = optimized.replace(/<link rel="icon"[^>]*>/g, '');
	optimized = optimized.replace('</head>', `${seoHead(metadata)}</head>`);
	if (metadata.indexable) {
		optimized = optimized.replace(
			'<h1 class="noscript-title">This page requires JavaScript.</h1><p>Please turn on JavaScript in your browser and refresh the page to view its content.</p>',
			`<h1 class="noscript-title">${escapeHtml(metadata.title)}</h1><p>${escapeHtml(metadata.description)}</p>`,
		);
	}
	return optimized;
}

async function pathExists(filePath) {
	try {
		return (await stat(filePath)).isFile();
	} catch {
		return false;
	}
}

const dataFiles = [
	path.join(apiRoot, 'data', 'documentation.json'),
	...(await filesBelow(dataRoot)).filter((file) => file.endsWith('.json')),
];
const indexableUrls = [];
let noindexCount = 0;

let nextIndex = 0;
async function optimizeNextDocument() {
	while (nextIndex < dataFiles.length) {
		const dataPath = dataFiles[nextIndex];
		nextIndex += 1;
		const route = dataPath.endsWith('/documentation.json') ? '' : relativeRoute(dataPath);
		const htmlPath = path.join(htmlRoot, route, 'index.html');
		if (!(await pathExists(htmlPath))) {
			throw new Error(`Missing DocC HTML for ${route}.`);
		}
		const document = JSON.parse(await readFile(dataPath, 'utf8'));
		const metadata = metadataFor(document, route, site);
		const html = await readFile(htmlPath, 'utf8');
		await writeFile(htmlPath, optimizeHtml(html, metadata));
		if (metadata.indexable) indexableUrls.push(metadata.canonical);
		else noindexCount += 1;
	}
}

await Promise.all(Array.from({ length: 24 }, optimizeNextDocument));
indexableUrls.sort();

const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${indexableUrls.map((url) => `  <url><loc>${xmlEscape(url)}</loc></url>`).join('\n')}
</urlset>
`;
await writeFile(path.join(outputRoot, 'sitemap-api.xml'), sitemap);

const sitemapIndexPath = path.join(outputRoot, 'sitemap-index.xml');
const sitemapIndex = await readFile(sitemapIndexPath, 'utf8');
const apiSitemapUrl = new URL('/sitemap-api.xml', site).href;
if (!sitemapIndex.includes(apiSitemapUrl)) {
	await writeFile(
		sitemapIndexPath,
		sitemapIndex.replace(
			'</sitemapindex>',
			`<sitemap><loc>${xmlEscape(apiSitemapUrl)}</loc></sitemap></sitemapindex>`,
		),
	);
}

console.log(
	`Optimized ${indexableUrls.length} first-party DocC pages; marked ${noindexCount} inherited or empty collection pages noindex.`,
);
