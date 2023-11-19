# .PHONY: build
# build: build-core build-reverse-proxy;

# .PHONY: build-core
# build-core:
# 	docker build . -t core:current

# .PHONY: build-reverse-proxy
# build-reverse-proxy:
# 	docker build . -f Dockerfile-reverse-proxy -t core-reverse-proxy:current


.PHONY: install
install:
	poetry install

.PHONY: migrations
migrations:
	poetry run python -m core.manage makemigrations

.PHONY: migrate
migrate:
	poetry run python -m core.manage migrate

.PHONY: superuser
superuser:
	 poetry run python -m core.manage createsuperuser

# admin
# admin@admin.com
# admin123.*

.PHONY: lint
lint:
	poetry run pre-commit run --all-files
.PHONY: install-pre-commit
install-pre-commit:
	poetry run pre-commit uninstall; poetry run pre-commit install

.PHONY: update
update: install migrate install-pre-commit ;

.PHONY: shell
shell:
	poetry run python -m core.manage shell

.PHONY: dbshell
dbshell:
	poetry run python -m core.manage dbshell

.PHONY: up-dependencies-only
up-dependencies-only:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --force-recreate db redis

.PHONY: run-server
run-server:
	poetry run python -m core.manage runserver 127.0.0.1:8000

# .PHONY: dot-env
# dot-env:
# 	grep -q -o CORESETTING_SECRET_KEY .env 2> /dev/null || echo "CORESETTING_SECRET_KEY=$$(xxd -c 48 -l 48 -p /dev/urandom)" >> .env

# .PHONY: run-dockerized-build
# run-dockerized-build: build dot-env
# 	docker compose -f docker-compose.yml -f docker-compose.build.yml up --no-build --force-recreate

# .PHONY: run-dockerized-from-registry
# run-dockerized-from-registry: dot-env
# 	echo '(username=github username; password=github personal access token (not github password)'
# 	docker login ghcr.io
# 	docker compose pull
# 	docker compose up --no-build --force-recreate



.PHONY: test
test:
	poetry run pytest -v -rs -n auto --show-capture=no

.PHONY: test-fail-fast
test-fail-fast:
	poetry run pytest -x -v -rs -n auto --show-capture=no

.PHONY: test-stepwise
test-stepwise:
	poetry run pytest --reuse-db --sw -vv

.PHONY: test-with-coverage
test-with-coverage:
	poetry run pytest -vv --cov=core --cov-report=html

.PHONY: test-dockerized
test-dockerized:
	docker compose -f docker-compose.test.yml build
	docker compose -f docker-compose.test.yml run -i --rm sut
	docker compose -f docker-compose.test.yml stop db redis  # docker compose run leaves them running

.PHONY: lint-and-test
lint-and-test: lint test ;
