FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ENV ROOT_PASSWORD="D7zn3juLQ82ySze1Ibyn"

RUN apt-get update && \
    apt-get -y --no-install-recommends install nano bash lftp wget openssh-server ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'root:"${ROOT_PASSWORD}"' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
    
RUN mkdir -p /var/run/sshd
	
EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
