default: bootstrap

SWIFT := $(if $(shell command -v xcrun 2> /dev/null),xcrun swift,swift)

bootstrap: check-cmark check-postgres .pf-env

fetch-gh-user:
	curl -H "application/vnd.github.v3+json" https://api.github.com/user/$(USER_ID)

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

.pf-env: .pf-env.example
	@echo "  ⚠️  Preparing local configuration..."
	@test -f .pf-env && echo "$$DOTENV_ERROR" && exit 1 || true
	@cp .pf-env.example .pf-env
	@echo "  ✅ \033[1m.pf-env\033[0m file copied!"

db:
	createuser --superuser pointfreeco || true
	createdb --owner pointfreeco pointfreeco_development || true
	createdb --owner pointfreeco pointfreeco_test || true

db-drop:
	dropdb --username pointfreeco pointfreeco_development || true
	dropdb --username pointfreeco pointfreeco_test || true
	dropuser pointfreeco || true

/usr/local/bin/stripe:
	brew install stripe/stripe-cli/stripe

stripe-listen: /usr/local/bin/stripe
	stripe listen \
		--events invoice.payment_failed,invoice.payment_succeeded,customer.subscription.deleted \
		--forward-to localhost:8080/webhooks/stripe \
		--latest \
		--print-json

define DOTENV_ERROR
  🛑 Local configuration already exists at \033[1m.pf-env\033[0m!

     Please reset the file:

       $$ \033[1mrm\033[0m \033[38;5;66m.pf-env\033[0m

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

# private

test-oss: db
	@$(SWIFT) test \
		--enable-test-discovery \
		-Xswiftc -D -Xswiftc OSS

test-linux:
	docker-compose build && docker-compose run \
		--entrypoint "swift test --enable-test-discovery --skip-build -Xswiftc -D -Xswiftc OSS" web

linux-start:
	docker compose up --build

env-local:
	heroku config --json -a pointfreeco-local > .pf-env

deploy-local:
	@heroku container:login
	@heroku container:push web -a pointfreeco-local
	@heroku container:release web -a pointfreeco-local

deploy-production:
	@git fetch origin
	@test "$$(git status --porcelain)" = "" \
		|| (echo "  🛑 Can't deploy while the working tree is dirty" && exit 1)
	@test "$$(git rev-parse @)" = "$$(git rev-parse origin/main)" \
		&& test "$$(git rev-parse --abbrev-ref HEAD)" = "main" \
		|| (echo "  🛑 Must deploy from an up-to-date origin/main" && exit 1)
	@heroku container:login
	@heroku container:push web -a pointfreeco
	@heroku container:release web -a pointfreeco

scorch-docker:
	@docker container ls --all --quiet \
		| xargs docker container stop \
		&& docker system prune --all --force --volumes

clean-snapshots:
	find Tests -name "__Snapshots__" | xargs -n1 rm -fr

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Package.swift ./Sources ./Tests

.PHONY: bootstrap \
	uninstall-colortheme \
	check-cmark \
	check-postgres \
	db \
	db-drop \
	deploy-local \
	deploy-production \
	env-local \
	format \
	test-oss
