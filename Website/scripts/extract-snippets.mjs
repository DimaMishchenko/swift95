import { mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { completeGuidePages } from '../src/data/completeGuides.mjs';

const scriptsDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptsDirectory, '../..');
const documentationDirectory = path.join(
	repositoryRoot,
	'Website/src/content/docs',
);
const packageDirectory = path.join(
	repositoryRoot,
	'.build/documentation-snippets',
);
const sourcesDirectory = path.join(
	packageDirectory,
	'Sources/DocumentationSnippets',
);

async function markdownFiles(directory) {
	const entries = await readdir(directory, { withFileTypes: true });
	const files = [];

	for (const entry of entries) {
		const entryPath = path.join(directory, entry.name);
		if (entry.isDirectory()) {
			files.push(...(await markdownFiles(entryPath)));
		} else if (entry.name.endsWith('.md') || entry.name.endsWith('.mdx')) {
			files.push(entryPath);
		}
	}

	return files.sort();
}

function swiftCompileSnippets(source) {
	const snippets = [];
	const fencePattern = /```swift compile\s*\n([\s\S]*?)\n```/g;
	let match;

	while ((match = fencePattern.exec(source)) !== null) {
		snippets.push(match[1]);
	}

	return snippets;
}

function swiftString(value) {
	return JSON.stringify(value);
}

const files = await markdownFiles(documentationDirectory);
const extracted = [];

for (const file of files) {
	const source = await readFile(file, 'utf8');
	const snippets = swiftCompileSnippets(source);
	const relativePath = path.relative(documentationDirectory, file);

	for (const [index, snippet] of snippets.entries()) {
		extracted.push({ index, relativePath, snippet });
	}
}

for (const page of completeGuidePages) {
	extracted.push({
		index: 0,
		relativePath: `generated/${page.slug}.mdx`,
		snippet: page.code,
	});
}

if (extracted.length === 0) {
	throw new Error(
		'No `swift compile` code fences were found in the documentation.',
	);
}

await rm(packageDirectory, { force: true, recursive: true });
await mkdir(sourcesDirectory, { recursive: true });

const manifest = `// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "DocumentationSnippets",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(path: ${swiftString(repositoryRoot)})
  ],
  targets: [
    .target(
      name: "DocumentationSnippets",
      dependencies: [
        .product(name: "Swift95", package: "swift95"),
        .product(name: "Swift95Icons", package: "swift95")
      ]
    )
  ]
)
`;

await writeFile(path.join(packageDirectory, 'Package.swift'), manifest);

for (const [outputIndex, item] of extracted.entries()) {
	const safeName = item.relativePath.replace(/[^a-zA-Z0-9]+/g, '_');
	const outputName = `${String(outputIndex + 1).padStart(3, '0')}_${safeName}_${item.index + 1}.swift`;
	await writeFile(path.join(sourcesDirectory, outputName), `${item.snippet}\n`);
}

console.log(
	`Extracted ${extracted.length} compilable Swift snippets from ${files.length} documentation files.`,
);
