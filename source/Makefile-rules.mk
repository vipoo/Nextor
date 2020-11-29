
SHELL := /bin/bash
.DELETE_ON_ERROR:
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

%.rel: %.mac version.inc condasm.inc
	@echo -e "\nAssembling \e[32m$<\e[0m"
	cd $(BLDDIR)
	m80.sh $(notdir $<) "$@" 2>&1 | grep -v "Sorry, terminal not found, using cooked mode."

%.rel: %.s
	@cd $(BLDDIR)
	sdasz80 -o $(notdir $@) $(notdir $<)

%.com: %.hex
	@cd $(BLDDIR)
	hex2bin -s 100 $(notdir $<)
	mv $(notdir $(basename $<)).bin $(notdir $(basename $<)).com

version.inc: $(SRC_ROOT_DIR)/kernel/condasm/version.inc
	@cd $(BLDDIR)
	ln -sf "$(SRC_ROOT_DIR)/kernel/condasm/version.inc" ./version.inc

