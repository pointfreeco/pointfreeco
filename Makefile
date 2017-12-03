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

postgres-mm:
	-@mkdir -p "$(POSTGRES_PATH)"
	-@echo "$$POSTGRES_MODULE_MAP" > "$(POSTGRES_PATH)/module.map"
	-@echo "$$POSTGRES_SHIM_H" > "$(POSTGRES_PATH)/shim.h"


SDK_PATH = $(shell xcrun --show-sdk-path)
FRAMEWORKS_PATH = $(SDK_PATH)/System/Library/Frameworks
POSTGRES_PATH = $(FRAMEWORKS_PATH)/CPostgreSQL.framework
define POSTGRES_MODULE_MAP
module CPostgreSQL [system] {
    header "shim.h"
    link "pq"
    export *
}
endef
export POSTGRES_MODULE_MAP

define POSTGRES_SHIM_H
#ifndef __CPOSTGRESQL_SHIM_H__
#define __CPOSTGRESQL_SHIM_H__

#include <libpq-fe.h>
#include <postgres_ext.h>

#endif
endef
export POSTGRES_SHIM_H
