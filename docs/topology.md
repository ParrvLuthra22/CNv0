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
                │  IP: <MALHAR_IP>               │
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
                │  IP: <PARRV_IP>                │
                │  Ports: 80 → redirect, 443 TLS │
                └───────────────┬────────────────┘
                                 │
                 3. Proxied (round-robin, health-checked)
                    ┌────────────┴────────────┐
                    ▼                          ▼
    ┌──────────────────────────┐  ┌──────────────────────────┐
    │  Mac 3 — Raghav           │  │  Mac 4 — Pushkar          │
    │  Backend Server A         │  │  Backend Server B         │
    │  IP: <RAGHAV_IP>          │  │  IP: <PUSHKAR_IP>         │
    │  Port: 3001                │  │  Port: 3002                │
    └───────────────────────────┘  └───────────────────────────┘



## Machine inventory

| # | Owner | Role | IP address | MAC address | Port(s) |
|---|---|---|---|---|---|
| 1 | Malhar | DNS server | `<MALHAR_IP>` | `<MALHAR_MAC>` | 53 |
| 2 | Parrv | Edge / load balancer / TLS | `<PARRV_IP>` | `<PARRV_MAC>` | 80, 443 |
| 3 | Raghav | Backend Server A | `<RAGHAV_IP>` | `<RAGHAV_MAC>` | 3001 |
| 4 | Pushkar | Backend Server B | `<PUSHKAR_IP>` | `<PUSHKAR_MAC>` | 3002 |

All four machines share the same LAN/hotspot subnet.

## DNS records

| Hostname | Resolves to |
|---|---|
| `app.team1.test` | `<PARRV_IP>` |
| `api.team1.test` | `<PARRV_IP>` |

## Connectivity confirmed

- All-to-all ping (12/12) confirmed between all four machines.
- DNS query from every client machine to Malhar's DNS server (port 53)
  resolves `app.team1.test` correctly.
- TLS handshake to `app.team1.test:443` on Parrv's machine verified from
  all four machines using the shared CA certificate.

## Client DNS configuration

Every machine's DNS resolver is set to `<MALHAR_IP>` (Network Settings →
Wi-Fi → Details → DNS), so `app.team1.test` resolves without any manual
`--resolve` override.