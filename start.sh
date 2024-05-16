#!/bin/bash
if [ -n "$http_proxy" ] && [ -n "$https_proxy" ]; then
    echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/proxy.conf
    echo "Acquire::https::Proxy \"$https_proxy\";" >> /etc/apt/apt.conf.d/proxy.conf
fi
exec "$@"
