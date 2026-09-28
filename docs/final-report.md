# Phase 2 Final Report — Draft

## Team and system overview

The team ran a three-Mac private service platform on a shared LAN using the reserved `team1.test` namespace. Malhar operated private DNS on Mac 1, Parrv operated the TLS reverse proxy/load balancer on Mac 2, and Raghav operated Backend A and Backend B on Mac 3. The application was intentionally small so the report could focus on DNS, TCP, TLS, HTTP, isolation, and failure recovery.

## Extension A — Backup DNS (Raghav + Malhar)

**Design.** A second dnsmasq instance on Mac 3 used the same records and forwarding policy as the primary, with its listener bound to Mac 3's LAN address. Clients were configured with both resolver addresses.

**Procedure and evidence.** [Add exact config diff and commands.] [Add primary/backup IPs.] We stopped the primary DNS service and queried `app.team1.test` from a client. [Add observed answer, latency, and evidence path.]

**Outcome and limitations.** [Record whether client resolver failover was automatic and any delay/cache behavior.]

## Extension C — Backend firewall isolation (Raghav)

**Policy.** Permit TCP 3001/3002 from Parrv's edge IP, then block those ports from other sources. The rules were tested with a successful edge-originated request and failed client-originated requests.

**Safety and rollback evidence.** [Record pf.conf backup path/hash, pre/post rules, exact rollback command, and a test proving restored rules match the backup. Do not claim rollback validation until performed.] [Add evidence path.]

## Extension E — Standby edge and DNS cutover (Raghav + Parrv)

**Design.** A standby nginx on Mac 3 used Parrv's server configuration and certificate material to proxy to the same backends. DNS for `app.team1.test` was changed to the standby address with a short TTL for the cutover demonstration.

**Procedure and evidence.** [Add config/certificate provenance without including private keys in the repository.] [Record old and new DNS answers, client cache behavior, TLS validation, and HTTP response headers.] [Add evidence path.]

**Outcome and limitations.** [Describe observed cutover time and remaining single points of failure.]

## Failure demonstrations and troubleshooting

[Summarize the five rehearsed failure scenarios and the Phase 2 injected fault. For each, identify the first failing layer, diagnostic command, observation, recovery action, and evidence file.]

## Lessons learned

[Discuss DNS caching/TTL, transport reachability, TLS certificate validation, reverse-proxy health checks, host firewall ordering, and operational rollback.]
