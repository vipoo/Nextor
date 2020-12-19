# ######################################
#
# Makefile system for building nextor units
# test on ubuntu only
#
# requires at least: bash 4.4, make 4.1
# other prerequisites can be installed using make install-prereq
#
# See README.md in ./linuxtools for more information
#
# #######################################

ifndef BUILD_TYPE
override export BUILD_TYPE = std
endif

export SRC_ROOT_DIR=$(PWD)
export WRK_DIR=../bin/working
KERNEL_WRK_DIR=$(WRK_DIR)/kernel
COMMAND_WRK_DIR=$(WRK_DIR)/command
TOOLS_WRK_DIR=$(WRK_DIR)/tools
BANK0_WRK_DIR=$(KERNEL_WRK_DIR)/bank0
BANK1_WRK_DIR=$(KERNEL_WRK_DIR)/bank1
BANK2_WRK_DIR=$(KERNEL_WRK_DIR)/bank2
BANK3_WRK_DIR=$(KERNEL_WRK_DIR)/bank3
BANK4_WRK_DIR=$(KERNEL_WRK_DIR)/bank4
BANK5_WRK_DIR=$(KERNEL_WRK_DIR)/bank5
BANK6_WRK_DIR=$(KERNEL_WRK_DIR)/bank6
MSXDOS_WRK_DIR=$(COMMAND_WRK_DIR)/msxdos
CMD_WRK_DIR=$(COMMAND_WRK_DIR)/command
CHKDSK_WRK_DIR=$(COMMAND_WRK_DIR)/chkdsk
DRV_SUNRISE_WRK_DIR=$(KERNEL_WRK_DIR)/drivers/sunriseide

SUBMAKE := $(MAKE) -C $(WRK_DIR) --no-print-directory
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
# MAKEFLAGS += -j

export VERSION=2.1.1-alpha2

export PATH := $(PWD)/../linuxtools/:$(PWD)/../linuxtools/prereq/sdcc-4.0.0/bin/:$(PWD)/../linuxtools/prereq/hex2bin/:$(PWD)/../linuxtools/prereq/cpm:$(PATH)


.PHONY: all
all: embedded sunrise hdddsk
	@

PREP := $(shell $(PWD)/../linuxtools/prep.sh > /dev/null; echo "$$?")
ifneq ($(PREP),0)
  $(error prep.sh failed.)
endif

include Makefile-main.mk

## Remove the bin directory
clean:
	rm -rf ../bin

../linuxtools/prereq/sdcc-4.0.0/bin/sz80:
	@mkdir -p ../linuxtools/prereq/
	cd ../linuxtools/prereq
	wget https://sourceforge.net/projects/sdcc/files/sdcc-linux-amd64/4.0.0/sdcc-4.0.0-amd64-unknown-linux2.5.tar.bz2/download -O "sdcc-4.0.0-amd64-unknown-linux2.5.tar.bz2"
	tar -xjf  sdcc-4.0.0-amd64-unknown-linux2.5.tar.bz2
	rm sdcc-4.0.0-amd64-unknown-linux2.5.tar.bz2

../linuxtools/prereq/hex2bin/hex2bin:
	@mkdir -p ../linuxtools/prereq/
	cd ../linuxtools/prereq
	git clone --depth 1 git@github.com:E3V3A/hex2bin.git
	cd hex2bin
	make

../linuxtools/prereq/cpm/cpm:
	@mkdir -p ../linuxtools/prereq/
	cd ../linuxtools/prereq
	git clone --depth 1 git@github.com:jhallen/cpm.git
	cd cpm
	OS=linux MAKEFLAGS= make -B --trace

## Install required tooling (sdcc, hex2bin, cpm) into (linuxtools/prereq)
install-prereq: ../linuxtools/prereq/sdcc-4.0.0/bin/sz80 ../linuxtools/prereq/hex2bin/hex2bin ../linuxtools/prereq/cpm/cpm
	@:

.PHONY: help
## Display this help message
help:
	@printf "Usage\n";
	awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)
