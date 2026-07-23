SHELL := /bin/sh

CATALOG_PATH := Catalog
CATALOG_WORKSPACE := $(CATALOG_PATH)/Swift95Catalog.xcworkspace
CATALOG_SCHEME := Swift95Catalog
IOS_TEST_SCHEME := Swift95Tests
DERIVED_DATA ?= DerivedData
IOS_SIMULATOR ?= iPhone 16 Pro
IOS_OS ?= 18.5
IOS_DESTINATION ?= platform=iOS Simulator,name=$(IOS_SIMULATOR),OS=$(IOS_OS)
XCODEBUILD_FLAGS ?= -quiet

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help generate format lint test test-macos test-ios build-catalog build-catalog-ios build-catalog-macos check

help:
	@echo "Swift95 developer commands"
	@echo "  make generate             Generate the Catalog Xcode workspace"
	@echo "  make format               Format Swift sources"
	@echo "  make lint                 Check Swift formatting"
	@echo "  make test                 Run macOS and iOS tests"
	@echo "  make test-macos           Run package tests on macOS"
	@echo "  make test-ios             Run tests on the iOS Simulator"
	@echo "  make build-catalog        Build the Catalog for iOS and macOS"
	@echo "  make check                Run formatting checks, tests, and Catalog builds"
	@echo ""
	@echo "Override the simulator when needed:"
	@echo "  make test-ios IOS_SIMULATOR='iPhone 16 Pro' IOS_OS=18.5"
	@echo "  make test-ios IOS_DESTINATION='platform=iOS Simulator,id=<UDID>'"

generate:
	tuist generate --path $(CATALOG_PATH) --no-open

format:
	swift format -i -r Sources Tests Catalog

lint:
	swift format lint -r Sources Tests Catalog

test: test-macos test-ios

test-macos:
	swift test

test-ios: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(IOS_TEST_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) test

build-catalog: build-catalog-ios build-catalog-macos

build-catalog-ios: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination '$(IOS_DESTINATION)' -derivedDataPath $(DERIVED_DATA) build

build-catalog-macos: generate
	xcodebuild $(XCODEBUILD_FLAGS) -workspace $(CATALOG_WORKSPACE) -scheme $(CATALOG_SCHEME) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) build

check: lint test build-catalog
