#
# default.mk - Convenient Ledger Makefile
#
# For convenience run:
#   % make -f $PATH_TO_LEDGER_SOURCE/makefiles/$PLATFORM.mk
#
# where $PLATFORM is any of the supported platforms.
# Use the following command to list supported platforms:
#   % make -f $PATH_TO_LEDGER_SOURCE/makefiles.default.mk platforms
#

# Where Ledger will be installed
PREFIX          ?= /usr/local

# The following *_ROOT variables should be changed according to the
# specifics of the respective platform in the platform specific Makefile.
USR             ?= /usr
GMP_ROOT        ?= $(USR)
MPFR_ROOT       ?= $(USR)
BOOST_ROOT      ?= $(USR)
ICU4C_ROOT      ?= $(USR)
LIBINTL_ROOT    ?= $(USR)

# User selectable compile options
PYTHON          ?= OFF
PYTHON_CONFIG   ?= python3-config
PYTHON_VERSION  ?= 3.5
DEBUG           ?= OFF

# Developer options
GCOV            ?= OFF
GPROF           ?= OFF
BUILD           ?= build
GIT_REV         ?= HEAD
MOUNT_POINT     ?= /mnt
CMAKE_GENERATOR ?= 'Unix Makefiles'

# NOTE: GMP_PATH and MPFR_PATH are only for non-refactored CMakeLists.txt builds
CMAKE_FLAGS     ?=-Wdev \
									-DBUILD_DEBUG=$(DEBUG) \
									-DUSE_PYTHON=$(PYTHON) \
									-DBUILD_DOCS=ON \
									-DBUILD_WEB_DOCS=ON \
									-DBUILD_DEV_DOCS=ON \
									\
									-DCLANG_GCOV=$(GCOV) \
									-DCLANG_GPROF=$(GPROF) \
									\
									-DGMP_PATH=$(GMP_ROOT) \
									-DGMP_LIB=$(GMP_ROOT)/lib/libgmp.dylib \
									-DMPFR_PATH=$(MPFR_ROOT) \
									-DMPFR_LIB=$(MPFR_ROOT)/lib/libmpfr.dylib \
									\
									-DGmp_ROOT_DIR=$(GMP_ROOT) \
									-DMpfr_ROOT_DIR=$(MPFR_ROOT) \
									-DIcu_ROOT_DIR=$(ICU4C_ROOT) \
									-DLibintl_ROOT_DIR=$(LIBINTL_ROOT) \
									-DBOOST_ROOT=$(BOOST_ROOT) \
									\
									-DPython_ADDITIONAL_VERSIONS=$(PYTHON_VERSION) \
									-DPYTHON_INCLUDE_DIR=`$(PYTHON_CONFIG) --includes | cut -d' ' -f1 | cut -dI -f2` \
									-DPYTHON_LIBRARY=$(shell $(PYTHON_CONFIG) --prefix)/lib/libpython3.5.dylib \
									\
									-DCMAKE_INSTALL_PREFIX=$(PREFIX)
									#-DBoost_USE_MULTITHREADED=OFF \
									#-DBoost_DEBUG=1 \

# When the argument to the BUILD variable is ramdisk
# a ramdisk is created and the build is placed into the ramdisk.
# The size of the ramdisk can be specified by ramdisk:SIZE
# where SIZE is the number of MB for the ramdisk,
# the default is 256.
ifeq ($(findstring ramdisk,$(BUILD)),ramdisk)
RD_NAME   ?= Ledger_Build
RD_SIZE   := $(subst ramdisk:,,$(BUILD))
ifeq ($(RD_SIZE),ramdisk)
# RD_SIZE is measured in MB
ifeq ($(PYTHON),ON)
RD_SIZE   := 2048
else
RD_SIZE   := 256
endif
endif
BUILD_DIR := $(MOUNT_POINT)/$(RD_NAME)
else
BUILD_DIR := $(BUILD)
endif

ifeq ($(CMAKE_GENERATOR),Ninja)
BUILD_CMD       := ninja -C $(BUILD_DIR)
else
BUILD_CMD       := make -C $(BUILD_DIR)
endif

MAKEFILE  := $(lastword $(MAKEFILE_LIST))
SRCROOT   := $(realpath $(dir $(MAKEFILE)))/..

help: # Print list of available make targets
	@echo Targets in Convenient Ledger Makefile:
	@grep '^[a-z].*#' $(MAKEFILE) | sed -e 's/:.*#[ \t]*/ - /'

platforms: # Print list of available 
	@echo Platforms supported by Convenient Ledger Makefile:
	@ls $(SRCROOT)/makefiles/*.mk | sed -e 's!$(SRCROOT)/makefiles/!!' | cut -d. -f1

all: ledger doc # Build everything

ledger: cmake # Build ledger
	+$(BUILD_CMD)

doc: cmake # Build documentation
	+$(BUILD_CMD) $@

install: all # Install ledger to PREFIX
	+$(BUILD_CMD) $@

cmake: init
	+(cd $(BUILD_DIR); cmake -G$(CMAKE_GENERATOR) $(CMAKE_FLAGS) $(SRCROOT))

package: all # Create a binary distribution archive
	+(cd $(BUILD_DIR); cpack)

archive: init # Create a source distribution archive
	+git archive --prefix=ledger-$(GIT_REV)/ -o $(BUILD_DIR)/ledger-$(GIT_REV).tar.bz2 $(GIT_REV)

coverage: ledger # Build code coverage report
	+$(BUILD_CMD) $@

init: init_ramdisk
	[ -f $(BUILD_DIR) ] || mkdir -p $(BUILD_DIR)

clean: # Clean build directory
	[ -n "$(BUILD_DIR)" ] && rm -rf $(BUILD_DIR)/*

init_ramdisk:
destroy_ramdisk:

.PHONY: init clean ramdisk coverage doc cmake ledger
