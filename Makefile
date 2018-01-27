bootstrap: check-postgres commoncrypto-mm postgres-mm webkit-snapshot-mm init-db xcodeproj

imports = \
	@testable import PointFreeTests; \
	@testable import StyleguideTests;

xcodeproj:
	swift package generate-xcodeproj --xcconfig-overrides=Development.xcconfig
	xed .

# db

check-postgres:
	@psql template1 -c '' \
		|| ( \
			echo "Please make sure Postgres is installed/running!" \
				&& exit 1 \
	)

init-db:
	psql template1 < database/init.sql

deinit-db:
	psql template1 < database/deinit.sql

reset-db: deinit-db init-db

# tests

test-all: test-linux test-mac test-ios

test-linux: sourcery
	docker-compose up --abort-on-container-exit --build

test-macos: xcodeproj init-db
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="macOS"

test-ios: xcodeproj init-db
	set -o pipefail && \
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.2" \
		| xcpretty

test-swift: init-db
	swift test

# sourcery

sourcery: linux-main route-partial-iso

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
		--templates ./.sourcery-templates/DerivePartialIsos.stencil \
		--output ./Sources/PointFree/__Generated__/DerivedPartialIsos.swift

# module maps

common-crypto-mm:
	-@sudo mkdir -p "$(COMMON_CRYPTO_PATH)"
	-@echo "$$COMMON_CRYPTO_MODULE_MAP" | sudo tee "$(COMMON_CRYPTO_MODULE_MAP_PATH)" > /dev/null

postgres-mm:
	-@sudo mkdir -p "$(POSTGRES_PATH)"
	-@echo "$$POSTGRES_MODULE_MAP" | sudo tee "$(POSTGRES_PATH)/module.map" > /dev/null
	-@echo "$$POSTGRES_SHIM_H" | sudo tee "$(POSTGRES_PATH)/shim.h" > /dev/null

webkit-snapshot-mm:
	-@sudo mkdir -p "$(WEBKIT_SNAPSHOT_CONFIGURATION_PATH)"
	-@echo "$$WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP" | sudo tee "$(WEBKIT_SNAPSHOT_CONFIGURATION_PATH)/module.map" > /dev/null

SDK_PATH = $(shell xcrun --show-sdk-path)
FRAMEWORKS_PATH = $(SDK_PATH)/System/Library/Frameworks
COMMON_CRYPTO_PATH = $(FRAMEWORKS_PATH)/CommonCrypto.framework
COMMON_CRYPTO_MODULE_MAP_PATH = $(COMMON_CRYPTO_PATH)/module.map
define COMMON_CRYPTO_MODULE_MAP
module CommonCrypto [system] {
  header "$(SDK_PATH)/usr/include/CommonCrypto/CommonCrypto.h"
  header "$(SDK_PATH)/usr/include/CommonCrypto/CommonRandom.h"
  export *
}
endef
export COMMON_CRYPTO_MODULE_MAP

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

WEBKIT_SNAPSHOT_CONFIGURATION_PATH = $(FRAMEWORKS_PATH)/WKSnapshotConfigurationShim.framework
define WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP
module WKSnapshotConfigurationShim [system] {
  header "$(SDK_PATH)/System/Library/Frameworks/WebKit.framework/Headers/WKSnapshotConfiguration.h"
  export *
}
endef
export WEBKIT_SNAPSHOT_CONFIGURATION_MODULE_MAP
