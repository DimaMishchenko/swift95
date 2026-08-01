import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import sharp from 'sharp';

const scriptsDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptsDirectory, '../..');
const outputDirectory = path.join(repositoryRoot, 'Website/public/images');

const crops = [
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/MacOSIntegrationSnapshotTests/controls.1.png',
		output: 'button95-overview-macos.png',
		region: { left: 34, top: 88, width: 360, height: 90 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/Menu95SnapshotTests/openMenuWithHighlightedAndDisabledItems.1.png',
		output: 'menu95-open-macos.png',
		region: { left: 16, top: 16, width: 190, height: 220 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/TextEditor95SnapshotTests/textEditorContentFitAndOverflow.1.png',
		output: 'texteditor95-macos.png',
		region: { left: 0, top: 0, width: 390, height: 290 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/Slider95SnapshotTests/sliderBoundaryStates.1.png',
		output: 'slider95-macos.png',
		region: { left: 0, top: 0, width: 390, height: 230 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/ScrollView95SnapshotTests/scrollView95.1.png',
		output: 'scrollview95-macos.png',
		region: { left: 0, top: 0, width: 390, height: 210 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/ScrollView95SnapshotTests/scrollIndicator95.1.png',
		output: 'scrollindicator95-macos.png',
		region: { left: 0, top: 0, width: 390, height: 230 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/Alert95SnapshotTests/alertWithIconAndMultipleActions.1.png',
		output: 'alert95-macos.png',
		region: { left: 0, top: 0, width: 390, height: 350 },
	},
	{
		source:
			'Tests/Swift95Tests/__Snapshots__/Workspace95SnapshotTests/workspaceWindowedRegularWidth.1.png',
		output: 'workspace95-windowed-macos.png',
		region: { left: 0, top: 0, width: 820, height: 650 },
	},
	{
		source: 'Sources/Swift95Icons/Resources/Icons/Computer_standard_32x32.png',
		output: 'icon95-computer.png',
		region: { left: 0, top: 0, width: 32, height: 32 },
	},
];

await mkdir(outputDirectory, { recursive: true });

for (const crop of crops) {
	const sourcePath = path.join(repositoryRoot, crop.source);
	const outputPath = path.join(outputDirectory, crop.output);

	await sharp(sourcePath).extract(crop.region).png().toFile(outputPath);

	const metadata = await sharp(outputPath).metadata();
	if (
		metadata.width !== crop.region.width ||
		metadata.height !== crop.region.height
	) {
		throw new Error(
			`${crop.output} has unexpected dimensions: ${metadata.width}×${metadata.height}`,
		);
	}

	console.log(
		`${crop.output}: ${crop.region.width}×${crop.region.height} from ${crop.source}`,
	);
}
