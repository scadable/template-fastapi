# ------------------------------------------------------------------------------
# Phony targets and set up
# ------------------------------------------------------------------------------
.PHONY: help runserver setup install uninstall freeze lint test

# collect extra words after the target name
ARGS := $(filter-out help setup lint install uninstall freeze docker-up db-up db-down db-shell status dev-up dev-down migrate test,$(MAKECMDGOALS))



# ------------------------------------------------------------------------------
# help: show this help text
# ------------------------------------------------------------------------------
help:
	@echo "Makefile for managing the project"
	@echo ""
	@echo "Available targets:"
	@echo "  help        - Show this help text"
	@echo "  runserver   - Run the web server"

# ------------------------------------------------------------------------------
# Environment Related Targets
# ------------------------------------------------------------------------------
setup:
	chmod +x ./bin/setup.sh
	./bin/setup.sh

# install dependencies
install:
	@pip install --upgrade pip
ifneq ($(ARGS),)
	@echo "Installing new package(s): $(ARGS)"
	@pip install $(ARGS)
else
	@echo "Installing from requirements.txt"
	@pip install -r requirements.txt
endif
	@$(MAKE) freeze

# uninstall dependencies
uninstall:
ifneq ($(ARGS),)
	@echo "Uninstalling package(s): $(ARGS)"
	@pip uninstall -y $(ARGS)
else
	@echo "Uninstalling everything in requirements.txt"
	@pip uninstall -y -r requirements.txt || true
endif
	@$(MAKE) freeze

# freeze: capture current env into requirements.txt
freeze:
	@echo "Freezing installed packages into requirements.txt"
	@pip freeze > requirements.txt


# ------------------------------------------------------------------------------
# Server Related Targets
# ------------------------------------------------------------------------------
runserver:
	@echo "Running server..."
	uvicorn app.main:app --reload



# ------------------------------------------------------------------------------
# Quality Related Targets
# ------------------------------------------------------------------------------
test:
	@echo "Running tests with pytest"
	@pytest
	@echo "Removing coverage data files"
	@rm -rf .coverage

lint:
	@echo "Running flake8…"
	@flake8 app tests --max-line-length=88
	@echo "✔️  Lint passed"

# ------------------------------------------------------------------------------
# Database Related Targets
# ------------------------------------------------------------------------------
