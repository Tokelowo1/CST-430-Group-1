pass=0
fail=0

good()  { echo " PASS  $1"; pass=$((pass+1)); }
bad() { echo " FAIL $1"; fail=$((fail+1)); }

#Hostname
name=$(hostname)
[ -n "$name" ] && good "Hostname: $name" || bad "Hostname not set"

# Non-loopback IP
ip=$(ip -4 addr show scope global | awk '/inet /{print $2}' | head -1)
[ -n "$ip" ] && good "IP address: $ip" || bad "No IP address assigned"

# /data mounted
mountpoint -q /data && good "/data is mounted" || bad "/data is not mounted"

# nginx enabled
[ "$(systemctl is-enabled nginx 2>/dev/null)" = "enabled" ] \
  && good "nginx is enabled" || bad "nginx is not enabled"

# nginx running
[ "$(systemctl is-active nginx 2>/dev/null)" = "active" ] \
  && good "nginx is running" || bad "nginx is not running"

# UFW active
ufw status 2>/dev/null | grep -q "Status: active" \
  && good "UFW is active" || bad "UFW is not active"

# Port 80 listening
ss -tlnp | awk '$4 ~ /:80$/{found=1} END{exit !found}' \
  && good "Port 80 is listening" || bad "Port 80 is not listening"

# /data/app/site exists
[ -d /data/app/site ] && good "/data/app/site exists" || bad "/data/app/site >

#nginx logs
journalctl -u nginx --since "10 minutes ago" --no-pager -n 20 2>/dev/null \
  && good "nginx log check done" || bad "Could not read nginx logs"
