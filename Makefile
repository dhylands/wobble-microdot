
TOP = $(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))

PYTHON_FILES = $(shell find . -name '*.py' -not -path  './.direnv/*' -not -path './microdot/*' -not -path './utemplate/*' -not -path '*/templates/*')

MICRODOT_REPO = $(TOP)/submodules/microdot
MICRODOT_SRC = $(MICRODOT_REPO)/src/microdot
UTEMPLATE_SRC = $(MICRODOT_REPO)/libs/common/utemplate

MICRODOT_DST = $(TOP)/microdot
UTEMPLATE_DST = $(TOP)/utemplate

MICRODOT_FILES = __init__.py microdot.py utemplate.py websocket.py
UTEMPLATE_FILES = compiled.py recompile.py source.py

MICRODOT_DST_FILES = $(addprefix $(MICRODOT_DST)/, $(MICRODOT_FILES))
UTEMPLATE_DST_FILES = $(addprefix $(UTEMPLATE_DST)/, $(UTEMPLATE_FILES))

run:
	./run.sh

sync: sync-microdot sync-utemplate

sync-microdot: $(MICRODOT_DST_FILES)

sync-utemplate: $(UTEMPLATE_DST_FILES)

$(MICRODOT_DST) $(UTEMPLATE_DST):
	mkdir -p $@

$(MICRODOT_DST)/%: $(MICRODOT_SRC)/% | $(MICRODOT_DST)
	@echo "Copying $< to $@"
	@cp $< $@

$(UTEMPLATE_DST)/%: $(UTEMPLATE_SRC)/% | $(UTEMPLATE_DST)
	@echo "Copying $< to $@"
	@cp $< $@

style:
	yapf -i $(PYTHON_FILES)

lint:
	pylint $(PYTHON_FILES)

make-pylintrc:
	pylint --generate-rcfile > .pylintrc

requirements:
	pip3 install -r requirements.txt

clean: clean-microdot clean-utemplate

clean-microdot:
	rm -rf $(MICRODOT_DST)

clean-utemplate:
	rm -rf $(UTEMPLATE_DST)