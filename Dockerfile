FROM registry.suse.com/bci/bci-base:15.6 AS builder
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
RUN zypper ref -s && zypper --non-interactive install git gcc13-c++ wget libevent-devel awk gcc-c++ libdb-4_8-devel && zypper --non-interactive install -t pattern devel_basis
RUN wget https://archives.boost.io/release/1.85.0/source/boost_1_85_0.tar.gz
RUN tar -xvf boost_1_85_0.tar.gz
ENV BOOST_ROOT=/boost_1_85_0
WORKDIR /boost_1_85_0
RUN chmod +x bootstrap.sh && ./bootstrap.sh && ./b2 || ./b2 headers
RUN git clone https://github.com/bitcoin/bitcoin.git /bitcoin
WORKDIR /bitcoin
RUN git fetch origin pull/29775/head:pr-29775 && git checkout pr-29775
RUN ./autogen.sh
RUN ./configure --with-incompatible-bdb --with-gui=no --enable-wallet CXX=g++-13
RUN make -j "$(($(nproc) + 1))"
WORKDIR /bitcoin/src
RUN strip bitcoin-util && strip bitcoind && strip bitcoin-cli && strip bitcoin-tx

FROM registry.suse.com/bci/bci-minimal:15.6
COPY --from=builder /bitcoin/src/bitcoin-util /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoin-tx /usr/local/bin
COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin
COPY --from=builder /usr/lib64/libevent_pthreads-2.1.so.7 /usr/lib64/
COPY --from=builder /usr/lib64/libevent-2.1.so.7 /usr/lib64/
