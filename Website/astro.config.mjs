// @ts-check
import { readFile, stat } from 'node:fs/promises';
import { extname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import starlight from '@astrojs/starlight';

const site = process.env.SITE_URL ?? 'https://swift95.dimasike.com';

const doccRoot = resolve(fileURLToPath(new URL('../.build/docc-site/api/', import.meta.url)));
/** @type {Record<string, string>} */
const contentTypes = {
	'.css': 'text/css; charset=utf-8',
	'.html': 'text/html; charset=utf-8',
	'.ico': 'image/x-icon',
	'.jpg': 'image/jpeg',
	'.js': 'text/javascript; charset=utf-8',
	'.json': 'application/json; charset=utf-8',
	'.png': 'image/png',
	'.svg': 'image/svg+xml',
	'.woff': 'font/woff',
	'.woff2': 'font/woff2',
};

/** @type {import('vite').Plugin} */
const doccDevelopmentMount = {
	name: 'swift95-docc-development-mount',
	apply: 'serve',
	configureServer(server) {
		server.middlewares.use('/api', async (request, response, next) => {
			try {
				const pathname = decodeURIComponent((request.url ?? '/').split('?')[0]);
				const relativePath = pathname.replace(/^\/+/, '');
				let filePath = resolve(doccRoot, relativePath || 'index.html');

				if (filePath !== doccRoot && !filePath.startsWith(`${doccRoot}${sep}`)) {
					next();
					return;
				}

				if ((await stat(filePath)).isDirectory()) {
					filePath = resolve(filePath, 'index.html');
				}

				const body = await readFile(filePath);
				const contentType = contentTypes[extname(filePath)];
				if (contentType) response.setHeader('Content-Type', contentType);
				response.end(body);
			} catch {
				next();
			}
		});
	},
};

// https://astro.build/config
export default defineConfig({
	site,
	integrations: [
		react(),
		starlight({
			title: 'Swift95',
			description: 'A Windows 95-inspired SwiftUI component kit for Apple platforms.',
			favicon: '/favicon.png',
			customCss: ['./src/styles/swift95.css'],
			social: [
				{
					icon: 'github',
					label: 'Swift95 on GitHub',
					href: 'https://github.com/dimamishchenko/swift95',
				},
			],
			sidebar: [
				{
					label: 'Start here',
					items: [
						{ label: 'Welcome to Swift95', slug: '' },
						{ label: 'Get started', slug: 'start' },
					],
				},
				{
					label: 'Components',
					items: [
						{ label: 'All components', slug: 'components' },
						{ label: 'Button95', slug: 'components/button' },
					],
				},
			],
			components: {
				Head: './src/components/SeoHead.astro',
				PageTitle: './src/components/EmptyPageTitle.astro',
			},
		}),
	],
	vite: {
		plugins: [doccDevelopmentMount],
		build: {
			cssMinify: 'esbuild',
		},
		resolve: {
			noExternal: ['@react95/core'],
		},
	},
});
