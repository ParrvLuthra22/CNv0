# Mac 2 (Parrv) — LAN inventory — Task A

| Field | Value |
|---|---|
| Role | Edge reverse proxy / load balancer / TLS termination |
| IP address (en0) | 10.7.3.237 |
| Subnet mask | 255.255.224.0 |
| Gateway/Router | 10.7.0.1 |
| Wi-Fi ID | 10:9f:41:bc:00:23 |
| MAC (en0) | a6:90:72:75:5b:2e |
| Assignment | DHCP (see note below) |

Captured with:
```
ipconfig getifaddr en0
networksetup -getinfo Wi-Fi
ifconfig en0 | grep ether
```
