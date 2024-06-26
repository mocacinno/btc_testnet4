FROM registry.suse.com/bci/bci-base:15.6 AS builder
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
RUN zypper ref -s && zypper --non-interactive install git wget awk gcc13-c++ && zypper --non-interactive install -t pattern devel_basis
RUN wget https://download.opensuse.org/repositories/devel:/tools:/building/15.6/noarch/autoconf-2.72-80.d_t_b.1.noarch.rpm
#rpm --import http://example.com/path/to/keyfile
RUN zypper --non-interactive --no-gpg-checks install autoconf-2.72-80.d_t_b.1.noarch.rpm
RUN git clone https://bitbucket.org/ckolivas/ckpool.git /ckpool
WORKDIR /ckpool
#RUN git fetch --all --tags
RUN ./autogen.sh && CC=gcc-13 CXX=g++-13 CXXFLAGS="-std=c++17" ./configure && make -j "$(($(nproc) + 1))"

FROM registry.suse.com/bci/bci-minimal:15.6
COPY --from=builder /ckpool/src/ckpool /usr/local/bin
COPY ckpool.conf /ckpool.conf
