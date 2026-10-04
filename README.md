# Private Network Service Platform

Computer Networks course project — a private, local network service platform
built from scratch across four machines, with no cloud infrastructure.
Demonstrates DNS resolution, TLS-terminated load balancing, HTTP caching,
and failure diagnosis at the DNS/TCP/TLS/application layers.

**Core principle:** the application stays simple — the network is the project.

## Team & roles

| Machine | Owner | Role | IP | Port(s) |
|---|---|---|---|---|
| Mac 1 | Malhar | Private DNS server (dnsmasq) | 10.7.5.152 | 53 |
| Mac 2 | Parrv | Edge reverse proxy, load balancer, TLS termination (nginx) | 10.7.29.176 | 80, 443 |
| Mac 3 | Raghav | Backend Server A | 10.7.25.71 | 3001 |
| Mac 4 | Pushkar | Backend Server B | 10.7.11.57 | 3002 |

> IPs are DHCP-assigned and may change. Re-verify with `ipconfig getifaddr en0`
> on each Mac before every demo session, and update the DNS records and
> configs if anything has drifted.

## Architecture

```
Client → DNS query (Mac 1) → HTTPS request (Mac 2, nginx) → Backend A or B (Mac 3/4)
```

Domain: `app.team1.test` / `api.team1.test` — resolves via the team's own
DNS server, terminates TLS at the edge, and load-balances across two
identical backend instances.

See [`docs/architecture.md`](docs/architecture.md) and
[`docs/topology.md`](docs/topology.md) for full details.

## Repository layout

```
/docs      architecture.md, topology.md, final-report.md
/config    dnsmasq/, nginx/, tls/ (ca.crt only, never keys), pf-rules/
/backend   server.js, package.json
/evidence  01-lan/ 02-dns/ 03-http-headers/ 04-wireshark/ 06-failures/ 07-phase2/
/scripts   start/stop helpers
```

## Status

**Phase 1 (build & observe):** DNS, backends, load balancing, TLS, and
HTTP caching all verified end-to-end through the real domain. Wireshark
capture (DNS, TCP handshake, TLS SNI) and all five failure demonstrations
are done. **Phase 1 is complete.**

**Phase 2 (harden & recover):** not yet started.

## Evidence index

| Folder | Contents |
|---|---|
| [`evidence/01-lan/`](evidence/01-lan/) | LAN inventory: IP, subnet, gateway, MAC per machine |
| [`evidence/02-dns/`](evidence/02-dns/) | DNS resolution and round-robin load-balancing verification |
| [`evidence/03-http-headers/`](evidence/03-http-headers/) | HTTP status/headers and caching (ETag, 304) via backend and domain |
| [`evidence/04-wireshark/`](evidence/04-wireshark/) | Wireshark screenshots: DNS query/response, TCP handshake, TLS Client Hello with SNI |
| [`evidence/06-failures/`](evidence/06-failures/) | Failure demos: wrong DNS, DNS wrong IP, backend A down, both backends down, wrong port |
| [`evidence/07-phase2/`](evidence/07-phase2/) | Phase 2 (harden & recover) evidence — empty for now |

## Running it

Each machine runs its own role — see the per-task instructions in
`docs/architecture.md`. Backends are plain Node HTTP servers (no
framework dependency required); the edge runs nginx with a self-signed
local CA for TLS.
