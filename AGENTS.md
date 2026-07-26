# Swift95 agent instructions

- Use the Makefile shortcuts as the canonical project interface; run `make help` to list them.
- Use `make format`, `make lint`, and the relevant `make test-*` target while developing. Run
  `make check` for full validation.
- Keep component changes covered by tests and represented in the Catalog.
- Do not record or replace snapshot references unless explicitly requested.
- Preserve support for Swift 6, iOS/iPadOS 18, and macOS 15.
