imports = \
	@testable import PointFreeTests; \
	@testable import StyleguideTests;

bootstrap: xcodeproj postgres-mm db

xcodeproj:
	swift package generate-xcodeproj

sourcery: linux-main route-partial-iso

init-db:
	psql < Database/init.sql

deinit-db:
	psql < Database/deinit.sql

test-linux: sourcery init-db
	docker-compose up --abort-on-container-exit --build

test-macos: xcodeproj init-db
	set -o pipefail && \
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="macOS" \
		| xcpretty

test-ios: xcodeproj init-db
	set -o pipefail && \
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.2" \
		| xcpretty

test-swift: init-db
	swift test

test-all: test-linux test-mac test-ios

linux-main:
	sourcery \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/LinuxMain.stencil \
		--output ./Tests/ \
		--args testimports='$(imports)'
	mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift

route-partial-iso:
	mkdir -p ./Sources/PointFree/__Generated__
	sourcery \
		--sources ./Sources/PointFree/ \
		--templates ./.sourcery-templates/RoutePartialIsos.stencil \
		--output ./Sources/PointFree/__Generated__/DerivedPartialIsos.swift

postgres-mm:
	-@sudo mkdir -p "$(POSTGRES_PATH)"
	-@echo "$$POSTGRES_MODULE_MAP" | sudo tee "$(POSTGRES_PATH)/module.map" > /dev/null
	-@echo "$$POSTGRES_SHIM_H" | sudo tee "$(POSTGRES_PATH)/shim.h" > /dev/null

webkit-snapshot-mm:
	-@sudo mkdir -p "$(WEBKIT_SNAPSHOT_CONFIGURATION_PATH)"
	-@echo "$$WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP" | sudo tee "$(WEBKIT_SNAPSHOT_CONFIGURATION_PATH)/module.map" > /dev/null

SDK_PATH = $(shell xcrun --show-sdk-path)
POSTGRES_PATH = $(SDK_PATH)/System/Library/Frameworks/CPostgreSQL.framework
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

WEBKIT_SNAPSHOT_CONFIGURATION_PATH = $(SDK_PATH)/System/Library/Frameworks/WKSnapshotConfigurationShim.framework
define WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP
module WKSnapshotConfigurationShim [system] {
  header "$(SDK_PATH)/System/Library/Frameworks/WebKit.framework/Headers/WKSnapshotConfiguration.h"
  export *
}
endef
export WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP
