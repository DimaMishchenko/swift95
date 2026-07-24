SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

CATALOG_PATH := Catalog
CATALOG_WORKSPACE := $(CATALOG_PATH)/Swift95Catalog.xcworkspace
CATALOG_SCHEME := Swift95Catalog
IOS_TEST_SCHEME := Swift95
DERIVED_DATA ?= DerivedData
IOS_SIMULATOR ?= iPhone 16 Pro
IOS_OS ?= 18.5
IOS_DESTINATION ?= platform=iOS Simulator,name=$(IOS_SIMULATOR),OS=$(IOS_OS)
IPAD_SIMULATOR ?= iPad Pro 13-inch (M4)
IPAD_OS ?= 18.5
IPAD_DESTINATION ?= platform=iOS Simulator,name=$(IPAD_SIMULATOR),OS=$(IPAD_OS)
XCBEAUTIFY ?= $(shell command -v xcbeautify 2>/dev/null)
ONLY_TESTING ?=
TEST_SELECTION := $(if $(ONLY_TESTING),-only-testing:$(ONLY_TESTING))
XCODEBUILD_FLAGS ?=

ifeq ($(XCBEAUTIFY),)
XCODEBUILD_OUTPUT :=
else
XCODEBUILD_OUTPUT := 2>&1 | $(XCBEAUTIFY)
endif

TEST_XCODEBUILD_FLAGS ?= $(XCODEBUILD_FLAGS) -parallel-testing-enabled NO

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help generate format lint test test-macos test-ios test-ipad build-catalog build-catalog-ios build-catalog-macos check

help:
	@echo "Swift95 developer commands"
	@echo "  make generate             Generate the Catalog Xcode workspace"
	@echo "  make format               Format Swift sources"
	@echo "  make lint                 Check Swift formatting"
	@echo "  make test                 Run macOS, iPhone, and iPad tests"
	@echo "  make test-macos           Run unit, snapshot, and UI tests on macOS"
	@echo "  make test-ios             Run unit, snapshot, and UI tests on iPhone"
	@echo "  make test-ipad            Run unit, snapshot, and UI tests on iPad"
	@echo "  make build-catalog        Build the Catalog for iOS and macOS"
	@echo "  make check                Run formatting checks, tests, and Catalog builds"
	@echo ""
	@echo "Override the simulator when needed:"
	@echo "  make test-ios IOS_SIMULATOR='iPhone 16 Pro' IOS_OS=18.5"
	@echo "  make test-ios IOS_DESTINATION='platform=iOS Simulator,id=<UDID>'"
	@echo "  make test-ios ONLY_TESTING='Swift95UITests/Swift95CatalogUITests/testName'"

generate:
	tuist generate --path $(CATALOG_PATH) --no-open

format:
	swift format -i -r Sources Tests Catalog

lint:
	swift format lint -r Sources Tests Catalog

test: test-macos test-ios test-ipad

test-macos: generate
	swift test
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) $(if $(ONLY_TESTING),$(TEST_SELECTION),-only-testing:Swift95UITests) test $(XCODEBUILD_OUTPUT)

test-ios: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) $(TEST_SELECTION) test $(XCODEBUILD_OUTPUT)

test-ipad: generate
	xcodebuild $(TEST_XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IPAD_DESTINATION)' -derivedDataPath $(DERIVED_DATA) $(TEST_SELECTION) test $(XCODEBUILD_OUTPUT)

build-catalog: build-catalog-ios build-catalog-macos

build-catalog-ios: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

build-catalog-macos: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) build $(XCODEBUILD_OUTPUT)

check: lint test build-catalog
