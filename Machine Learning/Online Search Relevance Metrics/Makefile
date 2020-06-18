default: test

all: clean init test

venv/bin/activate:
	@rm -rf venv/
	@python3 -m venv venv

tmp:
	@mkdir -p $@

.PHONY: clean
clean:
	@rm -rf venv/ tmp/

.PHONY: init
init: venv/bin/activate
	. venv/bin/activate ; \
	pip install -r requirements.txt

.PHONY: unit-test
unit-test: venv/bin/activate
	. venv/bin/activate ; \
    python3 -m unittest discover -s tests/unit

.PHONY: integration-test
integration-test: venv/bin/activate
	. venv/bin/activate ; \
    python3 -m unittest discover -s tests/integration

test: unit-test integration-test

.PHONY: jupyter
jupyter: venv/bin/activate
	. venv/bin/activate ; \
	jupyter lab
