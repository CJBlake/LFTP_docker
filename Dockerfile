FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh-server ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -ri 's/^#Port\s+.*/Port 12135/' /etc/ssh/sshd_config

ADD https://raw.githubusercontent.com/CJBlake/feralhosting-freenas_lftp/master/dockerautosetup.sh /automaticsetup.sh
RUN chmod 770 "/automaticsetup.sh"
    
RUN mkdir -p /var/run/sshd
	
EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
