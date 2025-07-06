# ------------------------------------------------------------------------------
# Phony targets and set up
# ------------------------------------------------------------------------------
# List of known targets to exclude
KNOWN_TARGETS := help \
	setup cleanup \
	 install uninstall freeze \
	 runserver \
	 lint test \

# Declare known targets (not KNOWN_TARGETS itself) as phony
.PHONY: $(KNOWN_TARGETS)

# ARGS are everything passed to make, except known targets
ARGS := $(filter-out $(KNOWN_TARGETS),$(MAKECMDGOALS))




# ------------------------------------------------------------------------------
# help: show this help text
# ------------------------------------------------------------------------------
help:
	@echo "Makefile for managing the project"
	@echo ""
	@echo "  help        - Show this help text"
	@echo ""
	@echo "Environment targets:"
	@echo "  setup       - Set up the environment"
	@echo "  install     - Install dependencies"
	@echo "  uninstall   - Uninstall dependencies"
	@echo "  freeze      - Freeze current environment into requirements.txt"
	@echo ""
	@echo "Server targets:"
	@echo "  runserver   - Run the web server"
	@echo ""
	@echo "Quality targets:"
	@echo "  lint        - Run code quality checks"
	@echo "  test        - Run tests"
	@echo ""


# ------------------------------------------------------------------------------
# Environment Related Targets
# ------------------------------------------------------------------------------
setup:
	chmod +x ./bin/setup.sh
	./bin/setup.sh

cleanup:
	@echo "Cleaning up directories..."
	chmod +x ./bin/cleanup.sh
	./bin/cleanup.sh


# ------------------------------------------------------------------------------
# Package Related Targets
# ------------------------------------------------------------------------------
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


# ------------------------------------------------------------------------------
# Other
# ------------------------------------------------------------------------------
$(ARGS):
	@: