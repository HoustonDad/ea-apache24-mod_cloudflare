#-------------------------------------------------------------------------------------
#
# Start Configuration
#
#-------------------------------------------------------------------------------------

# the upstream project
OBS_PROJECT := Jperkster

# the package name in OBS
OBS_PACKAGE := ea-apache24-mod_cloudflare

#-------------------------------------------------------------------------------------
#
# End Configuration
#
#-------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------
#
# TODO
#
#-------------------------------------------------------------------------------------
# - Cleaning the OBS target when files are removed from git
# - Add a obs_dependencies target to rebuild the package and all of it's dependencies
# - Create a devel RPM that contains all of these Makefile stubs.  This way it's
#   in one place, instead of being copied everywhere.
#
#

#-------------------
# Variables
#-------------------

# allow override
ifndef $(ARCH)
ARCH := $(shell uname -m)
endif

ERRMSG := "Please read, https://cpanel.wiki/display/AL/Setting+up+yourself+for+using+OBS"
OBS_USERNAME := $(shell grep -A5 '[https://api.opensuse.org]' ~/.oscrc | awk -F= '/user=/ {print $$2}')

# NOTE: OBS only like ascii alpha-numeric characters
GIT_BRANCH := $(shell git branch | awk '/^*/ { print $$2 }' | sed -e 's/[^a-z0-9]/_/ig')
ifdef bamboo_repository_git_branch
GIT_BRANCH := $(bamboo_repository_git_branch)
endif

# if we're pushing to master, push to the upstream project
ifeq ($(bamboo_repository_git_branch),master)
BUILD_TARGET := $(OBS_PROJECT)
else
BUILD_TARGET := home$(OBS_USERNAME):$(OBS_PROJECT):$(GIT_BRANCH)
endif
# OBS does not support / in branch names
$(substr /,-,BUILD_TARGET)


OBS_WORKDIR := $(BUILD_TARGET)/$(OBS_PACKAGE)

.PHONY: all clean local vars chroot obs check build-clean build-init

#-----------------------
# Primary make targets
#-----------------------

all: local

clean: build-clean

# Builds the RPM on your local machine using the OBS infrstructure.
# This is useful to test before submitting to OBS.
#
# For example, if you wanted to build PHP without running tests:
#	OSC_BUILD_OPTS='--define="runselftest 0"' make local
local: check
	make build-init
	cd OBS/$(OBS_WORKDIR) && osc build $(OSC_BUILD_OPTS) --clean --noverify --disable-debuginfo
	make build-clean

# Commits local file changes to OBS, and ensures a build is performed.
obs: check
	make build-init
	cd OBS/$(OBS_WORKDIR) && osc addremove -r 2> /dev/null || exit 0
	cd OBS/$(OBS_WORKDIR) && osc ci -m "Makefile check-in - date($(shell date)) branch($(GIT_BRANCH))"
	make build-clean

# This allows you to debug your build if it fails by logging into the
# build environment and letting you manually run commands.
chroot: check
	make build-init
	cd OBS/$(OBS_WORKDIR) && osc chroot --local-package -o CentOS_6.5_standard $(ARCH) $(OBS_PACKAGE)
	make build-clean

# Debug target: Prints out variables to ensure they're correct
vars: check
	@echo "ARCH: $(ARCH)"
	@echo "OBS_USERNAME: $(OBS_USERNAME)"
	@echo "GIT_BRANCH: $(GIT_BRANCH)"
	@echo "BUILD_TARGET: $(BUILD_TARGET)"
	@echo "OBS_WORKDIR: $(OBS_WORKDIR)"
	@echo "OBS_PROJECT: $(OBS_PROJECT)"
	@echo "OBS_PACKAGE: $(OBS_PACKAGE)"

#-----------------------
# Helper make targets
#-----------------------

build-init: build-clean
	mkdir OBS
	osc branch $(OBS_PROJECT) $(OBS_PACKAGE) $(BUILD_TARGET) $(OBS_PACKAGE) 2>/dev/null || exit 0
	cd OBS && osc co $(BUILD_TARGET)
	mv OBS/$(OBS_WORKDIR)/.osc OBS/.osc.proj.$$ && rm -rf OBS/$(OBS_WORKDIR)/* && cp --remove-destination -pr SOURCES/* SPECS/* OBS/$(OBS_WORKDIR) && mv OBS/.osc.proj.$$ OBS/$(OBS_WORKDIR)/.osc

build-clean:
	rm -rf OBS

check:
	@[ -e ~/.oscrc ] || make errmsg
	@[ -x /usr/bin/osc ] || make errmsg
	@[ -x /usr/bin/build ] || make errmsg
	@[ -d .git ] || ERRMSG="This isn't a git repository." make -e errmsg
	@[ -n "$(ARCH)" ] || ERRMSG="Unable to determine host architecture type using ARCH environment variable" make -e errmsg

errmsg:
	@echo -e "\nERROR: You haven't set up OBS correctly on your machine.\n $(ERRMSG)\n"
	@exit 1
