FROM registry.suse.com/bci/bci-base:15.6 AS builder
#start.sh sets proxy for apt, needed for my env
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN /usr/local/bin/start.sh
RUN zypper ref -s && zypper --non-interactive install git awk libcurl-devel gcc-c++ gmp-devel && zypper --non-interactive install -t pattern devel_basis
RUN git clone https://github.com/JayDDee/cpuminer-opt /cpuminer
WORKDIR /cpuminer
RUN git fetch --all --tags
RUN git checkout tags/v24.3 -b v24.3
RUN ./build.sh

FROM registry.suse.com/bci/bci-minimal:15.6
COPY --from=builder /cpuminer/cpuminer /usr/local/bin
