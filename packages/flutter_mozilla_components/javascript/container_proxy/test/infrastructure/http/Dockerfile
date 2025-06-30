FROM datadog/squid

RUN apt update && apt install -y apache2-utils

RUN htpasswd -b -c /etc/squid/passwords userhttp passwordhttp

ADD squid.conf /etc/squid/squid.conf

RUN chmod o+rw /var/run

USER proxy
