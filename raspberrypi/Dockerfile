FROM pihole/pihole:latest
RUN apt update && apt upgrade -y --no-install-recommends && apt install -y unbound wget

#COPY lighttpd-external.conf /etc/lighttpd/lighttpd-external.conf 
#COPY unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY /etc /etc
COPY /var /var
RUN wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints
COPY start_unbound_and_s6_init.sh start_unbound_and_s6_init.sh

RUN chmod +rwx /var/log/unbound
RUN chmod +x start_unbound_and_s6_init.sh
ENTRYPOINT ./start_unbound_and_s6_init.sh