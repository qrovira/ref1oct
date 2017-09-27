FROM nginx

RUN apt-get update && \
    apt-get install -y certbot cpanminus build-essential libio-socket-ssl-perl && \
    apt-get clean

RUN cpanm Mojolicious

COPY bin/* /usr/local/bin/

COPY site.conf /etc/nginx/conf.d/default.conf

RUN /usr/bin/perl /usr/local/bin/dump_db

RUN /usr/bin/perl /usr/local/bin/dump_web

EXPOSE 80 443
