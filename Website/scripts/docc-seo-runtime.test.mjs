import assert from 'node:assert/strict';
import test from 'node:test';
import { installDocCSEO } from './docc-seo-runtime.mjs';

const page = (name, inherited = false) => ({
	pathname: `/api/documentation/swift95/${name.toLowerCase()}`,
	title: `${name} | Swift95 API`,
	tags: [
		['meta[name="description"]', `<meta name="description" content="${name} reference">`],
		['link[rel="canonical"]', `<link rel="canonical" href="https://swift95.dimasike.com/api/documentation/swift95/${name.toLowerCase()}/">`],
		['meta[name="robots"]', `<meta name="robots" content="${inherited ? 'noindex,follow' : 'index,follow'}">`],
		['script[data-swift95-seo-schema]', `<script data-swift95-seo-schema="" type="application/ld+json">${JSON.stringify({ headline: name })}</script>`],
	],
});
const button = page('Button95');
const text = page('Text95');
const inherited = page('kerning', true);

function harness(fetchPage = async (pathname) => [button, text, inherited].find((item) => `${item.pathname}/` === pathname)) {
	const elements = new Map();
	const listeners = new Map();
	let observer;
	const browser = {
		document: {
			title: button.title,
			head: {
				querySelector: (selector) => elements.get(selector),
				insertAdjacentHTML(_position, html) {
					const selector = [button, text, inherited].flatMap((item) => item.tags).find(([, tag]) => tag === html)?.[0];
					assert.ok(selector, `Unexpected managed HTML: ${html}`);
					elements.set(selector, { outerHTML: html, remove: () => elements.delete(selector) });
				},
			},
		},
		location: { pathname: button.pathname },
		history: Object.fromEntries(['pushState', 'replaceState'].map((method) => [method, function (_state, _unused, pathname) {
			browser.location.pathname = pathname;
		}])),
		MutationObserver: class {
			constructor(callback) { observer = callback; }
			observe() {}
			disconnect() {}
		},
		DOMParser: class {
			parseFromString(payload) {
				return { querySelector: () => payload ? { textContent: payload } : null };
			}
		},
		fetch: async (pathname) => ({ ok: true, text: async () => JSON.stringify(await fetchPage(pathname)) }),
		addEventListener: (name, callback) => listeners.set(name, callback),
	};
	installDocCSEO(button, browser);
	return { browser, elements, mutate: () => observer(), back: async (pathname) => {
		browser.location.pathname = pathname;
		await listeners.get('popstate')();
	} };
}

const flush = () => new Promise((resolve) => setImmediate(resolve));

function assertPage(state, expected) {
	assert.equal(state.browser.document.title, expected.title);
	for (const [selector, html] of expected.tags) assert.equal(state.elements.get(selector)?.outerHTML, html);
}

test('SPA navigation updates title, canonical, description, robots and schema', async () => {
	const state = harness();
	assertPage(state, button);
	state.browser.history.pushState(null, '', `${text.pathname}/`);
	assert.equal(state.elements.has('link[rel="canonical"]'), false);
	state.browser.document.title = 'Text95 | Documentation';
	state.mutate();
	await flush();
	assertPage(state, text);
	state.browser.document.title = 'Text95 | Documentation';
	state.mutate();
	assertPage(state, text);
	state.browser.history.replaceState(null, '', inherited.pathname);
	await flush();
	assertPage(state, inherited);
	await state.back(button.pathname);
	assertPage(state, button);
});

test('a late destination response cannot restore metadata from an earlier route', async () => {
	let resolveText;
	const state = harness((pathname) => pathname === `${text.pathname}/`
		? new Promise((resolve) => { resolveText = resolve; })
		: inherited);
	state.browser.history.pushState(null, '', text.pathname);
	await flush();
	state.browser.history.pushState(null, '', inherited.pathname);
	await flush();
	assertPage(state, inherited);
	resolveText(text);
	await flush();
	assertPage(state, inherited);
});

test('failed route metadata leaves DocC title ownership and removes stale canonical', async () => {
	const state = harness(async () => { throw new Error('Offline'); });
	state.browser.history.pushState(null, '', text.pathname);
	state.browser.document.title = 'Text95 | Documentation';
	await flush();
	state.mutate();
	assert.equal(state.browser.document.title, 'Text95 | Documentation');
	assert.equal(state.elements.has('link[rel="canonical"]'), false);
	assert.equal(state.elements.has('script[data-swift95-seo-schema]'), false);
});
