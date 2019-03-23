if [ -x "$(command -v docker)" ]; then
    output info "Clearing Docker remainings"
    docker system prune --all -f
fi
case $(uname -rv) in
  *Ubuntu*)
    output info "Clearing & Updating APT"
    apt-get -y update
    apt-get -y autoclean
    apt-get -y autoremove
  ;;
esac

output info "Clearing logs"
if [ -x "$(command -v nginx)" ]; then
    truncate -s 0 /var/log/nginx/*.*
fi
journalctl --vacuum-size=20M
