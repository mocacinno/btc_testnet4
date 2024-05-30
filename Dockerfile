FROM ubuntu:24.04 AS lightning
RUN apt-get update && \
	apt-get install -y  git build-essential python3 sqlite3 libsqlite3-dev autoconf libtool python3-dev python3-mako gettext  python3-pip jq python3-protobuf python3-grpcio python3-full
RUN git clone https://github.com/ElementsProject/lightning /lightning
WORKDIR /lightning
RUN git fetch --all --tags
RUN git checkout tags/v24.02.2 -b v24.02.2
RUN sed -i '1311,1313d' /lightning/lightningd/chaintopology.c
RUN python3 -m venv ./grpc_tools
RUN ./grpc_tools/bin/pip3 install grpcio-tools
RUN ./configure
RUN make -j "$(($(nproc) + 1))"

FROM ubuntu:24.04 AS miner
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
RUN apt-get update \
  && apt-get install -y \
    build-essential \
    libssl-dev \
    libgmp-dev \
    libcurl4-openssl-dev \
    libjansson-dev \
    automake \
	git \
	zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/JayDDee/cpuminer-opt /cpuminer
WORKDIR /cpuminer
RUN git fetch --all --tags
RUN git checkout tags/v24.3 -b v24.3
RUN ./build.sh


FROM ubuntu:24.04 AS builder
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh

#install all prereqs
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && apt-get -y install git autoconf pkg-config libtool build-essential bsdmainutils libevent-dev  libdb-dev libdb++-dev clang python3 libssl-dev  libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libsqlite3-dev ccache

#pull pr
RUN git clone https://github.com/bitcoin/bitcoin.git /bitcoin
WORKDIR /bitcoin
RUN git fetch origin pull/29775/head:pr-29775 && git checkout pr-29775

#compile
RUN ./autogen.sh
RUN ./configure --with-incompatible-bdb --with-gui=no  CC=clang CXX=clang++
RUN make -j "$(($(nproc) + 1))"
WORKDIR /bitcoin/src
RUN strip bitcoin-util && strip bitcoind && strip bitcoin-cli && strip bitcoin-tx

#multistage
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y libdb5.3++-dev libminiupnpc-dev libevent-dev libzmq3-dev libsqlite3-dev \
	libjansson-dev  libcurl4-openssl-dev python3
	
COPY --from=builder /bitcoin/src/bitcoin-util /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoin-tx /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin
COPY --from=miner /cpuminer/cpuminer /usr/local/bin
COPY --from=lightning /lightning/cli/lightning-cli /usr/local/bin
COPY --from=lightning /lightning/tools/reckless /usr/local/bin
COPY --from=lightning /lightning/lightningd/lightningd /usr/local/bin
COPY --from=lightning /lightning/lightningd/lightning_channeld /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_closingd /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_connectd /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_gossipd /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_hsmd /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_onchaind /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/lightningd/lightning_openingd /usr/local/libexec/c-lightning/
COPY --from=lightning /lightning/plugins /opt/lightningd/plugins
