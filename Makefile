SHELL := /bin/bash -o pipefail

CATALOG_PATH := Catalog
WEBSITE_PATH := Website
WEBSITE_OUTPUT_PATH := $(WEBSITE_PATH)/dist
DOCC_BUILD_PATH := .build/docc
DOCC_SITE_PATH := .build/docc-site
DOCC_HOSTING_BASE_PATH := api
DOCC_OUTPUT_PATH := $(DOCC_SITE_PATH)/$(DOCC_HOSTING_BASE_PATH)
DOCC_DEPLOY_PATH := $(WEBSITE_OUTPUT_PATH)/$(DOCC_HOSTING_BASE_PATH)
DOCC_ROOT_REDIRECT := $(WEBSITE_PATH)/src/docc-root-redirect.html
SNIPPET_PACKAGE_PATH := .build/documentation-snippets
SNIPPET_BUILD_PATH := .build/documentation-snippets-build
CATALOG_WORKSPACE := Swift95.xcworkspace
EXAMPLES_SCHEME := Examples
CATALOG_SCHEME := Swift95Catalog
IOS_TEST_SCHEME := Swift95
# Keep macOS UI-test runners outside protected user folders such as Documents.
DERIVED_DATA ?= $(TMPDIR)swift95-derived-data
SWIFT60_BUILD_PATH ?= $(DERIVED_DATA)/swift60
IOS_TEST_PRODUCTS := $(DERIVED_DATA)/Swift95-iOS.xctestproducts
IOS_TEST_RESULTS := $(DERIVED_DATA)/Logs/Test/$(shell uuidgen)
IOS_SIMULATOR ?= iPhone 17 Pro
IOS_OS ?= 26.5
IOS_DESTINATION ?= platform=iOS Simulator,name=$(IOS_SIMULATOR),OS=$(IOS_OS)
IPAD_SIMULATOR ?= iPad Pro 13-inch (M5)
IPAD_OS ?= 26.5
IPAD_DESTINATION ?= platform=iOS Simulator,name=$(IPAD_SIMULATOR),OS=$(IPAD_OS)
XCBEAUTIFY ?= $(shell command -v xcbeautify 2>/dev/null)
ONLY_TESTING ?=
TEST_SELECTION := $(foreach selection,$(ONLY_TESTING),-only-testing:$(selection))
SWIFT_TEST_ARGS ?=
XCODEBUILD_TEST_FLAGS ?=
XCODEBUILD_FLAGS ?=

ifeq ($(XCBEAUTIFY),)
XCODEBUILD_OUTPUT :=
else
XCODEBUILD_OUTPUT := 2>&1 | $(XCBEAUTIFY)
endif

TEST_XCODEBUILD_FLAGS ?= $(XCODEBUILD_FLAGS) -parallel-testing-enabled NO

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help generate format lint check-swift60 test test-package test-catalog test-macos test-macos-ui test-mobile build-mobile-tests test-ios-built test-ipad-built test-ios test-ipad build-catalog build-catalog-ios build-catalog-macos build-examples build-examples-macos build-examples-ios website-dev website-build website-check .website-examples .website-astro .website-docc check

help:
	@echo "Swift95 developer commands"
	@echo "  make generate             Generate the workspace with Catalog and three example apps"
	@echo "  make format               Format Swift sources"
	@echo "  make lint                 Check Swift formatting"
	@echo "  make check-swift60        Build both library targets for macOS and iOS using Swift 6.0"
	@echo "  make test                 Run macOS, iPhone, and iPad tests"
	@echo "  make test-macos           Run unit, snapshot, and UI tests on macOS"
	@echo "  make test-package         Run Swift package tests"
	@echo "  make test-catalog         Run macOS UI and mobile tests with shared builds"
	@echo "  make test-macos-ui        Run Catalog UI tests on macOS"
	@echo "  make test-mobile          Build mobile tests once and run on iPhone and iPad"
	@echo "  make build-mobile-tests   Build reusable mobile test products"
	@echo "  make test-ios-built       Run existing mobile test products on iPhone"
	@echo "  make test-ipad-built      Run existing mobile test products on iPad"
	@echo "  make test-ios             Run unit, snapshot, and UI tests on iPhone"
	@echo "  make test-ipad            Run unit, snapshot, and UI tests on iPad"
	@echo "  make build-catalog        Build the Catalog for iOS and macOS"
	@echo "  make build-examples       Build all example apps for iOS and macOS"
	@echo "  make website-dev         Start the documentation website"
	@echo "  make website-build       Generate examples and build the complete website"
	@echo "  make website-check       Validate an existing website build"
	@echo "  make check                Run formatting checks, tests, and Catalog and example builds"
	@echo ""
	@echo "Override the simulator when needed:"
	@echo "  make test-ios IOS_SIMULATOR='iPhone 17 Pro' IOS_OS=26.5"
	@echo "  make test-ios IOS_DESTINATION='platform=iOS Simulator,id=<UDID>'"
	@echo "  make test-ios ONLY_TESTING='Swift95UITests/Swift95CatalogUITests/testName'"
	@echo "  make test-ios ONLY_TESTING='Swift95UITests Swift95Tests/SystemFonts95Tests'"

generate:
	mkdir -p $(CATALOG_WORKSPACE)/xcshareddata/swiftpm
	cp Package.resolved $(CATALOG_WORKSPACE)/xcshareddata/swiftpm/Package.resolved
	tuist generate --no-open

format:
	swift format -i -r Sources Tests Catalog Examples Workspace.swift Tuist.swift

lint:
	swift format lint -r Sources Tests Catalog Examples Workspace.swift Tuist.swift

check-swift60:
	swift --version
	@swift --version | grep -Eq 'Swift version 6\.0([ .]|$$)' || { echo 'Select a Swift 6.0 toolchain before running this check.'; exit 1; }
	xcrun --sdk macosx --show-sdk-version
	xcrun --sdk iphonesimulator --show-sdk-version
	swift build --configuration release --scratch-path "$(SWIFT60_BUILD_PATH)-macos" --target Swift95
	swift build --configuration release --scratch-path "$(SWIFT60_BUILD_PATH)-macos" --target Swift95Icons
	swift build --configuration release --scratch-path "$(SWIFT60_BUILD_PATH)-ios" --sdk "$$(xcrun --sdk iphonesimulator --show-sdk-path)" --triple arm64-apple-ios18.0-simulator --target Swift95
	swift build --configuration release --scratch-path "$(SWIFT60_BUILD_PATH)-ios" --sdk "$$(xcrun --sdk iphonesimulator --show-sdk-path)" --triple arm64-apple-ios18.0-simulator --target Swift95Icons

test: test-package test-catalog

test-catalog: test-macos-ui test-mobile

test-package:
	swift test $(SWIFT_TEST_ARGS)

test-macos: test-package test-macos-ui

test-macos-ui: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) $(if $(ONLY_TESTING),$(TEST_SELECTION),-only-testing:Swift95UITests) test $(XCODEBUILD_OUTPUT)

test-mobile: build-mobile-tests test-ios-built test-ipad-built

build-mobile-tests: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) -testProductsPath '$(IOS_TEST_PRODUCTS)' build-for-testing $(XCODEBUILD_OUTPUT)

test-ios-built:
	mkdir -p '$(DERIVED_DATA)/Logs/Test'
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -testProductsPath '$(IOS_TEST_PRODUCTS)' -destination '$(IOS_DESTINATION)' -resultBundlePath '$(IOS_TEST_RESULTS)-iPhone.xcresult' $(TEST_SELECTION) $(XCODEBUILD_TEST_FLAGS) test-without-building $(XCODEBUILD_OUTPUT)

test-ipad-built:
	mkdir -p '$(DERIVED_DATA)/Logs/Test'
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -testProductsPath '$(IOS_TEST_PRODUCTS)' -destination '$(IPAD_DESTINATION)' -resultBundlePath '$(IOS_TEST_RESULTS)-iPad.xcresult' $(TEST_SELECTION) $(XCODEBUILD_TEST_FLAGS) test-without-building $(XCODEBUILD_OUTPUT)

test-ios: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) $(TEST_SELECTION) $(XCODEBUILD_TEST_FLAGS) test $(XCODEBUILD_OUTPUT)

test-ipad: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IPAD_DESTINATION)' -derivedDataPath $(DERIVED_DATA) $(TEST_SELECTION) $(XCODEBUILD_TEST_FLAGS) test $(XCODEBUILD_OUTPUT)

build-catalog: build-catalog-ios build-catalog-macos

build-catalog-ios: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

build-catalog-macos: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

build-examples: build-examples-macos build-examples-ios

build-examples-macos: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(EXAMPLES_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

build-examples-ios: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(EXAMPLES_SCHEME) -destination 'generic/platform=iOS Simulator' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

website-dev:
	npm --prefix $(WEBSITE_PATH) run dev

.website-examples:
	node $(WEBSITE_PATH)/scripts/crop-reference-images.mjs
	swift run DocumentationImageGenerator "$(abspath $(WEBSITE_PATH))/public/images" "$(abspath Assets/README)"
	node $(WEBSITE_PATH)/scripts/extract-snippets.mjs
	swift format lint -r "$(SNIPPET_PACKAGE_PATH)/Sources"
	swift build --package-path "$(SNIPPET_PACKAGE_PATH)" --scratch-path "$(SNIPPET_BUILD_PATH)"

website-build: .website-examples .website-astro .website-docc
	rm -rf "$(DOCC_DEPLOY_PATH)"
	cp -R "$(DOCC_OUTPUT_PATH)" "$(DOCC_DEPLOY_PATH)"
	node $(WEBSITE_PATH)/scripts/optimize-docc-seo.mjs
	$(MAKE) --no-print-directory website-check

website-check:
	node $(WEBSITE_PATH)/scripts/generate-llms.mjs validate --require-api
	node $(WEBSITE_PATH)/scripts/validate-site.mjs --require-api

.website-astro:
	npm --prefix $(WEBSITE_PATH) run build

.website-docc:
	rm -rf "$(DOCC_BUILD_PATH)" "$(DOCC_OUTPUT_PATH)"
	mkdir -p "$(DOCC_BUILD_PATH)" "$(DOCC_SITE_PATH)"
	set -e; \
	trap 'node $(WEBSITE_PATH)/scripts/prepare-docc-content.mjs clean' EXIT; \
	node $(WEBSITE_PATH)/scripts/prepare-docc-content.mjs prepare; \
	swift package --allow-writing-to-directory "$(abspath $(DOCC_BUILD_PATH))" generate-documentation \
		--target Swift95 \
		--output-path "$(abspath $(DOCC_BUILD_PATH))/Swift95.doccarchive" \
		--hosting-base-path "$(DOCC_HOSTING_BASE_PATH)" \
		--no-transform-for-static-hosting; \
	swift package --allow-writing-to-directory "$(abspath $(DOCC_BUILD_PATH))" generate-documentation \
		--target Swift95Icons \
		--output-path "$(abspath $(DOCC_BUILD_PATH))/Swift95Icons.doccarchive" \
		--hosting-base-path "$(DOCC_HOSTING_BASE_PATH)" \
		--no-transform-for-static-hosting; \
	xcrun docc merge \
		"$(DOCC_BUILD_PATH)/Swift95.doccarchive" \
		"$(DOCC_BUILD_PATH)/Swift95Icons.doccarchive" \
		--output-path "$(DOCC_BUILD_PATH)/Swift95.doccarchive-merged" \
		--synthesized-landing-page-name "Swift95" \
		--synthesized-landing-page-kind "Package" \
		--synthesized-landing-page-topics-style detailedGrid; \
	node $(WEBSITE_PATH)/scripts/prepare-docc-content.mjs customize \
		"$(DOCC_BUILD_PATH)/Swift95.doccarchive-merged"; \
	xcrun docc process-archive transform-for-static-hosting \
		"$(DOCC_BUILD_PATH)/Swift95.doccarchive-merged" \
		--output-path "$(DOCC_OUTPUT_PATH)" \
		--hosting-base-path "$(DOCC_HOSTING_BASE_PATH)"; \
	cp "$(DOCC_ROOT_REDIRECT)" "$(DOCC_OUTPUT_PATH)/index.html"

check: lint test build-catalog build-examples
