run-oss: mock-env mock-transcripts
	swift run

xcodeproj:
	swift package generate-xcodeproj --xcconfig-overrides=Development.xcconfig
	xed .

# bootstrap

bootstrap-oss: mock-env mock-transcripts check-dependencies common-crypto-mm postgres-mm webkit-snapshot-mm init-db xcodeproj

bootstrap: submodules check-dependencies common-crypto-mm postgres-mm webkit-snapshot-mm init-db xcodeproj

mock-all-episodes:
	test -f Sources/Server/Transcripts/AllEpisodes.swift \
		|| echo "import PointFree; public func allEpisodes() -> [Episode] { return [] }" > Sources/Server/Transcripts/AllEpisodes.swift

mock-env:
	test -f .env \
		|| cp .env.example .env

mock-transcripts:
	test -d Sources/Server/Transcripts/ \
		|| cp -r Transcripts.example/ Sources/Server/Transcripts/

submodules:
	git submodule sync --recursive || true
	git submodule update --init --recursive || true

# dependencies

check-dependencies: check-cmark check-postgres

check-cmark:
	@command -v cmark > /dev/null \
		|| ( \
			echo "Please make sure cmark is installed!\n\n\$ brew install cmark" \
				&& exit 1 \
	)

check-postgres:
	@psql template1 -c '' \
		|| ( \
			echo "Please make sure Postgres is installed/running!\n\n\$ brew install postgres" \
				&& exit 1 \
	)

# db

db:
	createuser --superuser pointfreeco || true
	createdb --owner pointfreeco pointfreeco_development || true
	createdb --owner pointfreeco pointfreeco_test || true

init-db:
	psql template1 < database/init.sql

deinit-db:
	psql template1 < database/deinit.sql

reset-db: deinit-db init-db

# tests

test-all: test-linux test-mac test-ios

test-linux: mock-all-episodes sourcery
	docker-compose up --abort-on-container-exit --build

test-macos: mock-all-episodes xcodeproj init-db
	xcodebuild test \
		-scheme PointFree-Package \
		-destination platform="macOS"

test-swift: mock-all-episodes init-db
	swift test

# deploy

deploy-production:
	heroku container:push web -a pointfreeco

deploy-staging:
	heroku container:push web -a pointfreeco-staging

deploy-local:
	heroku container:push web -a pointfreeco-local

# local development

linux-start:
	test -f .env \
		|| make local-config
	docker-compose up --build

local-config:
	heroku config --json -a pointfreeco-local > ./.env

# linux helpers

linux-install-cmark:
	apt-get -y install cmake
	git clone https://github.com/commonmark/cmark
	make -C cmark INSTALL_PREFIX=/usr
	make -C cmark install

# sourcery

imports = \
	@testable import PointFreeTests; \
	@testable import StyleguideTests;

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

# colortheme

colortheme:
	mkdir -p $(HOME)/Library/Developer/Xcode/UserData/FontAndColorThemes
	cp -r .PointFree.xccolortheme $(HOME)/Library/Developer/Xcode/UserData/FontAndColorThemes/Point-Free.xccolortheme
