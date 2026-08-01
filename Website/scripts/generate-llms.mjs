import { readFile, readdir, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { select } from 'hast-util-select';
import rehypeParse from 'rehype-parse';
import rehypeRemark from 'rehype-remark';
import remarkGfm from 'remark-gfm';
import remarkStringify from 'remark-stringify';
import { unified } from 'unified';
import { remove } from 'unist-util-remove';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(scriptDirectory, '..');
const outputRoot = path.join(websiteRoot, 'dist');
const discoveryLink = '<link rel="alternate" type="text/plain" href="/llms.txt" title="Swift95 documentation for language models">';
const generatedMarker = '<!-- swift95-llms-discovery -->';
const excludedTags = new Set(['button', 'canvas', 'footer', 'nav', 'script', 'style', 'svg']);
const excludedClasses = new Set([
  'mobile-preferences',
  'pagination-links',
  'right-sidebar',
  'sidebar-pane',
  'sl-anchor-link',
  'starlight-aside__icon',
  'void-nav95'
]);
const promotedRoutes = [
  '/',
  '/start/',
  '/components/',
  '/components/button/',
  '/components/checkbox/',
  '/components/radio-button/',
  '/components/menu/',
  '/components/text-field/',
  '/components/list/',
  '/components/workspace/',
  '/components/theme/',
  '/components/icon/'
];

const htmlParser = unified().use(rehypeParse);
const markdownCompiler = unified()
  .use(rehypeRemark)
  .use(remarkGfm)
  .use(remarkStringify, {
    bullet: '-',
    fences: true,
    listItemIndent: 'one'
  });

async function filesBelow(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(
    entries.map((entry) => {
      const entryPath = path.join(directory, entry.name);
      return entry.isDirectory() ? filesBelow(entryPath) : [entryPath];
    })
  );
  return nested.flat();
}

function routeForHtml(relativePath) {
  const normalized = relativePath.split(path.sep).join('/');
  if (normalized === 'index.html') return '/';
  if (normalized.endsWith('/index.html')) {
    return `/${normalized.slice(0, -'index.html'.length)}`;
  }
  return `/${normalized.slice(0, -'.html'.length)}`;
}

function markdownPathForRoute(route) {
  return route === '/' ? '/index.md' : `${route.replace(/\/$/, '')}.md`;
}

function hasExcludedClass(node) {
  const classes = node.properties?.className;
  return Array.isArray(classes) && classes.some((name) => excludedClasses.has(String(name)));
}

function textFrom(node) {
  if (!node) return '';
  if (node.type === 'text') return node.value;
  return (node.children ?? []).map(textFrom).join('');
}

function descriptionFrom(tree) {
  const meta = select('meta[name="description"]', tree);
  return typeof meta?.properties?.content === 'string' ? meta.properties.content.trim() : '';
}

async function markdownFromHtml(html) {
  const tree = htmlParser.parse(html);
  const main =
    select('main.void-doc-client95', tree) ??
    select('.void-home95', tree) ??
    select('main', tree);
  if (!main) throw new Error('Rendered page has no <main> element.');
  const contentRoot = { type: 'root', children: [structuredClone(main)] };
  remove(contentRoot, (node) => {
    if (node.type !== 'element') return false;
    if (excludedTags.has(node.tagName) || hasExcludedClass(node)) return true;
    if (
      node.tagName === 'figcaption' &&
      Array.isArray(node.properties?.className) &&
      node.properties.className.includes('header')
    ) return true;
    return node.properties?.ariaHidden === 'true' || node.properties?.hidden === true;
  });
  addCodeLanguages(contentRoot);
	const markdownTree = await Promise.resolve(markdownCompiler.run(contentRoot));
  return markdownCompiler.stringify(markdownTree).trim();
}

function addCodeLanguages(node) {
  if (node.type === 'element' && node.tagName === 'pre') {
    const language = node.properties?.dataLanguage;
    const code = node.children?.find(
      (child) => child.type === 'element' && child.tagName === 'code'
    );
    if (typeof language === 'string' && code) {
      code.properties ??= {};
      code.properties.className = [`language-${language}`];
    }
  }
  for (const child of node.children ?? []) addCodeLanguages(child);
}

async function collectPages() {
  const files = await filesBelow(outputRoot);
  const htmlFiles = files.filter((file) => {
    const relative = path.relative(outputRoot, file).split(path.sep).join('/');
    return file.endsWith('.html') && relative !== '404.html' && !relative.startsWith('api/');
  });
  const pages = [];
  for (const htmlPath of htmlFiles) {
    const relativePath = path.relative(outputRoot, htmlPath);
    const route = routeForHtml(relativePath);
    const markdownPath = markdownPathForRoute(route);
    const html = await readFile(htmlPath, 'utf8');
    const tree = htmlParser.parse(html);
    const content =
      select('main.void-doc-client95', tree) ??
      select('.void-home95', tree) ??
      select('main', tree);
    const title = textFrom(select('h1', content)).trim() || textFrom(select('title', tree)).trim();
    const markdown = await markdownFromHtml(html);
    if (!title || !markdown) throw new Error(`Could not extract agent content from ${route}.`);
    pages.push({
      description: descriptionFrom(tree),
      html,
      htmlPath,
      markdown,
      markdownPath,
      route,
      title
    });
  }
  return pages.sort((left, right) => {
    const leftIndex = promotedRoutes.indexOf(left.route);
    const rightIndex = promotedRoutes.indexOf(right.route);
    if (leftIndex >= 0 || rightIndex >= 0) {
      return (leftIndex < 0 ? promotedRoutes.length : leftIndex) -
        (rightIndex < 0 ? promotedRoutes.length : rightIndex);
    }
    return left.route.localeCompare(right.route);
  });
}

function addDiscoveryLinks(html, markdownPath) {
  const pageLink = `<link rel="alternate" type="text/markdown" href="${markdownPath}" title="Markdown version of this page">`;
  const hints = `${generatedMarker}\n${discoveryLink}\n${pageLink}`;
  if (html.includes(generatedMarker)) {
    return html.replace(
      /<!-- swift95-llms-discovery -->[\s\S]*?<link rel="alternate" type="text\/markdown"[^>]*>/,
      hints
    );
  }
  return html.replace('</head>', `${hints}\n</head>`);
}

function pageSegment(page) {
  return `<!-- Source: ${page.route} -->\n\n${page.markdown}`;
}

function indexDocument(pages) {
  const page = (route) => {
    const match = pages.find((candidate) => candidate.route === route);
    if (!match) throw new Error(`Missing required documentation route: ${route}`);
    return match;
  };
  const link = (route, description) => {
    const item = page(route);
    return `- [${item.title}](${item.markdownPath}): ${description || item.description}`;
  };
  return `# Swift95

> A Windows 95-inspired SwiftUI component kit for iOS, iPadOS, and macOS. Swift95 requires Swift 6, iOS/iPadOS 18 or later, or macOS 15 or later.

Use the Markdown pages below for implementation guidance and the DocC links for exact public API signatures. Code examples in the documentation are compiled during the website build.

## Documentation sets

- [Abridged documentation](/llms-small.txt): essential setup, component, workspace, theme, and icon guidance
- [Complete documentation](/llms-full.txt): every human-facing documentation page in one file

## Start

${link('/start/', 'installation, Package.swift configuration, and the first component')}
${link('/components/', 'component selection and the complete documentation directory')}

## Essential guides

${link('/components/theme/', 'theme tokens and environment configuration')}
${link('/components/workspace/', 'desktop and window composition')}
${link('/components/icon/', 'type-safe bundled icon artwork')}

## API reference

- [Swift95 API](/api/documentation/swift95): generated DocC reference for components, tokens, and workspaces
- [Swift95Icons API](/api/documentation/swift95icons): generated DocC reference for Icon95 and every icon name

## Source

- [Source repository](https://github.com/dimamishchenko/swift95): package source, tests, and release history
`;
}

async function generate() {
  const pages = await collectPages();
  for (const page of pages) {
    const markdownDestination = path.join(outputRoot, page.markdownPath.slice(1));
    await writeFile(markdownDestination, `${page.markdown}\n`);
    await writeFile(page.htmlPath, addDiscoveryLinks(page.html, page.markdownPath));
  }
  const full = pages.map(pageSegment).join('\n\n---\n\n');
  const smallPages = promotedRoutes.map((route) => {
    const page = pages.find((candidate) => candidate.route === route);
    if (!page) throw new Error(`Missing abridged documentation route: ${route}`);
    return page;
  });
  const small = smallPages.map(pageSegment).join('\n\n---\n\n');
  await Promise.all([
    writeFile(path.join(outputRoot, 'llms.txt'), indexDocument(pages)),
    writeFile(path.join(outputRoot, 'llms-full.txt'), `${full}\n`),
    writeFile(path.join(outputRoot, 'llms-small.txt'), `${small}\n`)
  ]);
  console.log(`Generated LLM documentation for ${pages.length} pages.`);
}

function internalLinks(content) {
  return [...content.matchAll(/\]\((\/(?:\\.|[^)\s?#])+)(?:[?#](?:\\.|[^)])*)?\)/g)].map(
    (match) => match[1].replace(/\\(.)/g, '$1')
  );
}

async function pathExists(filePath) {
  try {
    return (await stat(filePath)).isFile();
  } catch {
    return false;
  }
}

function outputPathForUrl(url) {
  const relative = url.replace(/^\//, '');
  if (url.endsWith('/')) return path.join(outputRoot, relative, 'index.html');
  return path.join(outputRoot, relative);
}

async function outputExistsForUrl(url) {
  const directPath = outputPathForUrl(url);
  if (await pathExists(directPath)) return true;
  if (path.extname(url)) return false;
  return pathExists(path.join(outputRoot, url.replace(/^\//, ''), 'index.html'));
}

async function validate({ requireApi = false } = {}) {
  const required = ['llms.txt', 'llms-full.txt', 'llms-small.txt'];
  for (const filename of required) {
    if (!(await pathExists(path.join(outputRoot, filename)))) {
      throw new Error(`Missing generated LLM document: ${filename}`);
    }
  }
  const pages = await collectPages();
  if (pages.length < 49) throw new Error(`Expected at least 49 documentation pages, found ${pages.length}.`);
  const full = await readFile(path.join(outputRoot, 'llms-full.txt'), 'utf8');
  const small = await readFile(path.join(outputRoot, 'llms-small.txt'), 'utf8');
  const index = await readFile(path.join(outputRoot, 'llms.txt'), 'utf8');
  if (small.length >= full.length) throw new Error('llms-small.txt must be smaller than llms-full.txt.');
  if (/https?:\/\/(?:127\.0\.0\.1|localhost)/.test(`${index}\n${full}\n${small}`)) {
    throw new Error('Generated LLM documents contain a local-only URL.');
  }
  const rawDocuments = [];
  for (const page of pages) {
    if (!(await pathExists(outputPathForUrl(page.markdownPath)))) {
      throw new Error(`Missing Markdown twin for ${page.route}: ${page.markdownPath}`);
    }
    rawDocuments.push(await readFile(outputPathForUrl(page.markdownPath), 'utf8'));
    if (!page.html.includes(generatedMarker) || !page.html.includes(page.markdownPath)) {
      throw new Error(`Missing agent discovery links in ${page.route}.`);
    }
    if (!full.includes(`<!-- Source: ${page.route} -->`)) {
      throw new Error(`llms-full.txt does not include ${page.route}.`);
    }
  }
  const linkedDocuments = [
    ...new Set(internalLinks([index, full, small, ...rawDocuments].join('\n')))
  ];
  for (const url of linkedDocuments) {
    if (url.startsWith('/api/') && !requireApi) continue;
    if (!(await outputExistsForUrl(url))) {
      throw new Error(`Machine-readable documentation links to a missing local document: ${url}`);
    }
  }
  console.log(
    `Validated llms.txt, full and abridged sets, ${pages.length} Markdown twins, and ${linkedDocuments.length} internal links.`
  );
}

const command = process.argv[2];
if (command === 'generate') {
  await generate();
} else if (command === 'validate') {
  await validate({ requireApi: process.argv.includes('--require-api') });
} else {
  throw new Error('Usage: generate-llms.mjs <generate|validate> [--require-api]');
}
