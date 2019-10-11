FROM node:8-alpine

USER root

ENV USER root

RUN apk add --no-cache python2 g++ make zeromq-dev protobuf-dev graphicsmagick yasm && \
    apk --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ add android-tools && \
    npm install -g stf --unsafe-perm

CMD ["stf", "local", "--public-ip", "0.0.0.0"]
