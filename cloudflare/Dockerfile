FROM alpine

WORKDIR /home/

COPY command.sh .

RUN chmod +xr /home/command.sh && \
    apk add --no-cache jq curl bash

CMD ["bash", "/home/command.sh"]
