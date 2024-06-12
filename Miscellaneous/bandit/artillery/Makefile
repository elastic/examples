ENV?=dev
DEBUG?=http,http:response
scenarii := $(shell ls scenarii | sed -e 's/.yml//')

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

build: ## Build the artillery docker image.
	docker-compose build artillery

clean: ## Clean the report folder.
	rm -f report/*

$(scenarii): %: ## Dynamic tasks
	@echo "Start $* scenario for ${ENV} environment with debug params (${DEBUG}) "
	docker-compose run -e DEBUG=${DEBUG} artillery --environment ${ENV} /code/scenarii/$*.yml

list: ## List existing scenarii.
	@echo ${scenarii}

.PHONY: clean help build list
