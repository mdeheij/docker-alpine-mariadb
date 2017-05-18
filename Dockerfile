FROM alpine:latest
MAINTAINER mdeheij

RUN apk add --no-cache mysql mysql-client pwgen

ADD run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
