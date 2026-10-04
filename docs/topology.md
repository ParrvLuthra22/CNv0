# Network Topology — Private Network Service Platform

## Diagram
                     ┌────────────────────────┐
                     │   Client (any of the    │
                     │   4 machines, or a      │
                     │   grader's device)      │
                     └───────────┬─────────────┘
                                 │
                 1. DNS query for app.team1.test
                                 │
                                 ▼
                ┌──────────────────────────────┐
                │  Mac 1 — Malhar                │
                │  DNS server (dnsmasq)          │
                │  IP: 10.7.5.152                │
                │  Port: 53                      │
                └───────────────┬────────────────┘
                                 │
                 2. Returns Parrv's IP
                                 │
                                 ▼
                ┌──────────────────────────────┐
                │  Mac 2 — Parrv                 │
                │  Edge: nginx (reverse proxy +  │
                │  load balancer + TLS)          │
                │  IP: 10.7.29.176               │
                │  Ports: 80 → redirect, 443 TLS │
                └───────────────┬────────────────┘
                                 │
                 3. Proxied (round-robin, health-checked)
                    ┌────────────┴────────────┐
                    ▼                          ▼
    ┌──────────────────────────┐  ┌──────────────────────────┐
    │  Mac 3 — Raghav           │  │  Mac 4 — Pushkar          │
    │  Backend Server A         │  │  Backend Server B         │
    │  IP: 10.7.25.71           │  │  IP: 10.7.11.57          │
    │  Port: 3001                │  │  Port: 3002                │
    └───────────────────────────┘  └───────────────────────────┘



## Machine inventory

| # | Owner | Role | IP address | MAC address | Port(s) |
|---|---|---|---|---|---|
| 1 | Malhar | DNS server | `10.7.5.152` | `TODO` | 53 |
| 2 | Parrv | Edge / load balancer / TLS | `10.7.29.176` | `TODO` | 80, 443 |
| 3 | Raghav | Backend Server A | `10.7.25.71` | `TODO` | 3001 |
| 4 | Pushkar | Backend Server B | `10.7.11.57` | `TODO` | 3002 |

<!-- TODO: collect MACs from each teammate's own Mac with `ifconfig en0 | grep ether`
     (Malhar, Raghav, Pushkar). Parrv's MAC taken from `ifconfig en0` on 2026-10-04;
     Wi-Fi Private Address may rotate it per network. -->

All four machines share the same LAN/hotspot subnet.

## DNS records

| Hostname | Resolves to |
|---|---|
| `app.team1.test` | `10.7.29.176` |
| `api.team1.test` | `10.7.29.176` |

## Connectivity confirmed

- All-to-all ping (12/12) confirmed between all four machines.
- DNS query from every client machine to Malhar's DNS server (port 53)
  resolves `app.team1.test` correctly.
- TLS handshake to `app.team1.test:443` on Parrv's machine verified from
  all four machines using the shared CA certificate.

## Client DNS configuration

Every machine's DNS resolver is set to `10.7.5.152` (Network Settings →
Wi-Fi → Details → DNS), so `app.team1.test` resolves without any manual
`--resolve` override.
