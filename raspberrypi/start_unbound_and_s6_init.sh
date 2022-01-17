#!/bin/bash

reserved=12582912
availableMemory=$((1024 * $( (grep MemAvailable /proc/meminfo || grep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
memoryLimit=$availableMemory
[ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ] && memoryLimit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes | sed 's/[^0-9]//g')
[[ ! -z $memoryLimit && $memoryLimit -gt 0 && $memoryLimit -lt $availableMemory ]] && availableMemory=$memoryLimit
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
rr_cache_size=$(($availableMemory / 3))
# Use roughly twice as much rrset cache memory as msg cache memory
msg_cache_size=$(($rr_cache_size / 2))
nproc=$(nproc)
export nproc
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc - 1))
    # Calculate base 2 log of the number of processors
    nproc_log=$(perl -e 'printf "%5.5f\n", log($ENV{nproc})/log(2);')

    # Round the logarithm to an integer
    rounded_nproc_log="$(printf '%.*f\n' 0 "$nproc_log")"

    # Set *-slabs to a power of 2 close to the num-threads value.
    # This reduces lock contention.
    slabs=$(( 2 ** rounded_nproc_log ))
else
    threads=1
    slabs=4
fi

if [ ! -f /etc/unbound/unbound.conf.d/performance-unbound.conf ]; then
    sed \
        -e "s/@MSG_CACHE_SIZE@/${msg_cache_size}/" \
        -e "s/@RR_CACHE_SIZE@/${rr_cache_size}/" \
        -e "s/@THREADS@/${threads}/" \
        -e "s/@SLABS@/${slabs}/" \
        > /etc/unbound/unbound.conf.d/performance-unbound.conf << EOT

server:
    ###########################################################################
    # PERFORMANCE SETTINGS
    ###########################################################################
    # https://nlnetlabs.nl/documentation/unbound/howto-optimise/
    # https://nlnetlabs.nl/news/2019/Feb/05/unbound-1.9.0-released/

    # Number of slabs in the infrastructure cache. Slabs reduce lock contention
    # by threads. Must be set to a power of 2.
    infra-cache-slabs: @SLABS@

    # Number of incoming TCP buffers to allocate per thread. Default
    # is 10. If set to 0, or if do-tcp is "no", no  TCP  queries  from
    # clients  are  accepted. For larger installations increasing this
    # value is a good idea.
    incoming-num-tcp: 10

    # Number of slabs in the key cache. Slabs reduce lock contention by
    # threads. Must be set to a power of 2. Setting (close) to the number
    # of cpus is a reasonable guess.
    key-cache-slabs: @SLABS@

    # Number  of  bytes  size  of  the  message  cache.
    # Unbound recommendation is to Use roughly twice as much rrset cache memory
    # as you use msg cache memory.
    msg-cache-size: @MSG_CACHE_SIZE@

    # Number of slabs in the message cache. Slabs reduce lock contention by
    # threads. Must be set to a power of 2. Setting (close) to the number of
    # cpus is a reasonable guess.
    msg-cache-slabs: @SLABS@

    # The number of queries that every thread will service simultaneously. If
    # more queries arrive that need servicing, and no queries can be jostled
    # out (see jostle-timeout), then the queries are dropped.
    # This is best set at half the number of the outgoing-range.
    # This Unbound instance was compiled with libevent so it can efficiently
    # use more than 1024 file descriptors.
    num-queries-per-thread: 4096

    # The number of threads to create to serve clients.
    # This is set dynamically at run time to effectively use available CPUs
    # resources
    num-threads: @THREADS@

    # Number of ports to open. This number of file descriptors can be opened
    # per thread.
    # This Unbound instance was compiled with libevent so it can efficiently
    # use more than 1024 file descriptors.
    outgoing-range: 8192

    # Number of bytes size of the RRset cache.
    # Use roughly twice as much rrset cache memory as msg cache memory
    rrset-cache-size: @RR_CACHE_SIZE@

    # Number of slabs in the RRset cache. Slabs reduce lock contention by
    # threads. Must be set to a power of 2.
    rrset-cache-slabs: @SLABS@

    # Do no insert authority/additional sections into response messages when
    # those sections are not required. This reduces response size
    # significantly, and may avoid TCP fallback for some responses. This may
    # cause a slight speedup.
    minimal-responses: yes

    # # Fetch the DNSKEYs earlier in the validation process, when a DS record
    # is encountered. This lowers the latency of requests at the expense of
    # little more CPU usage.
    prefetch: yes

    # Fetch the DNSKEYs earlier in the validation process, when a DS record is
    # encountered. This lowers the latency of requests at the expense of little
    # more CPU usage.
    prefetch-key: yes

    # Have unbound attempt to serve old responses from cache with a TTL of 0 in
    # the response without waiting for the actual resolution to finish. The
    # actual resolution answer ends up in the cache later on.
    serve-expired: yes

    # Open dedicated listening sockets for incoming queries for each thread and
    # try to set the SO_REUSEPORT socket option on each socket. May distribute
    # incoming queries to threads more evenly.
    so-reuseport: yes

    
remote-control:
    control-enable: no
EOT
fi

/etc/init.d/unbound start
/s6-init