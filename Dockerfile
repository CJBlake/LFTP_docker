FROM debian:jessie

apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
    
# Add user
    useradd -U -d /config -s /bin/false mediaplayer && \
    usermod -G users mediaplayer && \

# Setup directories
    mkdir -p \
      /data
      /downloads
    && \

EXPOSE 12135/tcp 12135/udp
VOLUME ["/data", "/downloads"]

