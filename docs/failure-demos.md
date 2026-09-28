# Failure demonstrations

Use these in the project LAN with Malhar and Parrv present. Record the exact time, command, observed status/headers, and a screenshot or terminal capture in `evidence/06-failures/`. Do not run the destructive steps against a shared or unrelated network.

## 1. Wrong DNS server

On a client, query an unused/wrong resolver address: `dig @<wrong-DNS-IP> app.team1.test`. Expected: timeout or no answer. Then ping a known LAN IP to show that IP connectivity can still work while name resolution fails.

## 2. DNS points to the wrong destination

With Malhar, temporarily change the `app.team1.test` address on the primary DNS server to a known unused LAN address, reload dnsmasq, and run `dig @<MAC1_IP> app.team1.test` followed by `curl -v https://app.team1.test`. Expected: DNS returns the changed address; the subsequent connection fails. Restore the record and verify it resolves to Parrv's edge again.

## 3. One backend stopped (HA check)

Before Ext D is configured this may cause intermittent errors; perform only after Parrv has confirmed nginx passive health checks. Stop Backend A with `kill <Backend-A-PID>` (or Ctrl-C in its terminal), then make repeated requests through Parrv's edge. Expected after nginx marks A unavailable: responses continue from B. Restart A and show balancing resumes.

## 4. Both backends stopped

Stop both backend processes, leave DNS and nginx running, then request the service through the edge. Expected: DNS still resolves and TLS still completes; HTTP returns `502 Bad Gateway`. Restart both processes and confirm recovery.

## 5. Wrong destination port

From a client, run `nc -vz <MAC3_IP> 4443` (or `curl -v http://<MAC3_IP>:4443/`). Expected: the host is reachable but no service listens on that port, so the connection is refused or times out. Compare with the working ports 3001/3002.

## Phase 2 challenge: firewall isolation

After Ext C is installed, from Parrv's Mac test both backend ports successfully; from another LAN client test both fail. Capture `pfctl -sr` before/after and the curl/nc outcomes. Use the verified rollback procedure if access is unexpected.
