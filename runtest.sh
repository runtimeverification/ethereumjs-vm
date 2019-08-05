#!/bin/bash
set -euo pipefail

REPOURL=$1
REPONAME=$(echo $REPOURL | grep -o "[^/]*.git$" | sed 's/.git//')
COMMIT=$2
CLIARGS=${@:3}

npx kevm-ganache-cli $CLIARGS &
sleep 2

git clone $REPOURL
pushd $REPONAME
git checkout $COMMIT
npm install
npx truffle test
popd

rm -rf $REPONAME
pkill node
pkill kevm-vm || true
