function textFromInline(items) {
	return (items ?? [])
		.map((item) => item.text ?? item.code ?? textFromInline(item.inlineContent ?? item.children))
		.join('')
		.replace(/\s+/g, ' ')
		.trim();
}

export function metadataFor(document, route, site) {
	const title = document.metadata?.title ?? document.metadata?.navigatorTitle?.[0]?.text ?? 'Swift95 API';
	const moduleName = document.metadata?.modules?.[0]?.name ?? 'Swift95';
	const role = document.metadata?.roleHeading ?? 'API Reference';
	const abstract = textFromInline(document.abstract);
	const description = abstract || `${title} ${role.toLowerCase()} reference for ${moduleName}.`;
	const pathname = `/api/documentation/${route}/`.replace('/documentation//', '/documentation/');
	const emptyCollection = ['collection', 'collectionGroup'].includes(document.metadata?.role)
		&& !abstract
		&& !document.primaryContentSections?.length;
	return {
		canonical: new URL(pathname, site).href,
		description,
		indexable: !document.metadata?.extendedModule && !emptyCollection,
		moduleName,
		role,
		title,
	};
}
