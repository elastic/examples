default-task: serve

bundle-check:
	bundle check --path=vendor/bundle || bundle install --path=vendor/bundle

serve: bundle-check
	@echo 'start rack'
	bundle exec rackup --port 9393

test:
	bundle exec rspec
