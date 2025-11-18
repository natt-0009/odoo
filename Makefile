.PHONY: help start build up down restart logs shell db-shell clean rebuild

help: ## Show this help
	@echo "Odoo Development Environment - Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Start Odoo (recommended)
	@bash start.sh

build: ## Build Docker images
	docker-compose build

up: ## Start services (without start script)
	docker-compose up -d
	@echo "✓ Services started"
	@echo "Odoo: http://localhost:8089"
	@echo "pgAdmin: http://localhost:5050"

down: ## Stop all services
	docker-compose down

restart: ## Restart services
	docker-compose restart
	@echo "✓ Services restarted"

logs: ## View all logs
	docker-compose logs -f

logs-web: ## View Odoo logs
	docker-compose logs -f web

logs-db: ## View database logs
	docker-compose logs -f db

shell: ## Access Odoo shell
	docker-compose exec web bash

db-shell: ## Access PostgreSQL shell
	docker-compose exec db psql -U odoo

ps: ## Show running containers
	docker-compose ps

clean: ## Stop and remove volumes (WARNING: deletes data!)
	@echo "WARNING: This will delete all data!"
	@read -p "Continue? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ]; then \
		docker-compose down -v; \
		rm -f .initialized; \
		echo "✓ Cleaned"; \
	fi

rebuild: ## Rebuild images and restart
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✓ Rebuilt and restarted"

install: ## Install module (Usage: make install DB=dbname MODULE=module_name)
	@if [ -z "$(DB)" ] || [ -z "$(MODULE)" ]; then \
		echo "Usage: make install DB=dbname MODULE=module_name"; \
		exit 1; \
	fi
	docker-compose exec web odoo-bin --config=/etc/odoo/odoo.conf -d $(DB) -i $(MODULE) --stop-after-init
	docker-compose restart web
	@echo "✓ Module $(MODULE) installed"

update: ## Update module (Usage: make update DB=dbname MODULE=module_name)
	@if [ -z "$(DB)" ] || [ -z "$(MODULE)" ]; then \
		echo "Usage: make update DB=dbname MODULE=module_name"; \
		exit 1; \
	fi
	docker-compose exec web odoo-bin --config=/etc/odoo/odoo.conf -d $(DB) -u $(MODULE) --stop-after-init
	docker-compose restart web
	@echo "✓ Module $(MODULE) updated"

init-db: ## Initialize database (Usage: make init-db DB=dbname)
	@if [ -z "$(DB)" ]; then \
		echo "Usage: make init-db DB=dbname"; \
		exit 1; \
	fi
	docker-compose exec web odoo-bin --config=/etc/odoo/odoo.conf -d $(DB) -i base --stop-after-init
	docker-compose restart web
	@echo "✓ Database $(DB) initialized"
