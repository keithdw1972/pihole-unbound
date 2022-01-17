FROM pihole/pihole:latest
RUN apt update && apt upgrade --no-install-recommends -y && apt install -y wget unbound

COPY pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY lighttpd-external.conf /etc/lighttpd/external.conf
COPY start_unbound_and_s6_init.sh start_unbound_and_s6_init.sh

RUN wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints
RUN chmod +x start_unbound_and_s6_init.sh
ENTRYPOINT ./start_unbound_and_s6_init.sh
