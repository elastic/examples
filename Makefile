help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start: ## Start the demo stack

proxy: ## Start ngrok proxy

stress: ## Stress the application

.PHONY: help proxy stress
