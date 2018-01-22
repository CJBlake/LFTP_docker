FROM alpine:latest

RUN apk add --no-cache \
		nano \ 
		bash \
		lftp \
		wget \
		ca-certificates \
		openssh 
		openssh-client 
	
CMD bash