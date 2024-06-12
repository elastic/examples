include .env
export $(shell sed 's/=.*//' .env)
sha1=`git rev-parse --verify HEAD`

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start: ## Start the demo stack
	@echo build a new docker image with GIT_SHA1 ${sha1}
	GIT_SHA1=${sha1} docker-compose -f docker-compose-dev.yml up --build -d

stop: ## Stop the demo stack and remove the Elasticsearch volume
	GIT_SHA1=${sha1} docker-compose -f docker-compose-dev.yml down

proxy: ## Start an ngrok proxy to the bandit server
	ngrok http 9292

proxy-kibana: ## Start an ngrok proxy to the kibana UI.
	ngrok http 5601

stress: ## Stress the application
	@make -C artillery ping

clean: ## Remove logs and other files
	rm log/*.log 2> /dev/null

count: ## Count log lines
	wc -l log/bandit.log

import-dashboards: ## Import dashboards in kibana
	script/import_dashboards -es http://localhost:9200 -dir ./kibana

.PHONY: help proxy proxy-kibana stress start stop count import-dashboards

