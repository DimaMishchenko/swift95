import { copyFile, mkdir, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptDirectory, '../..');
const swift95Generated = path.join(
  repositoryRoot,
  'Sources/Swift95/Swift95.docc/Generated'
);
const iconsCatalogGenerated = path.join(
  repositoryRoot,
  'Sources/Swift95Icons/Swift95Icons.docc/Generated'
);
const iconResources = path.join(repositoryRoot, 'Sources/Swift95Icons/Resources/Icons');
const iconNamesSource = path.join(repositoryRoot, 'Sources/Swift95Icons/Icon95+Names.swift');

async function clean() {
  await Promise.all([
    rm(swift95Generated, { force: true, recursive: true }),
    rm(iconsCatalogGenerated, { force: true, recursive: true })
  ]);
}

function renditionPriority(filename) {
  if (filename.includes('_standard_')) return 0;
  if (filename.includes('_large_')) return 1;
  if (filename.includes('_small_')) return 2;
  return 3;
}

async function copyTopicArtwork() {
  await Promise.all([
    mkdir(swift95Generated, { recursive: true }),
    mkdir(iconsCatalogGenerated, { recursive: true })
  ]);
  const swift95Icon = path.join(iconResources, 'WindowGraph_standard_32x32.png');
  const swift95IconsIcon = path.join(iconResources, 'Computer_standard_32x32.png');
  await Promise.all([
    createHeroIcon(swift95Icon, path.join(swift95Generated, 'Swift95-icon.png')),
    createHeroIcon(
      swift95IconsIcon,
      path.join(iconsCatalogGenerated, 'Swift95Icons-icon.png')
    ),
    createTopicCard(swift95Icon, path.join(swift95Generated, 'Swift95-card.png')),
    createTopicCard(
      swift95IconsIcon,
      path.join(iconsCatalogGenerated, 'Swift95Icons-card.png')
    )
  ]);
}

async function createHeroIcon(source, destination) {
  await sharp(source)
    .resize(256, 256, { fit: 'contain', kernel: 'nearest' })
    .png()
    .toFile(destination);
}

async function createTopicCard(source, destination) {
  const artwork = await sharp(source)
    .resize(128, 128, { fit: 'contain', kernel: 'nearest' })
    .png()
    .toBuffer();
  await sharp({
    create: {
      width: 600,
      height: 338,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 }
    }
  })
    .composite([{ input: artwork, gravity: 'center' }])
    .png()
    .toFile(destination);
}

async function generateIconCaseDocumentation() {
  const source = await readFile(iconNamesSource, 'utf8');
  const resources = await readdir(iconResources);
  const casePattern = /^    case (\w+) = "([^"]+)"/gm;
  const cases = [...source.matchAll(casePattern)].map((match) => ({
    identifier: match[1],
    resourceBaseName: match[2]
  }));
  const casesDirectory = path.join(iconsCatalogGenerated, 'Cases');
  const artworkDirectory = path.join(iconsCatalogGenerated, 'Icons');
  await Promise.all([
    mkdir(casesDirectory, { recursive: true }),
    mkdir(artworkDirectory, { recursive: true })
  ]);

  let documentedCount = 0;
  for (const iconCase of cases) {
    const prefix = `${iconCase.resourceBaseName}_`;
    const rendition = resources
      .filter((filename) => filename.startsWith(prefix) && filename.endsWith('.png'))
      .sort((left, right) => {
        const priority = renditionPriority(left) - renditionPriority(right);
        return priority === 0 ? left.localeCompare(right) : priority;
      })[0];
    if (!rendition) continue;

    await copyFile(
      path.join(iconResources, rendition),
      path.join(artworkDirectory, rendition)
    );
    const alt = `The ${iconCase.resourceBaseName} Windows 95 icon.`;
    const documentation = `# \`\`Swift95Icons/Icon95/Name-swift.enum/${iconCase.identifier}\`\`

The type-safe name for the bundled \`${iconCase.resourceBaseName}\` artwork.

@Metadata {
  @PageImage(purpose: icon, source: "${rendition}", alt: "${alt}")
}

## Overview

@Image(source: "${rendition}", alt: "${alt}")
`;
    await writeFile(
      path.join(casesDirectory, `${iconCase.identifier}.md`),
      documentation
    );
    documentedCount += 1;
  }

  console.log(`Prepared DocC artwork for ${documentedCount} icon cases.`);
}

async function prepare() {
  await clean();
  await copyTopicArtwork();
  await generateIconCaseDocumentation();
}

async function customizeMergedArchive(archivePath) {
  if (!archivePath) {
    throw new Error('The customize command requires a DocC archive path.');
  }
  const landingPagePath = path.join(archivePath, 'data/documentation.json');
  const landingPage = JSON.parse(await readFile(landingPagePath, 'utf8'));
  landingPage.abstract = [
    {
      type: 'text',
      text: 'Windows 95 components and pixel-art icons for SwiftUI.'
    }
  ];
  landingPage.primaryContentSections = [
    {
      kind: 'content',
      content: [
        {
          type: 'heading',
          level: 2,
          text: 'Overview',
          anchor: 'Overview'
        },
        {
          type: 'paragraph',
          inlineContent: [
            {
              type: 'text',
              text: 'Use Swift95 for native controls and complete workspaces, and Swift95Icons for bundled type-safe artwork.'
            }
          ]
        }
      ]
    }
  ];
  await writeFile(landingPagePath, `${JSON.stringify(landingPage)}\n`);
}

const command = process.argv[2];
if (command === 'prepare') {
  await prepare();
} else if (command === 'clean') {
  await clean();
} else if (command === 'customize') {
  await customizeMergedArchive(path.resolve(process.argv[3]));
} else {
  throw new Error('Usage: prepare-docc-content.mjs <prepare|clean|customize> [archive]');
}
