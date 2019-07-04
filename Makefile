
.PHONY: clean distclean deps \
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

node-prerequisites:
	sudo apt-get install nodejs

deps:
	node-prerequisites
	git submodule update --init --recursive
	$(KEVM_MAKE) deps llvm-deps
	$(KEVM_MAKE) split-tests
	cd $(KEVM_DEPS)/k && mvn package -DskipTests -U -Dhaskell.backend.skip

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
