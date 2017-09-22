sha1=`git rev-parse --verify HEAD`

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start: ## Start the demo stack
	@echo build a new docker image with GIT_SHA1 ${sha1}
	GIT_SHA1=${sha1} docker-compose -f docker-compose-dev.yml up --build -d 

stop: ## Stop the demo stack and remove the Elasticsearch volume
	docker-compose -f docker-compose-dev.yml down -v

proxy: ## Start an ngrok proxy to the bandit server
	ngrok http 9292 

proxy-kibana: ## Start an ngrok proxy to the kibana UI.
	ngrok http 5601

stress: ## Stress the application
	cd artillery && make ping

clean: ## Remove logs and other files
	rm log/*.log 2> /dev/null 

.PHONY: help proxy proxy-kibana stress start stop
