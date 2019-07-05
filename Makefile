
.PHONY: clean distclean deps ganache erc20 rust\
        test-execute

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
	npm install && \
	protoc --js_out=import_style=commonjs,binary:. lib/proto/msg.proto && \
	npm run build:dist && \
	sudo npm link && \
	cd deps/ganache-core && \
	npm install && \
	npm link ethereumjs-vm && \
	npm run build && \
	sudo npm link && \
	cd ../ganache-cli && \
	wget https://gist.githubusercontent.com/anvacaru/24a09c588e9590dad296200c1a9c86a5/raw/be243b1d461fb9ba9a74679a2459d0fd3b9417e0/totalSupply.js && \
	npm install && \
	npm link ganache-core && \
	npm run build && \
	cd ../..

erc20:
	cd deps/openzeppelin-solidity && \
	npm install && \
	cd ../..

deps:
	git submodule update --init --recursive
	$(KEVM_MAKE) deps llvm-deps
	cd $(KEVM_DEPS)/k && mvn package -DskipTests -U -Dhaskell.backend.skip

rust:
	cd $(KEVM_SUBMODULE) && \
	./deps/k/llvm-backend/src/main/native/llvm-backend/install-rust && \
	cd ../..
# Regular Semantics Build
# -----------------------

build-kevm-%:
	$(KEVM_MAKE) build-$*

# AOP Analysis Build
# ------------------

build-analysis-%: $(DEFN_DIR)/%/kevm-analysis.k
	$(KEVM_MAKE) build-$* MAIN_DEFN_FILE=kevm-analysis MAIN_MODULE=KEVM-ANALYSIS

$(DEFN_DIR)/%/kevm-analysis.k: kevm-analysis.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:'.k' $< > $@

# Tests
# =====

execute_tests:=$(wildcard $(KEVM_SUBMODULE)/tests/ethereum-tests/VMTests/vmArithmeticTest/*.json)

test-execute: $(execute_tests:=.test-execute)

%.test-execute:
	MODE=VMTESTS SCHEDULE=DEFAULT ./kevma EXECUTE $* > $*.out || true
	git --no-pager diff --no-index tests/output/success.out $*.out
