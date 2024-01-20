
TOP = $(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))

MPY_CROSS ?= $(HOME)/micropython/micropython/mpy-cross/mpy-cross

PYTHON_FILES = $(shell find . -name '*.py' -not -path  './.direnv/*' -not -path './microdot/*' -not -path './utemplate/*' -not -path '*/templates/*')

MICRODOT_REPO = submodules/microdot
MICRODOT_SRC = $(MICRODOT_REPO)/src/microdot
UTEMPLATE_SRC = $(MICRODOT_REPO)/libs/common/utemplate

MICRODOT_DST = microdot
UTEMPLATE_DST = utemplate

MICRODOT_UPY = upy/microdot
UTEMPLATE_UPY = upy/utemplate

MICRODOT_FILES = __init__.py microdot.py utemplate.py websocket.py
UTEMPLATE_FILES = compiled.py recompile.py source.py

MICRODOT_DST_FILES = $(addprefix $(MICRODOT_DST)/, $(MICRODOT_FILES))
UTEMPLATE_DST_FILES = $(addprefix $(UTEMPLATE_DST)/, $(UTEMPLATE_FILES))

MICRODOT_UPY_FILES = $(addprefix $(MICRODOT_UPY)/, $(MICRODOT_FILES:.py=.mpy))
UTEMPLATE_UPY_FILES = $(addprefix $(UTEMPLATE_UPY)/, $(UTEMPLATE_FILES:.py=.mpy))

APP_FILES = $(wildcard app/*.py) $(wildcard app/static/*) $(wildcard app/templates/*.html)

UPY_EXTRA_FILES = wifi.mpy wifi_config.mpy wobble_upy.mpy
UPY_FILES = $(addprefix upy/, $(UPY_EXTRA_FILES) $(APP_FILES)) $(MICRODOT_UPY_FILES) $(UTEMPLATE_UPY_FILES)
UPY_FILES := $(UPY_FILES:.py=.mpy)

UPY_DIRS = $(sort $(dir $(UPY_FILES)))

run:
	./run.sh

sync: sync-microdot sync-utemplate $(UPY_FILES)

sync-microdot: $(MICRODOT_DST_FILES)

sync-utemplate: $(UTEMPLATE_DST_FILES)

# We add $(UPY_DIRS) so that there is something more specific that upy/%
%/:
	@echo "Creating directory $@"
	@mkdir -p $@

#microdot/ utemplate/ upy/:
#	@echo "Creating directory $@"
#	@mkdir -p $@

upy/%: %
	@if [ -d "$<" ]; then \
		echo "Creating x directory $@"; \
		mkdir -p $@; \
	else \
		echo "Copying $< to $@"; \
		cp $< $@; \
	fi

upy/%.mpy: %.py
	@echo "Compiling $<"
	@$(MPY_CROSS) -o $@ $<

$(MICRODOT_DST_FILES) : microdot/
$(MICRODOT_DST_FILES) : $(MICRODOT_DST)/%: $(MICRODOT_SRC)/%
	@echo "Copying $< to $@"
	@cp $< $@

$(UTEMPLATE_DST_FILES): utemplate/
$(UTEMPLATE_DST)/%: $(UTEMPLATE_SRC)/%
	@echo "Copying $< to $@"
	@cp $< $@

$(UPY_FILES): | $(UPY_DIRS)

deploy: $(UPY_FILES)
	rshell rsync upy/ /pyboard/

style:
	yapf -i $(PYTHON_FILES)

lint:
	pylint $(PYTHON_FILES)

make-pylintrc:
	pylint --generate-rcfile > .pylintrc

requirements:
	pip3 install -r requirements.txt

clean: clean-upy clean-microdot clean-utemplate

clean-upy:
	rm -rf upy

clean-microdot:
	rm -rf $(MICRODOT_DST)

clean-utemplate:
	rm -rf $(UTEMPLATE_DST)
