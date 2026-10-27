# Swift95 documentation website

The documentation site is built with Astro and Starlight. It contains the custom homepage,
hand-written guides, generated component guides, and the Swift-DocC API reference.

Use Node.js 22.22.0 or later. TypeScript stays on 6.x because `astro check` requires its
programmatic language service API, which TypeScript 7 does not provide yet. Track compatibility
in the [Astro TypeScript 7 support discussion](https://github.com/withastro/roadmap/discussions/1321).
The stylesheet declares Starlight's layers before React95's so the documentation reset does
not override React95 10's layered component styles.

From the repository root:

```sh
npm --prefix Website ci
make website-dev
```

Build the static output with:

```sh
make website-build
```

The build also generates `/llms.txt`, complete and abridged context files, and a Markdown twin for
every rendered documentation page. Validate an existing build with `make website-check` from the
repository root.

Canonical URLs and sitemaps use `https://swift95.dimasike.com` by default. Set `SITE_URL` when
building for a different production origin. `make website-check` validates generated LLM files,
metadata, social artwork, structured data, crawler rules, sitemaps, and published agent resources.

Hand-written documentation pages live in `src/content/docs/`; generated component guides are
defined by `src/data/completeGuides.mjs`. Reusable site styling lives in
`src/styles/swift95.css`, and stable images copied from the native snapshot suite live in
`public/images/`.

The scoped `@expressive-code/core` dependency override uses `postcss-nested` 7.0.2 or later
in the 7.x line so its selector parser receives the CPU exhaustion fix from
[`postcss-selector-parser` 7.1.6](https://github.com/postcss/postcss-selector-parser/blob/main/CHANGELOG.md#716---2026-09-03).
This keeps the current Starlight release and PostCSS 8 API. The nesting plugin's
[7.0 changes](https://github.com/postcss/postcss-nested/blob/main/CHANGELOG.md#700)
affect comment placement and require Node 18 or later, which the Astro toolchain already exceeds.

## Analytics

Production pages at `swift95.dimasike.com`, including the generated DocC API pages, use cookie-free Cloudflare Web Analytics. The shared `dimasike.com` analytics site separates traffic by request hostname. Local development and builds for other hostnames omit the beacon.
