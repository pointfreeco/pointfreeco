default: bootstrap

SWIFT := $(if $(shell command -v xcrun 2> /dev/null),xcrun swift,swift)

bootstrap:
	@if test -e Sources/PointFree/Transcripts/.git; \
		then \
			$(MAKE) bootstrap-private; \
		else \
			$(MAKE) bootstrap-oss; \
		fi

bootstrap-oss:
	@echo "  ⚠️  Bootstrapping open-source Point-Free..."
	@set -e; set -o pipefail; $(MAKE) .env | sed "s/make\[1\]: \`\.env'/\  ✅ $$(tput bold).env$$(tput sgr0)/"
	@$(MAKE) xcodeproj-oss
	@$(MAKE) install-mm
	@echo "  ✅ Bootstrapped! Opening Xcode..."
	@sleep 1 && xed .

bootstrap-oss-lite:
	@echo "  ⚠️  Bootstrapping open-source Point-Free (lite)..."
	@$(MAKE) xcodeproj-oss
	@echo "  ✅ Bootstrapped! Opening Xcode..."
	@sleep 1 && xed .

bootstrap-private:
	@echo "  👀 Bootstrapping Point-Free (private)..."
	@$(MAKE) xcodeproj
	@$(MAKE) install-mm
	@echo "  ✅ Bootstrapped! Opening Xcode..."
	@sleep 1 && xed .

uninstall: uninstall-mm db-drop

install-mm:
	@if test -d Sources/PointFree/Transcripts/.git; \
		then \
			echo "  ⚠️  Installing module maps into SDK path..."; \
		else \
			echo "$$MODULE_MAP_WARNING"; \
		fi
	@$(MAKE) install-mm-commoncrypto || (echo "$$MODULE_MAP_ERROR" && exit 1)
	@$(MAKE) install-mm-cmark
	@$(MAKE) install-mm-postgres
	@$(MAKE) install-mm-xcodeproj
	@echo "  ✅ Module maps installed!"

install-mm-cmark: $(CCMARK_MODULE_MAP_PATH)
	@$(SUDO) mkdir -p "$(CCMARK_PATH)"
	@echo "$$CCMARK_MODULE_MAP" | sudo tee "$(CCMARK_MODULE_MAP_PATH)" > /dev/null

install-mm-commoncrypto: $(COMMON_CRYPTO_MODULE_MAP_PATH)
	@$(SUDO) mkdir -p "$(COMMON_CRYPTO_PATH)"
	@echo "$$COMMON_CRYPTO_MODULE_MAP" | sudo tee "$(COMMON_CRYPTO_MODULE_MAP_PATH)" > /dev/null

install-mm-postgres: $(POSTGRES_MODULE_MAP_PATH)
	@$(SUDO) mkdir -p "$(POSTGRES_PATH)"
	@echo "$$POSTGRES_MODULE_MAP" | $(SUDO) tee "$(POSTGRES_PATH)/module.map" > /dev/null
	@echo "$$POSTGRES_SHIM_H" | $(SUDO) tee "$(POSTGRES_PATH)/shim.h" > /dev/null

install-mm-xcodeproj: PointFree.xcodeproj
	@ls PointFree.xcodeproj/GeneratedModuleMap | xargs -n1 -I '{}' $(SUDO) mkdir -p "$(FRAMEWORKS_PATH)/{}.framework"
	@ls PointFree.xcodeproj/GeneratedModuleMap | xargs -n1 -I '{}' $(SUDO) cp "./PointFree.xcodeproj/GeneratedModuleMap/{}/module.modulemap" "$(FRAMEWORKS_PATH)/{}.framework/module.map"

uninstall-mm:
	@echo "  ⚠️  Uninstalling module maps from SDK path..."
	@$(SUDO) rm -r "$(COMMON_CRYPTO_PATH)" || (echo "$$MODULE_MAP_ERROR_UNINSTALL")
	@$(SUDO) rm -r "$(CCMARK_PATH)"
	@$(SUDO) rm -r "$(POSTGRES_PATH)"
	@ls PointFree.xcodeproj/GeneratedModuleMap | xargs -n1 -I '{}' $(SUDO) rm "$(FRAMEWORKS_PATH)/{}.framework/module.map"
	@echo "  ✅ Module maps uninstalled!"

check-dependencies: check-cmark check-postgres

check-cmark:
	@echo "  ⚠️  Checking on cmark..."
	@command -v cmark >/dev/null || (echo "$$CMARK_ERROR" && exit 1)
	@echo "  ✅ cmark is installed!"

check-postgres:
	@echo "  ⚠️  Checking on PostgreSQL..."
	@command -v psql >/dev/null || (echo "$$POSTGRES_ERROR_INSTALL" && exit 1)
	@psql template1 --command '' 2>/dev/null || \
		(echo "$$POSTGRES_ERROR_RUNNING" && exit 1)
	@echo "  ✅ PostgreSQL is up and running!"
	@psql --dbname=pointfreeco_development --username=pointfreeco --command '' \
		2>/dev/null || (echo "$$POSTGRES_WARNING" && $(MAKE) --quiet db)

db:
	createuser --superuser pointfreeco || true
	createdb --owner pointfreeco pointfreeco_development || true
	createdb --owner pointfreeco pointfreeco_test || true

db-drop:
	dropdb --username pointfreeco pointfreeco_development || true
	dropdb --username pointfreeco pointfreeco_test || true
	dropuser pointfreeco || true


xcodeproj-oss: check-dependencies
	@echo "  ⚠️  Generating \033[1mPointFree.xcodeproj\033[0m..."
	@$(SWIFT) package generate-xcodeproj --xcconfig-overrides=OSS.xcconfig >/dev/null \
		&& echo "  ✅ Generated!" \
		|| (echo "  🛑 Failed!" && exit 1)

.env: .env.example
	@echo "  ⚠️  Preparing local configuration..."
	@test -f .env && echo "$$DOTENV_ERROR" && exit 1 || true
	@cp .env.example .env
	@echo "  ✅ \033[1m.env\033[0m file copied!"

SDK_PATH = $(shell xcrun --show-sdk-path 2>/dev/null)
FRAMEWORKS_PATH = $(SDK_PATH)/System/Library/Frameworks

CCMARK_PATH = $(FRAMEWORKS_PATH)/Ccmark.framework
CCMARK_MODULE_MAP_PATH = $(CCMARK_PATH)/module.map
define CCMARK_MODULE_MAP
module Ccmark [system] {
  header "/usr/local/Cellar/cmark/0.28.3/include/cmark.h"
  export *
}
endef
export CCMARK_MODULE_MAP

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

define MODULE_MAP_WARNING
  ⚠️  Point-Free installs module maps into your Xcode SDK path to enable
     playground support. If you don't want to run playgrounds, bootstrap with:

       $$ \033[1mmake\033[0m \033[38;5;66mbootstrap-oss-lite\033[0m

     You can undo this at any time by running the following:

       $$ \033[1mmake\033[0m \033[38;5;66muninstall-mm\033[0m

endef
export MODULE_MAP_WARNING

define MODULE_MAP_ERROR
  🛑 Couldn't install module maps! Point-Free requires \033[1msudo\033[0m access to install
     module maps for playground support.

endef
export MODULE_MAP_ERROR

define MODULE_MAP_ERROR_UNINSTALL
  🛑 Couldn't uninstall module maps! Point-Free requires \033[1msudo\033[0m access to
     uninstall its module maps.

endef
export MODULE_MAP_ERROR_UNINSTALL

define CMARK_ERROR
  🛑 cmark not found! Point-Free uses cmark to render Markdown for transcripts
     and blog posts.

     You can install it with your favorite package manager, e.g.:

       $$ \033[1mbrew\033[0m \033[38;5;66minstall cmark\033[0m

endef
export CMARK_ERROR

define DOTENV_ERROR
  🛑 Local configuration already exists at \033[1m.env\033[0m!

     Please reset the file:

       $$ \033[1mrm\033[0m \033[38;5;66m.env\033[0m

     Or manually edit it:

       $$ \033[1m$$EDITOR\033[0m \033[38;5;66minstall cmark\033[0m

endef
export DOTENV_ERROR

define POSTGRES_ERROR_INSTALL
  🛑 PostgreSQL not found! Point-Free uses PostgreSQL as its database.

     Install it with your favorite package manager, e.g.:

       $$ \033[1mbrew\033[0m \033[38;5;66minstall postgresql\033[0m

endef
export POSTGRES_ERROR_INSTALL

define POSTGRES_ERROR_RUNNING
  🛑 PostgreSQL isn't running! Point-Free uses PostgreSQL as its database.

     Make sure it's spawned by running, e.g.:

       $$ \033[1mpg_ctl\033[0m \033[38;5;66m-D /usr/local/var/postgres start\033[0m

endef
export POSTGRES_ERROR_RUNNING

define POSTGRES_WARNING
  ⚠️  Local databases aren't configured! Creating pointfreeco user/databases...

     Reset at any time with:

       $$ \033[1mmake\033[0m \033[38;5;66mdb-drop\033[0m

endef
export POSTGRES_WARNING

# colortheme

COLOR_THEMES_PATH = $(HOME)/Library/Developer/Xcode/UserData/FontAndColorThemes
COLOR_THEME = $(COLOR_THEMES_PATH)/Point-Free.xccolortheme

colortheme:
	@echo "  ⚠️  Installing \033[1mPoint-Free.xcolortheme\033[0m..."
	@mkdir -p $(COLOR_THEMES_PATH)
	@cp -r .PointFree.xccolortheme $(COLOR_THEME)
	@echo "  ✅ Installed!"

uninstall-colortheme:
	rm -r $(COLOR_THEME)

# sourcery

sourcery: sourcery-routes sourcery-tests

sourcery-routes:
	@echo "  ⚠️  Generating routes..."
	@mkdir -p ./Sources/PointFree/__Generated__
	@.bin/sourcery \
		--quiet \
		--sources ./Sources/PointFree/ \
		--templates ./.sourcery-templates/DerivePartialIsos.stencil \
		--output ./Sources/PointFree/__Generated__/DerivedPartialIsos.swift
	@echo "  ✅ Generated!"

SOURCERY_TESTS_IMPORTS = \
	@testable import PointFreeTests; \
	@testable import StyleguideTests;

sourcery-tests: check-sourcery
	@echo "  ⚠️  Generating tests..."
	@.bin/sourcery \
		--quiet \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/LinuxMain.stencil \
		--output ./Tests/ \
		--args testimports='$(SOURCERY_TESTS_IMPORTS)'
	@mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift
	@echo "  ✅ Generated!"

# private

xcodeproj: check-dependencies
	@echo "  ⚠️  Generating \033[1mPointFree.xcodeproj\033[0m..."
	@$(SWIFT) package generate-xcodeproj --xcconfig-overrides=Development.xcconfig >/dev/null
	@xed .
	@echo "  ✅ Generated!"

submodules:
	@echo "  ⚠️  Fetching transcripts..."
	@git submodule sync --recursive >/dev/null
	@git submodule update --init --recursive >/dev/null
	@echo "  ✅ Fetched!"

linux-start:
	docker-compose up --build

env-local:
	heroku config --json -a pointfreeco-local > .env

deploy-local:
	@heroku container:push web -a pointfreeco-local
	@heroku container:release web -a pointfreeco-local

deploy-production:
	@heroku container:push web -a pointfreeco
	@heroku container:release web -a pointfreeco

test-linux: sourcery
	docker-compose up --abort-on-container-exit --build

test-oss: db
	@$(SWIFT) test -Xswiftc "-D" -Xswiftc "OSS"

scorch-docker:
	@docker container ls --all --quiet \
		| xargs docker container stop \
		&& docker system prune --all --force --volumes

SUDO = sudo --prompt=$(SUDO_PROMPT)
SUDO_PROMPT = "  🔒 Please enter your password: "

.PHONY: bootstrap-oss \
	bootstrap-oss-lite \
	bootstrap \
	install-mm \
	install-mm-cmark \
	install-mm-commoncrypto \
	install-mm-postgres \
	install-mm-xcodeproj \
	uninstall \
	uninstall-mm \
	uninstall-colortheme \
	check-dependencies \
	check-cmark \
	check-postgres \
	check-sourcery \
	db \
	db-drop \
	xcodeproj-oss \
	xcodeproj \
	submodule \
	env-local \
	deploy-local \
	deploy-production \
	test-oss
