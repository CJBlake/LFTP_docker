FROM alpine:latest

RUN apk --update add nano bash lftp wget ca-certificates openssh \
    \
    # clean up cached artefacts
    && rm -rf /var/cache/apk/*
