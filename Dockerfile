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
COPY --from=builder /usr/lib64/libcurl.so.4 /usr/lib64/libcurl.so.4
COPY --from=builder /usr/lib64/libnghttp2.so.14 /usr/lib64/libnghttp2.so.14
COPY --from=builder /usr/lib64/libidn2.so.0 /usr/lib64/libidn2.so.0
COPY --from=builder /usr/lib64/libssh.so.4 /usr/lib64/libssh.so.4
COPY --from=builder /usr/lib64/libpsl.so.5 /usr/lib64/libpsl.so.5 
COPY --from=builder /usr/lib64/libssl.so.3 /usr/lib64/libssl.so.3  
COPY --from=builder /usr/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3
COPY --from=builder /usr/lib64/libgssapi_krb5.so.2 /usr/lib64/libgssapi_krb5.so.2
COPY --from=builder /usr/lib64/libldap_r-2.4.so.2 /usr/lib64/libldap_r-2.4.so.2
COPY --from=builder /usr/lib64/liblber-2.4.so.2 /usr/lib64/liblber-2.4.so.2
COPY --from=builder /usr/lib64/libzstd.so.1 /usr/lib64/libzstd.so.1
COPY --from=builder /usr/lib64/libbrotlidec.so.1 /usr/lib64/libbrotlidec.so.1
COPY --from=builder /usr/lib64/libunistring.so.2 /usr/lib64/libunistring.so.2
COPY --from=builder /usr/lib64/libkrb5.so.3 /usr/lib64/libkrb5.so.3
COPY --from=builder /usr/lib64/libk5crypto.so.3 /usr/lib64/libk5crypto.so.3
COPY --from=builder /lib64/libcom_err.so.2 /lib64/libcom_err.so.2
COPY --from=builder /usr/lib64/libkrb5support.so.0 /usr/lib64/libkrb5support.so.0
COPY --from=builder /usr/lib64/libsasl2.so.3 /usr/lib64/libsasl2.so.3
COPY --from=builder /usr/lib64/libbrotlicommon.so.1 /usr/lib64/libbrotlicommon.so.1
COPY --from=builder /usr/lib64/libkeyutils.so.1 /usr/lib64/libkeyutils.so.1
COPY --from=builder /lib64/libresolv.so.2 /lib64/libresolv.so.2
COPY --from=builder /usr/lib64/libselinux.so.1 /usr/lib64/libselinux.so.1
