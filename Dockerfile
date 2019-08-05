FROM runtimeverificationinc/ubuntu:bionic

ENV TZ=America/Chicago

RUN    apt-get update                                                         \
    && apt-get upgrade --yes                                                  \
    && apt-get install --yes                                                  \
        autoconf bison clang-8 cmake curl flex gcc libboost-test-dev          \
        libcrypto++-dev libffi-dev libjemalloc-dev libmpfr-dev libprocps-dev  \
        libprotobuf-dev libsecp256k1-dev libssl-dev libtool libyaml-dev lld-8 \
        llvm-8-tools make maven opam openjdk-11-jdk pandoc pkg-config         \
        protobuf-compiler python3 python-pygments python-recommonmark         \
        python-sphinx time zlib1g-dev jq

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install --yes nodejs
RUN npm install -g npx yarn

USER user:user

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PATH=/home/user/.local/bin:/home/user/.cargo/bin:$PATH

ENV NPM_PACKAGES=/home/user/.npm-packages
ENV PATH=$NPM_PACKAGES/bin:$PATH
RUN npm config set prefix $NPM_PACKAGES
