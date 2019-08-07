default: bootstrap

SWIFT := $(if $(shell command -v xcrun 2> /dev/null),xcrun swift,swift)

bootstrap:
	@if test -e Sources/Models/Transcripts/.git; \
		then \
			$(MAKE) bootstrap-private; \
		else \
			$(MAKE) bootstrap-oss; \
		fi

bootstrap-oss:
	@echo "  ⚠️  Bootstrapping open-source Point-Free..."
	@set -e; set -o pipefail; $(MAKE) .env | sed "s/make\[1\]: \`\.env'/\  ✅ $$(tput bold).env$$(tput sgr0)/"
	@$(MAKE) check-dependencies
	@echo "  ✅ Bootstrapped! Opening Xcode..."
	@xed .

bootstrap-private:
	@echo "  👀 Bootstrapping Point-Free (private)..."
	@$(MAKE) check-dependencies
	@echo "  ✅ Bootstrapped! Opening Xcode..."
	@sleep 1 && xed .

uninstall: db-drop

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

.env: .env.example
	@echo "  ⚠️  Preparing local configuration..."
	@test -f .env && echo "$$DOTENV_ERROR" && exit 1 || true
	@cp .env.example .env
	@echo "  ✅ \033[1m.env\033[0m file copied!"

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

sourcery: routes sourcery-tests

routes:
	@echo "  ⚠️  Generating routes..."
	@mkdir -p ./Sources/PointFreeRouter/__Generated__
	@.bin/sourcery \
		--quiet \
		--sources ./Sources/PointFreeRouter/ \
		--templates ./.sourcery-templates/DerivePartialIsos.stencil \
		--output ./Sources/PointFreeRouter/__Generated__/DerivedPartialIsos.swift \
		&& echo "  ✅ Generated!"

SOURCERY_TESTS_IMPORTS = \
	@testable import FunctionalCssTests; \
	@testable import DatabaseTests; \
	@testable import GitHubTests; \
	@testable import ModelsTests; \
	@testable import PointFreeRouterTests; \
	@testable import PointFreeTests; \
	@testable import StripeTests; \
	@testable import StyleguideTests; \
	@testable import SyndicationTests;

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
	@heroku container:login
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

clean-snapshots:
	find Tests -name "__Snapshots__" | xargs -n1 rm -fr

SUDO = sudo --prompt=$(SUDO_PROMPT)
SUDO_PROMPT = "  🔒 Please enter your password: "

.PHONY: \
	bootstrap \
	bootstrap-oss \
	check-cmark \
	check-dependencies \
	check-postgres \
	check-sourcery \
	db \
	db-drop \
	deploy-local \
	deploy-production \
	env-local \
	submodules \
	test-oss \
	uninstall \
	uninstall-colortheme \

