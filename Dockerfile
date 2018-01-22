FROM ubuntu:16.04

RUN \
# Update and get dependencies
    apt-get update && \
    apt-get install -y \
      nano \
      bash \
      lftp \
      wget \
      ca-certificates \
      openssh \
    && \
    
# Add user
    useradd -U -d /config -s /bin/false mediaplayer && \
    usermod -G users mediaplayer && \

# Setup directories
    mkdir -p \
      /data
      /downloads
    && \

# Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    
EXPOSE 12135/tcp 12135/udp
VOLUME /data /downloads

ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

COPY root/ /
