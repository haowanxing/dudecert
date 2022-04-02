FROM alpine:3.15

RUN apk update && apk add openssl
VOLUME ["/opt/ca/root", "/opt/ca/agent"]
COPY entrypoint.sh /opt/
COPY root-openssl.cnf agent-openssl.cnf site-openssl-tpl.cnf /data/
ENTRYPOINT ["/opt/entrypoint.sh"]