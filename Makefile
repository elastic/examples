sha1=`git rev-parse --verify HEAD`

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start: ## Start the demo stack
	@echo build a new docker image with GIT_SHA1 ${sha1}
	GIT_SHA1=${sha1} docker-compose -f docker-compose-dev.yml up --build -d 

stop: ## Stop the demo stack
	docker-compose -f docker-compose-dev.yml down

proxy: ## Start ngrok proxy

stress: ## Stress the application

.PHONY: help proxy stress start stop
