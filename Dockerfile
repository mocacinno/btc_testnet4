FROM registry.suse.com/bci/bci-base:15.6 AS builder
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
#RUN zypper ref -s && zypper --non-interactive install git python3 awk gcc-c++ sqlite3-devel python3-importlib_resources && zypper --non-interactive install -t pattern devel_basis
RUN zypper ref -s && zypper --non-interactive install git python311 awk gcc-c++ sqlite3-devel python311-importlib_resources jq python311-pip python311-Mako && zypper --non-interactive install -t pattern devel_basis
RUN git clone https://github.com/ElementsProject/lightning /lightning
WORKDIR /lightning
RUN git fetch --all --tags
#RUN git checkout tags/v24.05 -b v24.05
#RUN sed -i '1294,1296d' /lightning/lightningd/chaintopology.c
#RUN python3.11 -m venv ./grpc_tools
#ENV PATH="/lightning/grpc_tools/bin:$PATH"
#RUN pip install grpcio-tools mako importlib
RUN git checkout tags/v24.02.2 -b v24.02.2
RUN git submodule update --init --recursive
RUN sed -i '1311,1313d' /lightning/lightningd/chaintopology.c
RUN ln -s /usr/bin/python3.11 /usr/bin/python
RUN ln -s /usr/bin/python3.11 /usr/bin/python3
RUN pip install grpcio
RUN pip install grpcio-tools
RUN ./configure && make -j "$(($(nproc) + 1))"

FROM registry.suse.com/bci/bci-base:15.6 AS node
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
RUN zypper ref -s && zypper --non-interactive install git gcc13-c++ wget libevent-devel awk gcc-c++ && zypper --non-interactive install -t pattern devel_basis
RUN wget https://archives.boost.io/release/1.85.0/source/boost_1_85_0.tar.gz
RUN tar -xvf boost_1_85_0.tar.gz
ENV BOOST_ROOT=/boost_1_85_0
WORKDIR /boost_1_85_0
RUN chmod +x bootstrap.sh && ./bootstrap.sh && ./b2 || ./b2 headers
RUN git clone https://github.com/bitcoin/bitcoin.git /bitcoin
WORKDIR /bitcoin
RUN git fetch origin pull/29775/head:pr-29775 && git checkout pr-29775
RUN ./autogen.sh
RUN ./configure --with-incompatible-bdb --with-gui=no CXX=g++-13
RUN make -j "$(($(nproc) + 1))"
WORKDIR /bitcoin/src
RUN strip bitcoin-util && strip bitcoind && strip bitcoin-cli && strip bitcoin-tx



FROM registry.suse.com/bci/bci-minimal:15.6
COPY --from=builder /lightning/cli/lightning-cli /usr/local/bin
COPY --from=builder /lightning/tools/reckless /usr/local/bin
COPY --from=builder /lightning/lightningd/lightningd /usr/local/bin
COPY --from=builder /lightning/lightningd/lightning_channeld /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_closingd /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_connectd /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_gossipd /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_hsmd /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_onchaind /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/lightningd/lightning_openingd /usr/local/libexec/c-lightning/
COPY --from=builder /lightning/plugins /opt/lightningd/plugins
COPY --from=builder /usr/lib64/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0

COPY --from=node /bitcoin/src/bitcoin-util /usr/local/bin
COPY --from=node /bitcoin/src/bitcoin-cli /usr/local/bin
COPY --from=node /bitcoin/src/bitcoin-tx /usr/local/bin
COPY --from=node /bitcoin/src/bitcoind /usr/local/bin
COPY --from=node /usr/lib64/libevent_pthreads-2.1.so.7 /usr/lib64/
COPY --from=node /usr/lib64/libevent-2.1.so.7 /usr/lib64/
