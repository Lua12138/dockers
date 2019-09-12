FROM openstf/stf:v3.4.1

USER root

RUN npm install && \
    npm test

CMD ["stf", "local"]
