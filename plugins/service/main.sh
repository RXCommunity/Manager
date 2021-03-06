servicelist=$(systemctl list-units --type=service --state=active | grep -oe ".*\.service")
mapfile -t services < ${CWDIR}/services.list
for i in "${services[@]}"; do
  case "$2" in
    "start")
      if (( $(echo "${servicelist}" | grep -c "$i") > 0 )); then
        echo "warn Service $i was already running!"
      else
        if (systemctl start "$i" > /dev/null 2>&1); then
          echo "done Started service $i succesfully!"
        else
          echo "erro Failed to start service $i!"
        fi
      fi
    ;;
    "stop")
      if (( $(echo "${servicelist}" | grep -c "$i") > 0 )); then
        if (systemctl stop "$i" > /dev/null 2>&1); then
          echo "done Stopped service $i succesfully!"
        else
          echo "erro Failed to stop service $i!"
        fi
      else
        echo "warn Service $i is already stopped!"
      fi
    ;;
    "status")
      if (( $(echo "${servicelist}" | grep -c "$i") > 0 )); then
        echo "warn Service $i is up and running!"
      else
        echo "erro Service $i is stopped!"
      fi
    ;;
  esac
done
