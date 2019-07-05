
.PHONY: clean distclean deps ganache erc20 \
        start-node start-ganache start-truffle-test

# Settings
# --------

ANALYSIS_BACKEND=ocaml
MAIN_MODULE:=KEVM-ANALYSIS
MAIN_DEFN_FILE:=kevm-analysis

DEPS_DIR:=deps
DEFN_DIR:=$(BUILD_DIR)/defn
KEVM_SUBMODULE:=$(DEPS_DIR)/evm-semantics
KEVM_DEPS:=$(KEVM_SUBMODULE)/deps
BUILD_DIR:=.build
K_RELEASE:=$(KEVM_SUBMODULE)/deps/k/k-distribution/target/release/k
K_BIN:=$(K_RELEASE)/bin
K_LIB:=$(K_RELEASE)/lib
KEVM_DIR:=.
KEVM_MAKE:=make --directory $(KEVM_SUBMODULE) BUILD_DIR=$(BUILD_DIR)

export K_RELEASE
export KEVM_DIR

PANDOC_TANGLE_SUBMODULE:=$(KEVM_SUBMODULE)/deps/pandoc-tangle
TANGLER:=$(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH:=$(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export TANGLER
export LUA_PATH

clean:
	rm -rf $(DEFN_DIR)

distclean: clean
	rm -rf $(BUILD_DIR)

ganache:
	npm install
	protoc --js_out=import_style=commonjs,binary:. lib/proto/msg.proto 
	npm run build:dist 
	sudo npm link 
	cd deps/ganache-core && \
	npm install && \
	npm link ethereumjs-vm && \
	npm run build && \
	sudo npm link
	cd deps/ganache-cli && \
	npm install && \
	npm link ganache-core && \
	npm run build

erc20:
	cd deps/openzeppelin-solidity && \
	wget https://gist.githubusercontent.com/anvacaru/24a09c588e9590dad296200c1a9c86a5/raw/be243b1d461fb9ba9a74679a2459d0fd3b9417e0/totalSupply.js && \
	npm install

deps:
	git submodule update --init --recursive
	$(KEVM_MAKE) llvm-deps

# Regular Semantics Build
# -----------------------

build-kevm-%:
	$(KEVM_MAKE) build-$*

start-node:
	$(KEVM_SUBMODULE)/.build/defn/vm/kevm-vm 8080 127.0.0.1 &

start-ganache:
	node ./deps/ganache-cli/cli.js &

start-truffle-test:
	cd deps/openzeppelin-solidity && \
	node node_modules/.bin/truffle test totalSupply.js