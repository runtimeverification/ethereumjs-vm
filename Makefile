
.PHONY: deps ganache erc20 start-vm stop-vm test-openzeppelin

# Settings
# --------

ganache:
	npm install -g yarn
	git submodule update --init --recursive -- $(GANACHE_CORE_SUBMODULE) $(GANACHE_CLI_SUBMODULE)
	yarn install --non-interactive
	yarn link
	yarn run build:dist
	cd $(GANACHE_CORE_SUBMODULE)  \
		&& yarn link kevm-ethereumjs-vm \
		&& yarn install --non-interactive \
		&& yarn link \
		&& yarn run build
	cd $(GANACHE_CLI_SUBMODULE)  \
		&& yarn link kevm-ganache-core \
		&& yarn install --non-interactive
	cd $(GANACHE_CLI_SUBMODULE) \
		&& yarn run build

truffle:
	npm install -g truffle

deps:
	git submodule update --init --recursive

CLIARGS?=

start-vm:
	node ./deps/ganache-cli/cli.js $(CLIARGS) &

stop-vm:
	pkill node

test-openzeppelin:
	cd ./deps/openzeppelin-solidity \
		&& truffle test

