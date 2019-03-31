if [ -x "$(command -v docker)" ]; then
  echo "info Clearing Docker remainings"
  docker system prune --all -f
fi
case $(uname -rv) in
  *Ubuntu*)
    echo "info Clearing & Updating APT"
    apt-get -y update
    apt-get -y autoclean
    apt-get -y autoremove
  ;;
esac

echo "info Clearing logs"
if [ -x "$(command -v nginx)" ]; then
  truncate -s 0 "${LOGPATH:-/var/log/nginx/*.*}"
fi
journalctl --vacuum-size=20M
