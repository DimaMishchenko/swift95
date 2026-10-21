import assert from 'node:assert/strict';
import test from 'node:test';
import { metadataFor } from './docc-seo-metadata.mjs';

const site = new URL('https://swift95.dimasike.com');
const collection = {
	metadata: { title: 'View Implementations', role: 'collectionGroup' },
	topicSections: [{ generated: true, identifiers: ['doc://Swift95/member'] }],
};

test('generated link-only collections are excluded while their URLs stay canonical', () => {
	const metadata = metadataFor(collection, 'swift95/scrollview95/view-implementations', site);
	assert.equal(metadata.indexable, false);
	assert.equal(metadata.canonical, 'https://swift95.dimasike.com/api/documentation/swift95/scrollview95/view-implementations/');
});

test('collections with descriptions or authored content remain indexable', () => {
	for (const content of [
		{ abstract: [{ type: 'text', text: 'Workspace configuration APIs.' }] },
		{ primaryContentSections: [{ kind: 'content', content: [{ type: 'paragraph', inlineContent: [{ type: 'text', text: 'Configure your workspace.' }] }] }] },
	]) {
		assert.equal(metadataFor({ ...collection, ...content }, 'swift95/workspace', site).indexable, true);
	}
});

test('public symbols and icon references remain indexable without an abstract', () => {
	for (const role of ['symbol', 'symbolCollection']) {
		assert.equal(metadataFor({ metadata: { title: 'Button95', role } }, 'swift95/button95', site).indexable, true);
	}
});

test('inherited APIs stay excluded even when documented', () => {
	assert.equal(metadataFor({
		metadata: { title: 'kerning(_:)', extendedModule: 'SwiftUI' },
		abstract: [{ type: 'text', text: 'Sets the spacing between characters.' }],
	}, 'swift95icons/icon95/kerning(_:)', site).indexable, false);
});
