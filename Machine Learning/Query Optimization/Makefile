default: test

all: clean init test

venv/bin/activate:
	rm -rf venv/
	python3 -m venv venv

.PHONY: clean
clean:
	rm -rf venv/

.PHONY: init
init: venv/bin/activate
	. venv/bin/activate ; \
	pip install -r requirements.txt

.PHONY: test
test: venv/bin/activate
	. venv/bin/activate ; \
	python3 -m unittest discover -s tests

.PHONY: jupyter
jupyter: venv/bin/activate
	. venv/bin/activate ; \
	jupyter lab
