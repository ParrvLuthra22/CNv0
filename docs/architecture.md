# Architecture — Private Network Service Platform

## Overview

A private network service platform built across four physical machines on
a shared LAN (or hotspot), demonstrating DNS resolution, load-balanced
backend services, TLS termination, and traffic-level verification.

Domain used throughout: `team1.test`

## Components

| Component | Machine | Owner | Purpose |
|---|---|---|---|
| DNS server | Mac 1 | Malhar | Resolves `app.team1.test` / `api.team1.test` to the edge machine's IP using dnsmasq |
| Edge / reverse proxy | Mac 2 | Parrv | Terminates TLS, load-balances requests across both backends via nginx |
| Backend Server A | Mac 3 | Raghav | REST API instance, identical code to Backend B |
| Backend Server B | Mac 4 | Pushkar | REST API instance, identical code to Backend A |

## Request flow

1. Client queries DNS for `app.team1.test`.
2. Malhar's dnsmasq (port 53) returns Parrv's IP (the edge machine).
3. Client connects to Parrv on port 443 (TLS).
4. nginx terminates TLS using a certificate signed by our own local CA,
   trusted on all four machines' keychains.
5. nginx proxies the request to whichever backend (Raghav's `:3001` or
   Pushkar's `:3002`) is healthy, using round-robin with automatic
   failover (`max_fails=2 fail_timeout=10s`).
6. The backend responds with an `X-Backend` header identifying which
   instance served the request, plus `Cache-Control` and `ETag` headers
   on cacheable responses.

## Services and ports

| Service | Host | Port | Protocol |
|---|---|---|---|
| dnsmasq | Malhar's Mac | 53 | UDP/TCP (DNS) |
| nginx (HTTP → redirect) | Parrv's Mac | 80 | HTTP |
| nginx (TLS termination + LB) | Parrv's Mac | 443 | HTTPS |
| Backend A | Raghav's Mac | 3001 | HTTP |
| Backend B | Pushkar's Mac | 3002 | HTTP |

## API endpoints (backend)

| Endpoint | Method | Response |
|---|---|---|
| `/` | GET, HEAD | Plain text, "Backend `<ID>` is running" |
| `/api/status` | GET, HEAD | JSON `{ backend, status: "ok" }` |
| `/api/cached` | GET, HEAD | JSON with `Cache-Control: public, max-age=60` and `ETag`; returns `304 Not Modified` when `If-None-Match` matches |

## TLS

- Self-signed local Certificate Authority (`Team1 Local CA`), generated
  once on Parrv's machine.
- Server certificate for `app.team1.test` / `api.team1.test`, signed by
  that CA, with a SAN extension covering both hostnames.
- `ca.crt` is distributed to all four machines and trusted via
  `security add-trusted-cert` in each machine's System keychain.
- `ca.key` and `server.key` are never committed to the repository — kept
  local to Parrv's machine only.

## High availability

- nginx's `upstream` block marks a backend unhealthy after 2 consecutive
  failures (`max_fails=2`) and retries it after 10 seconds
  (`fail_timeout=10s`).
- If one backend goes down, nginx continues serving from the other with
  no client-visible interruption.
- If both backends go down, clients receive `502 Bad Gateway` from nginx.

## Caching strategy

- `/api/cached` is served with a 60-second `Cache-Control: public,
  max-age=60` and a content-derived `ETag`.
- Clients that send a matching `If-None-Match` header receive `304 Not
  Modified` with no response body, verified via `curl -sI -H
  'If-None-Match: "<etag>"'`.

## Failure modes demonstrated

| Scenario | Trigger | Expected result |
|---|---|---|
| Wrong DNS on a client | Point resolver at a bad IP | Domain fails to resolve; direct IP connectivity (ping) still works |
| DNS record changed to wrong IP | Edit dnsmasq `address=` line | Domain resolves, but to the wrong host |
| One backend down | Kill Backend A | Service continues via Backend B only |
| Both backends down | Kill both | nginx returns `502 Bad Gateway` |
| Wrong port | Connect to a closed port | Connection refused |

## Repository layout

```
/docs        architecture.md, topology.md, final-report.md
/config      dnsmasq/, nginx/, tls/ (ca.crt only, never keys), pf-rules/
/backend     server.js, package.json
/evidence    01-lan/ 02-dns/ 03-http-headers/ 04-wireshark/ 06-failures/ 07-phase2/
/scripts     start/stop helpers
```