# Private Network Service Platform

Computer Networks course project — a private, local network service platform
built from scratch across four machines, with no cloud infrastructure.
Demonstrates DNS resolution, TLS-terminated load balancing, HTTP caching,
and failure diagnosis at the DNS/TCP/TLS/application layers.

**Core principle:** the application stays simple — the network is the project.

## Team & roles

| Machine | Owner | Role | Port(s) |
|---|---|---|---|
| Mac 1 | Malhar | Private DNS server (dnsmasq) | 53 |
| Mac 2 | Parrv | Edge reverse proxy, load balancer, TLS termination (nginx) | 80, 443 |
| Mac 3 | Raghav | Backend Server A | 3001 |
| Mac 4 | Pushkar | Backend Server B | 3002 |

## Architecture

Client → DNS query (Mac 1) → HTTPS request (Mac 2, nginx) → Backend A or B (Mac 3/4)


Domain: `app.team1.test` / `api.team1.test` — resolves via the team's own
DNS server, terminates TLS at the edge, and load-balances across two
identical backend instances.

See [`docs/architecture.md`](docs/architecture.md) and
[`docs/topology.md`](docs/topology.md) for full details.

## Repository layout

/docs architecture.md, topology.md, final-report.md
/config dnsmasq/, nginx/, tls/ (ca.crt only, never keys), pf-rules/
/backend server.js, package.json
/evidence 01-lan/ 02-dns/ 03-http-headers/ 04-wireshark/ 06-failures/ 07-phase2/
/scripts start/stop helpers


## Status

**Phase 1 (build & observe):** DNS, backends, load balancing, TLS, and
HTTP caching all verified end-to-end through the real domain. Wireshark
capture and failure demonstrations in progress.

**Phase 2 (harden & recover):** not yet started.

## Running it

Each machine runs its own role — see the per-task instructions in
`docs/architecture.md`. Backends are plain Node HTTP servers (no
framework dependency required); the edge runs nginx with a self-signed
local CA for TLS.
