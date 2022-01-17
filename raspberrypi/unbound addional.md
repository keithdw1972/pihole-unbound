    ###########################################################################
    # PRIVACY SETTINGS
    ###########################################################################

    # RFC 8198. Use the DNSSEC NSEC chain to synthesize NXDO-MAIN and other
    # denials, using information from previous NXDO-MAINs answers. In other
    # words, use cached NSEC records to generate negative answers within a
    # range and positive answers from wildcards. This increases performance,
    # decreases latency and resource utilization on both authoritative and
    # recursive servers, and increases privacy. Also, it may help increase
    # resilience to certain DoS attacks in some circumstances.
    aggressive-nsec: yes

    # Extra delay for timeouted UDP ports before they are closed, in msec.
    # This prevents very delayed answer packets from the upstream (recursive)
    # servers from bouncing against closed ports and setting off all sort of
    # close-port counters, with eg. 1500 msec. When timeouts happen you need
    # extra sockets, it checks the ID and remote IP of packets, and unwanted
    # packets are added to the unwanted packet counter.
    delay-close: 10000

    # Prevent the unbound server from forking into the background as a daemon
    do-daemonize: no

    # Add localhost to the do-not-query-address list.
    do-not-query-localhost: no

    # Number  of  bytes size of the aggressive negative cache.
    neg-cache-size: 4M

    # Send minimum amount of information to upstream servers to enhance
    # privacy (best privacy).
    qname-minimisation: yes

    ###########################################################################
    # SECURITY SETTINGS
    ###########################################################################
    # Only give access to recursion clients from LAN IPs
    access-control: 127.0.0.1/32 allow
    access-control: 192.168.0.0/16 allow
    access-control: 172.16.0.0/12 allow
    access-control: 10.0.0.0/8 allow
    # access-control: fc00::/7 allow
    # access-control: ::1/128 allow

    # File with trust anchor for  one  zone, which is tracked with RFC5011
    # probes.
    auto-trust-anchor-file: "var/root.key"

    # Enable chroot (i.e, change apparent root directory for the current
    # running process and its children)
    #chroot: "/opt/unbound/etc/unbound"

    # Deny queries of type ANY with an empty response.
    deny-any: yes

    # Harden against algorithm downgrade when multiple algorithms are
    # advertised in the DS record.
    harden-algo-downgrade: yes

    # RFC 8020. returns nxdomain to queries for a name below another name that
    # is already known to be nxdomain.
    harden-below-nxdomain: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the
    # zone becomes bogus. If turned off you run the risk of a downgrade attack
    # that disables security for a zone.
    harden-dnssec-stripped: yes

    # Only trust glue if it is within the servers authority.
    harden-glue: yes

    # Ignore very large queries.
    harden-large-queries: yes

    # Perform additional queries for infrastructure data to harden the referral
    # path. Validates the replies if trust anchors are configured and the zones
    # are signed. This enforces DNSSEC validation on nameserver NS sets and the
    # nameserver addresses that are encountered on the referral path to the
    # answer. Experimental option.
    harden-referral-path: no

    # Ignore very small EDNS buffer sizes from queries.
    harden-short-bufsize: yes

    # If enabled the HTTP header User-Agent is not set. Use with  caution
    # as some webserver configurations may reject HTTP requests lacking
    # this header. If needed, it is better to explicitly set the
    # the http-user-agent.
    hide-http-user-agent: no

    # Refuse id.server and hostname.bind queries
    hide-identity: yes

    # Refuse version.server and version.bind queries
    hide-version: yes

    # Set the HTTP User-Agent header for outgoing HTTP requests. If
    # set to "", the default, then the package name  and  version  are
    #  used.
    http-user-agent: "DNS"

    # Report this identity rather than the hostname of the server.
    identity: "DNS"

    # These private network addresses are not allowed to be returned for public
    # internet names. Any  occurrence of such addresses are removed from DNS
    # answers. Additionally, the DNSSEC validator may mark the  answers  bogus.
    # This  protects  against DNS  Rebinding
    private-address: 10.0.0.0/8
    private-address: 172.16.0.0/12
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    # private-address: fd00::/8
    # private-address: fe80::/10
    # private-address: ::ffff:0:0/96

    # Enable ratelimiting of queries (per second) sent to nameserver for
    # performing recursion. More queries are turned away with an error
    # (servfail). This stops recursive floods (e.g., random query names), but
    # not spoofed reflection floods. Cached responses are not rate limited by
    # this setting. Experimental option.
    ratelimit: 1000

    # Use this certificate bundle for authenticating connections made to
    # outside peers (e.g., auth-zone urls, DNS over TLS connections).
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt

    # Set the total number of unwanted replies to eep track of in every thread.
    # When it reaches the threshold, a defensive action of clearing the rrset
    # and message caches is taken, hopefully flushing away any poison.
    # Unbound suggests a value of 10 million.
    unwanted-reply-threshold: 10000

    # Use 0x20-encoded random bits in the query to foil spoof attempts. This
    # perturbs the lowercase and uppercase of query names sent to authority
    # servers and checks if the reply still has the correct casing.
    # This feature is an experimental implementation of draft dns-0x20.
    # Experimental option.
    use-caps-for-id: yes

    # Help protect users that rely on this validator for authentication from
    # potentially bad data in the additional section. Instruct the validator to
    # remove data from the additional section of secure messages that are not
    # signed properly. Messages that are insecure, bogus, indeterminate or
    # unchecked are not affected.
    val-clean-additional: yes