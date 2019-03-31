dockerstatus=$(systemctl status | grep -c docker) || xt "erro" "1" && exit
dockercont=$(docker ps)
mapfile -t containers < "${CWDIR}"/containers.list
for i in "${containers[@]}"; do
  if (( "${dockerstatus}" > 0 )); then
    case "$2" in
      "start")
        if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
          echo "warn Container $i was already up and running!"
        else
          if (docker start "$i" > /dev/null 2>&1); then
            echo "done Started container $i succesfully!"
          else
            echo "erro Failed to start container $i!"
          fi
        fi
      ;;
      "stop")
        if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
          if (docker stop --time=20 "$i" > /dev/null 2>&1); then
            echo "done Stopped container $i succesfully!"
          else
            echo "erro Failed to stop container $i!"
          fi
        else
          echo "warn Container $i was already stopped!"
        fi
      ;;
      "status")
        if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
          echo "warn Container $i is up and running!"
        else
          echo "erro Container $i is stopped!"
        fi
      ;;
    esac
  elif (systemctl -q is-active docker); then
    echo "erro An error has occured, we are sorry!"
  else
    echo "erro Docker is stopped, cannot perform check!"
  fi
done 
