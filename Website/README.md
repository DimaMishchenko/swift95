# Swift95 documentation website

The documentation site is built with Astro and Starlight. It contains the custom homepage,
hand-written guides, generated component guides, and the Swift-DocC API reference.

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
