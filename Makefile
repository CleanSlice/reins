.PHONY: help install dev docs sync-from-ranch

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

install: ## Install docs deps
	cd docs && npm ci

dev: ## Run docs site in dev mode
	cd docs && npm run dev

docs: ## Build docs static site
	cd docs && npm run build

sync-from-ranch: ## Copy nestjs/ and nuxt/ from a ranch checkout: make sync-from-ranch RANCH_PATH=/path/to/ranch
	@bash scripts/sync-from-ranch.sh "$(RANCH_PATH)"
