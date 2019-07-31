FROM ubuntu:bionic

ENV TZ=America/Chicago
RUN    ln --symbolic --no-dereference --force /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN    apt-get update                                                                 \
    && apt-get upgrade --yes                                                          \
    && apt-get install --yes                                                          \
        autoconf bison clang-6.0 cmake curl flex gcc libboost-test-dev            \
        libcrypto++-dev libffi-dev libjemalloc-dev libmpfr-dev libprocps-dev      \
        libsecp256k1-dev libssl1.0-dev libtool libyaml-dev lld-6.0 llvm-6.0-tools \
        make maven opam openjdk-8-jdk pandoc pkg-config   \
        python3 python-pygments python-recommonmark python-sphinx time zlib1g-dev \
        protobuf-compiler libprotobuf-dev jq

RUN jq_query='[.[] | select(any(.tag_name; test("^v1.0.0-*")))][0]'  # select released tags \
    && jq_query="$jq_query"' | .assets[]'                               # browse packages \
    && jq_query="$jq_query"' | select(any(.label; test("Ubuntu *")))'   # select Debian package \
    && jq_query="$jq_query"' | .browser_download_url'                   # get download url \
    && release_url="$(curl 'https://api.github.com/repos/kframework/evm-semantics/releases' | jq --raw-output "$jq_query")" \
    && curl --location "$release_url" --output kevm_1.0.0_amd64.deb \
    && apt install --yes ./kevm_1.0.0_amd64.deb

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get install --yes nodejs

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN    groupadd --gid $GROUP_ID user                                        \
    && useradd --create-home --uid $USER_ID --shell /bin/sh --gid user user

USER $USER_ID:$GROUP_ID

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PATH=/home/user/.local/bin:/home/user/.cargo/bin:$PATH

ENV NPM_PACKAGES=/home/user/.npm-packages
ENV PATH=$NPM_PACKAGES/bin:$PATH
RUN npm config set prefix $NPM_PACKAGES