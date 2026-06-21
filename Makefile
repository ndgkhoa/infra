# Convenience wrappers. `make up` brings up everything.
.DEFAULT_GOAL := help
COMPOSE := docker compose

.PHONY: help up down restart ps logs db cache mq auth pull nuke

help: ## Show this help
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

up: ## Start all services
	$(COMPOSE) --profile all up -d

down: ## Stop all services (keep data)
	$(COMPOSE) --profile all down

restart: ## Restart all services
	$(COMPOSE) --profile all restart

ps: ## List running services
	$(COMPOSE) --profile all ps

logs: ## Tail logs (use: make logs s=postgres)
	$(COMPOSE) logs -f $(s)

db: ## Start databases only (postgres + mysql)
	$(COMPOSE) --profile db up -d

cache: ## Start redis only
	$(COMPOSE) --profile cache up -d

mq: ## Start rabbitmq only
	$(COMPOSE) --profile mq up -d

auth: ## Start authentik (server + worker)
	$(COMPOSE) --profile auth up -d

pull: ## Pull latest pinned images
	$(COMPOSE) --profile all pull

nuke: ## DESTROY all containers AND data volumes (irreversible)
	$(COMPOSE) --profile all down -v
