# TLS / Local CA — Task E (Parrv, Mac 2)

## What was generated
- `ca.key` / `ca.crt` — self-signed local root CA, `CN=Team1 Local CA`, 4096-bit RSA, 365 days.
  **`ca.key` is never committed** (see `.gitignore`).
- `server.key` / `server.csr` / `server.crt` — 2048-bit RSA, `CN=app.team1.test`,
  SAN `DNS:app.team1.test, DNS:api.team1.test`, signed by our CA, 90 days.
  **`server.key` is never committed.**

## File to send to Malhar and Raghav

Send them **only** `config/tls/ca.crt` (never `ca.key`). Each of them trusts it locally:

```
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
```

## Verified on Mac 2 (edge)

```
openssl verify -CAfile ca.crt server.crt   # -> server.crt: OK
```

```
curl -sv --resolve app.team1.test:443:127.0.0.1 https://app.team1.test/
# subject: CN=app.team1.test
# issuer: CN=Team1 Local CA
# SSL certificate verify ok.
```

No `-k`, no `--cacert` needed on this Mac because it uses Apple's `/usr/bin/curl`
(SecureTransport), which reads the System keychain directly. Note for teammates:
if they use a Homebrew-installed curl instead, it links OpenSSL and will need
`--cacert ca.crt` explicitly, since it does not read the System keychain.
