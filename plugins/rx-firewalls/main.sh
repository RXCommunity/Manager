source "${CWDIR}/.env"

function join { local IFS="$1"; shift; echo "$*"; }

# Main
output "info" "Getting addresses"
ipv4=$(curl https://www.cloudflare.com/ips-v4) || output erro "Failed to get IPv4 addresses"
ipv6=$(curl https://www.cloudflare.com/ips-v6) || output erro "Failed to get IPv6 addresses"
ip=("${ipv4[@]}" "${ipv6[@]}")
output "info" "Truncating existing list"
truncate -s 0 $FILE
output "info" "Writing new IPs to the list"
for i in ${ip[@]}; do
    echo "set_real_ip_from ${i};" >> $FILE
done
echo "real_ip_header X-Forwarded-For;" >> $FILE
output "info" "Reloading nginx"
nginx -t && nginx -s reload || echo "Failed to reload nginx" | output erro
output "info" "Updating DigitalOcean Firewall(s)"
DOLIST=()
DLETS=()
for i in ${ip[@]}; do
    DOLIST+=(address:${i})
done
snap run doctl compute firewall update ${FWID} --name ${NAME} --droplet-ids $(join , ${DROPLETS[@]}) --inbound-rules protocol:tcp,ports:443,$(join , ${DOLIST[@]})
