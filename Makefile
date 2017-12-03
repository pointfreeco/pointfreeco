imports = \
	@testable import PointFreeTests; \
	@testable import StyleguideTests;

xcodeproj: sourcery
	swift package generate-xcodeproj

sourcery: linux-main route-partial-iso

test-linux: sourcery
	docker build --tag swift-web-test . \
		&& docker run --rm swift-web-test

test-macos: xcodeproj
	set -o pipefail && \
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="macOS" \
		| xcpretty

test-ios: xcodeproj
	set -o pipefail && \
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.1" \
		| xcpretty

test-swift: sourcery
	swift test

test-all: test-linux test-mac test-ios

linux-main:
	sourcery \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/LinuxMain.stencil \
		--output ./Tests/ \
		--args testimports='$(imports)' \
		&& mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift

route-partial-iso:
	sourcery \
		--sources ./Sources/PointFree/ \
		--templates ./.sourcery-templates/RoutePartialIsos.stencil \
		--output ./Sources/PointFree/
