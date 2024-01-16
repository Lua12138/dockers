FROM --platform=linux/amd64 debian

ARG DEB_DOWNLOAD=https://dashboard.swarmbytes.com/downloads/swarmbytes_1.16.0_amd64.deb
ENV API_KEY
ENV BIND_IPS
ENV HTTP_PORT
ENV CHILD_SPAWN_DELAY

WORKDIR /workspaces

COPY entrypoint.sh /workspaces/entrypoint.sh

RUN curl "${DEB_DOWNLOAD}" -o /workspaces/swarmbytes.deb && \
    apt install -y /workspaces/swarmbytes.deb && \
    rm -f /workspaces/swarmbytes.deb && \
    ulimit -n 65535 && \
    chmod +x /workspaces/entrypoint.sh

CMD /workspaces/entrypoint.sh