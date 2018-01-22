FROM debian:jessie

RUN apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh-server ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
    
  ENTRYPOINT /bin/bash
