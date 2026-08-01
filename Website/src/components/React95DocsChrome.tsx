import { Button } from '@react95/core/Button';
import { Frame } from '@react95/core/Frame';
import { Input } from '@react95/core/Input';
import { List } from '@react95/core/List';
import { useEffect, useMemo, useRef, useState } from 'react';
import '@react95/core/themes/win95.css';
import buttonContent from '../content/docs/components/button.mdx?raw';
import checkboxContent from '../content/docs/components/checkbox.mdx?raw';
import menuContent from '../content/docs/components/menu.mdx?raw';
import radioButtonContent from '../content/docs/components/radio-button.mdx?raw';
import startContent from '../content/docs/start.mdx?raw';
import { completeGuides } from '../data/completeGuides.mjs';
import { apiDocumentationSections } from '../data/docsNavigation';

type ActivePage = string;

const authoredPageContent: Record<string, string> = {
	start: startContent,
	button: buttonContent,
	checkbox: checkboxContent,
	'radio-button': radioButtonContent,
	menu: menuContent,
};

const guideContent = Object.fromEntries(
	Object.entries(completeGuides).map(([slug, guide]) => [
		slug,
		JSON.stringify(guide),
	]),
) as Record<string, string>;

const sections = [
	{
		label: 'Documentation',
		items: [
			{
				label: 'Get started',
				href: '/start/',
				key: 'start',
				searchText: authoredPageContent.start,
			},
		],
	},
	...apiDocumentationSections.map((section) => ({
		label: section.label,
		items: section.items.map((item) => ({
			href: `/components/${item.slug}/`,
			key: item.slug,
			label: item.label,
			searchText:
				guideContent[item.slug] ?? authoredPageContent[item.slug] ?? '',
		})),
	})),
];

export function DocsSidebar({ active }: { active: ActivePage }) {
	const [query, setQuery] = useState('');
	const [navigationOpen, setNavigationOpen] = useState(false);
	const searchInput = useRef<HTMLInputElement>(null);
	const queryTokens = tokenizeSearchText(query);
	const isSearching = queryTokens.length > 0;
	const activeLabel =
		sections
			.flatMap((section) => section.items)
			.find((item) => item.key === active)?.label ?? 'Documentation';
	const filteredSections = useMemo(
		() =>
			sections
				.map((section) => {
					const items = section.items
						.map((item) => ({
							...item,
							searchRank: rankSearchResult(
								queryTokens,
								`${item.label} ${section.label}`,
								item.searchText,
							),
						}))
						.filter((item) => item.searchRank !== null)
						.sort(
							(left, right) =>
								(left.searchRank ?? 0) - (right.searchRank ?? 0),
						);

					return { ...section, items };
				})
				.filter((section) => section.items.length > 0),
		[queryTokens.join('\u0000')],
	);
	const resultCount = filteredSections.reduce(
		(total, section) => total + section.items.length,
		0,
	);
	const firstResult = filteredSections[0]?.items[0];

	useEffect(() => {
		const focusSearch = (event: KeyboardEvent) => {
			const target = event.target as HTMLElement | null;
			const isTyping =
				target?.isContentEditable ||
				target?.tagName === 'INPUT' ||
				target?.tagName === 'TEXTAREA' ||
				target?.tagName === 'SELECT';

			if (event.key === '/' && !isTyping) {
				event.preventDefault();
				searchInput.current?.focus();
			}
		};

		window.addEventListener('keydown', focusSearch);
		return () => window.removeEventListener('keydown', focusSearch);
	}, []);

	const openFirstResult = (event: React.KeyboardEvent<HTMLInputElement>) => {
		if (event.key === 'Escape' && query) {
			event.preventDefault();
			setQuery('');
		}

		if (event.key === 'Enter' && firstResult) {
			event.preventDefault();
			window.location.assign(firstResult.href);
		}
	};

	return (
		<Frame
			className="r95-doc-sidebar"
			data-nav-open={navigationOpen ? 'true' : undefined}
			data-searching={isSearching ? 'true' : undefined}
		>
			<div className="r95-doc-search">
				<label className="visually-hidden95" htmlFor="docs-search95">
					Search documentation
				</label>
				<div className="r95-doc-search-field">
					<Input
						aria-controls="docs-navigation-results95"
						aria-describedby="docs-search-status95"
						autoComplete="off"
						id="docs-search95"
						onChange={(event) => setQuery(event.currentTarget.value)}
						onKeyDown={openFirstResult}
						placeholder="Search all docs..."
						ref={searchInput}
						spellCheck={false}
						type="search"
						value={query}
					/>
					{query && (
						<Button
							aria-label="Clear search"
							className="r95-doc-search-clear"
							onClick={() => {
								setQuery('');
								searchInput.current?.focus();
							}}
							type="button"
						>
							×
						</Button>
					)}
				</div>
				<span
					aria-live="polite"
					className="r95-doc-search-status"
					id="docs-search-status95"
				>
					{query
						? `${resultCount} ${resultCount === 1 ? 'page' : 'pages'}`
						: 'Searches page content · press /'}
				</span>
			</div>
			<Button
				aria-controls="docs-navigation-panel95"
				aria-expanded={navigationOpen || isSearching}
				className="r95-doc-sidebar-toggle"
				onClick={() => setNavigationOpen((open) => !open)}
				type="button"
			>
				<span className="r95-doc-sidebar-toggle-label">
					Browse: {activeLabel}
				</span>
				<span aria-hidden="true">{navigationOpen ? '▴' : '▾'}</span>
			</Button>
			<nav
				aria-label="Documentation navigation"
				id="docs-navigation-panel95"
			>
				<List className="r95-doc-nav-list" id="docs-navigation-results95">
					{filteredSections.flatMap((section, sectionIndex) => [
						...(sectionIndex > 0
							? [<List.Divider key={`${section.label}-divider`} />]
							: []),
						<List.Item className="r95-doc-group" key={`${section.label}-label`}>
							{section.label}
						</List.Item>,
						...section.items.map((item) => (
							<List.Item
								className="r95-doc-nav-item"
								key={item.label}
								data-current={item.key === active ? 'true' : undefined}
							>
								<a
									href={item.href}
									aria-current={item.key === active ? 'page' : undefined}
								>
									{item.label}
								</a>
							</List.Item>
						)),
					])}
					{resultCount === 0 && (
						<List.Item className="r95-doc-search-empty">
							No matching pages
						</List.Item>
					)}
				</List>
			</nav>
		</Frame>
	);
}

function tokenizeSearchText(value: string) {
	return value
		.toLocaleLowerCase()
		.split(/[^a-z0-9]+/)
		.filter(Boolean);
}

function rankSearchResult(
	queryTokens: string[],
	title: string,
	content: string,
) {
	if (queryTokens.length === 0) return 0;

	const titleTokens = tokenizeSearchText(title).join(' ');
	const searchableContent = tokenizeSearchText(`${title} ${content}`).join(' ');
	if (!queryTokens.every((token) => searchableContent.includes(token))) {
		return null;
	}

	return queryTokens.every((token) => titleTokens.includes(token)) ? 0 : 1;
}

export function DocsActions() {
	return (
		<div className="r95-doc-actions">
			<Button as="a" href="/start/">
				Installation guide
			</Button>
			<Button as="a" href="/components/button/">
				Open Button95
			</Button>
		</div>
	);
}
