#
# homebrew.mk - Convenient Ledger Makefile for Mac OS X Homebrew
#

# Where Ledger will be installed
PREFIX          := $(shell brew --cellar ledger)/HEAD

# User selectable compile options
PYTHON          := OFF
DEBUG           := OFF
EMACS_LISP      := OFF

# Specify location of ledger dependencies
HOMEBREW_PREFIX := $(shell brew --prefix)
BOOST_ROOT      := $(HOMEBREW_PREFIX)
GMP_ROOT        := $(HOMEBREW_PREFIX)
MPFR_ROOT       := $(HOMEBREW_PREFIX)
ICU4C_ROOT      := $(shell brew --prefix icu4c)
LIBINTL_ROOT    := $(shell brew --prefix gettext)

# Developer options
MOUNT_POINT     := /Volumes

include $(dir $(lastword $(MAKEFILE_LIST)))/default.mk

init_ramdisk:
	[ -z "$(RD_SIZE)" ] || RD_DEV=`diskutil info "$(RD_NAME)" | grep 'Device Node' | cut -d: -f2 | tr -d ' '` ; \
		[ -z "$(RD_SIZE)" -o -b "$$RD_DEV" ] || diskutil erasevolume HFS+ "$(RD_NAME)" `hdiutil attach -nomount ram://$$(expr $(RD_SIZE) '*' 2048)`
	[ -z "$(RD_NAME)" -a ! -f ramdisk ] || ln -sf $(MOUNT_POINT)/$(RD_NAME) ramdisk

destroy_ramdisk:
	[ -z "$(RD_SIZE)" ] || RD_DEV=`diskutil list "$(RD_NAME)" | head -1` ; \
		diskutil eject "$(RD_NAME)"


# It allows you to quickly get the value of any makefile variable. For example,
# suppose you want to know the value of a variable called SOURCE_FILES. You'd
# just type: % make print-SOURCE_FILES
# -- http://blog.jgc.org/2015/04/the-one-line-you-should-add-to-every.html
print-%: ; @echo $*=$($*)


