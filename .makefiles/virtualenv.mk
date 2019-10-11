# Provides a dependecy, `virtualenv`, which creates a local virtualenv for use
# during development of a python project.
PYTHON_VERSION   ?=
VIRTUALENV_DIR   ?= .env
PIP_INDEX_URL    ?=
PIP_REQUIREMENTS ?= requirements.txt

PYTHON := python$(PYTHON_VERSION)
PIP    := $(VIRTUALENV_DIR)/bin/pip
PIP_INDEX_FLAG := $(if $(PIP_INDEX_URL),--index-url $(PIP_INDEX_URL))

$(VIRTUALENV_DIR): | _program_$(PYTHON) _program_virtualenv
	${call log,creating virtualenv at $(VIRTUALENV_DIR)}
	virtualenv --python=$(PYTHON) $(VIRTUALENV_DIR)

$(PIP): $(PIP_REQUIREMENTS) | $(VIRTUALENV_DIR)
	${call log,install python dependencies from $(PIP_REQUIREMENTS)}
	$(PIP) install $(PIP_INDEX_FLAG) --upgrade pip setuptools
	$(PIP) install $(PIP_INDEX_FLAG) --upgrade -r $(PIP_REQUIREMENTS)
	@touch $(PIP)

#> installs python dependencies
virtualenv:: $(PIP)
.PHONY: virtualenv

clean::
	rm -rf $(VIRTUALENV_DIR)
.PHONY: clean
