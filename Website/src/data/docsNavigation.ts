export type DocsNavigationItem = {
	apiPath?: string;
	label: string;
	slug: string;
};

export type DocsNavigationSection = {
	items: DocsNavigationItem[];
	label: string;
};

export const apiDocumentationSections: DocsNavigationSection[] = [
	{
		label: 'Controls',
		items: [
			{ label: 'Button95', slug: 'button' },
			{ label: 'Checkbox95', slug: 'checkbox' },
			{ label: 'RadioButton95', slug: 'radio-button' },
		],
	},
	{
		label: 'Inputs',
		items: [
			{ label: 'TextField95', slug: 'text-field' },
			{ label: 'SecureField95', slug: 'secure-field' },
			{ label: 'TextEditor95', slug: 'text-editor' },
			{ label: 'Picker95', slug: 'picker' },
			{ label: 'Slider95', slug: 'slider' },
		],
	},
	{
		label: 'Content',
		items: [
			{ label: 'Text95', slug: 'text' },
			{ label: 'Image95', slug: 'image' },
			{ label: 'AsyncImage95', slug: 'async-image' },
			{ label: 'List95', slug: 'list' },
			{ label: 'Tabs95', slug: 'tabs' },
			{ label: 'ProgressView95', slug: 'progress-view' },
			{ label: 'ScrollView95', slug: 'scroll-view' },
			{ label: 'ScrollIndicator95', slug: 'scroll-indicator' },
			{ label: 'Divider95', slug: 'divider' },
			{
				apiPath:
					'/api/documentation/swift95/button95/alert95(_:ispresented:isclosebuttonenabled:actions:message:)-5m4dn',
				label: 'Alert95',
				slug: 'alert',
			},
		],
	},
	{
		label: 'Workspace',
		items: [
			{ label: 'Workspace95', slug: 'workspace' },
			{ label: 'WorkspaceWindow95', slug: 'workspace-window' },
			{ label: 'Menu95', slug: 'menu' },
			{ label: 'Desktop95', slug: 'desktop' },
			{ label: 'DesktopShortcut95', slug: 'desktop-shortcut' },
			{ label: 'WorkspaceLink95', slug: 'workspace-link' },
			{ label: 'TaskBar95', slug: 'task-bar' },
			{ label: 'StartMenu95', slug: 'start-menu' },
			{
				label: 'ClassicWorkspaceBackground95',
				slug: 'classic-workspace-background',
			},
		],
	},
	{
		label: 'Workspace APIs',
		items: [
			{ label: 'WorkspaceConfiguration95', slug: 'workspace-configuration' },
			{ label: 'WorkspaceState95', slug: 'workspace-state' },
			{
				label: 'WorkspaceWindowConfiguration95',
				slug: 'workspace-window-configuration',
			},
			{ label: 'WorkspaceWindowActions95', slug: 'workspace-window-actions' },
			{ label: 'WorkspacePresentation95', slug: 'workspace-presentation' },
			{
				label: 'WorkspaceWindowResizeControl95',
				slug: 'workspace-window-resize-control',
			},
			{ label: 'DesktopState95', slug: 'desktop-state' },
			{
				label: 'DesktopShortcutActivation95',
				slug: 'desktop-shortcut-activation',
			},
			{
				label: 'OpenWorkspaceWindow95Action',
				slug: 'open-workspace-window-action',
			},
		],
	},
	{
		label: 'Theming',
		items: [
			{ label: 'Theme95', slug: 'theme' },
			{ label: 'Colors95', slug: 'colors' },
			{ label: 'Fonts95', slug: 'fonts' },
			{ label: 'Spacing95', slug: 'spacing' },
			{ label: 'Metrics95', slug: 'metrics' },
			{ label: 'Motion95', slug: 'motion' },
			{
				apiPath: '/api/documentation/swift95/bevel95style',
				label: 'Bevel95',
				slug: 'bevel',
			},
		],
	},
	{
		label: 'Configuration',
		items: [
			{ label: 'Strings95', slug: 'strings' },
			{ label: 'ValueFormatters95', slug: 'value-formatters' },
		],
	},
	{
		label: 'Icons',
		items: [
			{
				apiPath: '/api/documentation/swift95icons/icon95',
				label: 'Icon95',
				slug: 'icon',
			},
		],
	},
];

export const authoredDocumentationPages = new Set([
	'button',
	'checkbox',
	'menu',
	'radio-button',
	...apiDocumentationSections
		.flatMap((section) => section.items)
		.map((item) => item.slug),
]);

export const generatedDocumentationPages = apiDocumentationSections
	.flatMap((section) => section.items)
	.filter(
		(item) =>
			!new Set(['button', 'checkbox', 'menu', 'radio-button']).has(item.slug),
	);
