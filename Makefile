
.PHONY: deps ganache erc20

# Settings
# --------

DEPS_DIR:=deps

GANACHE_CORE_SUBMODULE:=$(DEPS_DIR)/ganache-core
GANACHE_CLI_SUBMODULE :=$(DEPS_DIR)/ganache-cli

ganache:
	git submodule update --init --recursive -- $(GANACHE_CORE_SUBMODULE) $(GANACHE_CLI_SUBMODULE)
	yarn install --non-interactive
	yarn link
	yarn run build:dist
	cd $(GANACHE_CORE_SUBMODULE)          \
	    && yarn link kevm-ethereumjs-vm   \
	    && yarn install --non-interactive \
	    && yarn link                      \
	    && yarn run build
	cd $(GANACHE_CLI_SUBMODULE)           \
	    && yarn link kevm-ganache-core    \
	    && yarn install --non-interactive
	cd $(GANACHE_CLI_SUBMODULE) \
	    && yarn run build

deps:
	git submodule update --init --recursive
