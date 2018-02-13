FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh-server ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -ri 's/^#Port\s+.*/Port 12135/' /etc/ssh/sshd_config

RUN mkdir -p /var/run/sshd

COPY autosetup.sh /usr/local/bin/

RUN chmod 770 "/usr/local/bin/autosetup.sh"

EXPOSE 22
ENTRYPOINT ["autosetup.sh"]
CMD    ["/usr/sbin/sshd", "-D"]
