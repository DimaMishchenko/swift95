# Swift95 agent instructions

- Use the Makefile shortcuts as the canonical project interface; run `make help` to list them.
- Use `make format`, `make lint`, and the relevant `make test-*` target. Run `make check` for full
  package validation.
- Keep component changes covered by tests and represented in the Catalog.
- Do not record or replace snapshot references unless explicitly requested.
- Preserve support for Swift 6, iOS/iPadOS 18, and macOS 15.
- `make generate` creates `Swift95.xcworkspace` with the Catalog and standalone example apps.
- Example apps live in `Examples/`, each with its own target and app-owned feature state. Validate them
  manually and keep them free of test targets. Use `make build-examples` to check compilation.

## Website and documentation

- Website sources are in `Website/`; DocC catalogs are beside their Swift targets.
- Use `make website-dev` locally, `make website-build` for the complete Astro + DocC output, and
  `make website-check` to validate an existing build.
- The build compiles documentation snippets and validates pages, images, links, search, SEO,
  sitemaps, `/llms*.txt`, and Markdown twins.
- Production URLs use `https://swift95.dimasike.com`; override `SITE_URL` only for another origin.
