DOCKER_COMPOSE_PULL ?= yes
DOCKER_COMPOSE_DAEMON ?= yes
DOCKER_COMPOSE_FILE ?= docker-compose.yml

DOCKER_COMPOSE_UP_FLAGS += $(if $(filter yes,$(DOCKER_COMPOSE_DAEMON)),-d)
DOCKER_COMPOSE_BUILD_FLAGS += $(if $(filter yes,$(DOCKER_COMPOSE_PULL)),--pull)
DOCKER_COMPOSE_CLEAN_FLAGS ?= --rmi all --volumes --remove-orphans

.docker-compose-build-complete:
	@[ -f .gitignore -a -z "$$(grep '$@' .gitignore 2> /dev/null)" ] && \
		( $(call _warn,WARNING: $@ not found in .gitignore) ) || true
	$(call log,building from $(DOCKER_COMPOSE_FILE))
	docker-compose -f $(DOCKER_COMPOSE_FILE) build $(DOCKER_COMPOSE_BUILD_FLAGS)
	@touch $@

#> build docker images (force rebuild with -B)
build:: .docker-compose-build-complete | _program_docker-compose
.PHONY: build

#> run docker-compose up
up:: build | _program_docker-compose
	$(call log,starting docker services in $(DOCKER_COMPOSE_FILE))
	docker-compose -f $(DOCKER_COMPOSE_FILE) up $(DOCKER_COMPOSE_UP_FLAGS)
.PHONY: up

#> run docker-compose down
down:: | _program_docker-compose
	$(call log,stopping docker services in $(DOCKER_COMPOSE_FILE))
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
.PHONY: down

#> remove docker-compose artifacts
clean:: | _program_docker-compose
	$(call log,cleaning up docker artifacts)
	docker-compose -f $(DOCKER_COMPOSE_FILE) down $(DOCKER_COMPOSE_CLEAN_FLAGS)
	rm -f .docker-compose-build-complete
.PHONY: clean
