function join { local IFS="$1"; shift; echo "$*"; }

# Main
echo "info Getting addresses"
ipv4=$(curl -sS https://www.cloudflare.com/ips-v4) || echo "erro Failed to get IPv4 addresses"
ipv6=$(curl -sS https://www.cloudflare.com/ips-v6) || echo "erro Failed to get IPv6 addresses"
ip=("${ipv4[@]}" "${ipv6[@]}")
echo "info Truncating existing list"
truncate -s 0 $FILE
echo "info Writing new IPs to the list"
for i in ${ip[@]}; do
    echo "set_real_ip_from ${i};" >> $FILE
done
echo "real_ip_header X-Forwarded-For;" >> $FILE
echo "info Reloading nginx"
nginx -s reload || echo "erro Failed to reload nginx"
echo "info Updating DigitalOcean Firewall(s)"
DOLIST=()
DLETS=()
for i in ${ip[@]}; do
    DOLIST+=(address:${i})
done
if (snap run doctl compute firewall update ${FWID} --name ${NAME} --droplet-ids $(join , ${DROPLETS[@]}) --inbound-rules protocol:tcp,ports:443,$(join , ${DOLIST[@]}) > /dev/null 2>&1); then
  echo "done Updated firewall(s) successfully"
else
  echo "erro Failed to update firewalls via doctl"
fi
