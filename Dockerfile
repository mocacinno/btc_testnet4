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
