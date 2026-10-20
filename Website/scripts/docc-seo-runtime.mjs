export function installDocCSEO(initial, browser = window) {
	const { document, history, location, MutationObserver, DOMParser } = browser;
	const route = () => location.pathname.replace(/\/$/, '').toLowerCase();
	let active = initial;
	let requestedRoute = initial.pathname;
	const observer = new MutationObserver(ensure);

	function ensure() {
		if (!active || active.pathname !== route()) return;
		observer.disconnect();
		if (document.title !== active.title) document.title = active.title;
		for (const [selector, html] of active.tags) {
			const existing = document.head.querySelector(selector);
			if (existing?.outerHTML === html) continue;
			existing?.remove();
			document.head.insertAdjacentHTML('beforeend', html);
		}
		observer.observe(document.head, { childList: true, subtree: true, attributes: true, characterData: true });
	}

	async function navigate() {
		const pathname = route();
		if (pathname === requestedRoute) return;
		requestedRoute = pathname;
		active = null;
		for (const selector of ['link[rel="canonical"]', 'meta[name="robots"]', 'script[data-swift95-seo-schema]']) {
			document.head.querySelector(selector)?.remove();
		}
		try {
			const response = await browser.fetch(`${pathname}/`);
			if (!response.ok) return;
			const html = new DOMParser().parseFromString(await response.text(), 'text/html');
			const payload = html.querySelector('script[data-swift95-seo-page]');
			if (!payload || route() !== pathname) return;
			const next = JSON.parse(payload.textContent);
			if (next.pathname !== pathname) return;
			active = next;
			ensure();
		} catch {}
	}

	for (const method of ['pushState', 'replaceState']) {
		const original = history[method];
		history[method] = function (...args) {
			const result = original.apply(this, args);
			void navigate();
			return result;
		};
	}
	browser.addEventListener('popstate', navigate);
	ensure();
}
