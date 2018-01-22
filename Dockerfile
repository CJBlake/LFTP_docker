FROM alpine:latest

RUN apk add --no-cache \
		nano \ 
		bash \
		lftp \
		wget \
		ca-certificates \
		openssh 
    \
    # clean up cached artefacts
    && rm -rf /var/cache/apk/*
