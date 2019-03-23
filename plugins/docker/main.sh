dockercont=$(docker ps) || xt "erro" "1" && exit
dockerstatus=$(systemctl status | grep -c docker)
mapfile -t containers < "${CWDIR}"/containers.list
for i in "${containers[@]}"; do
    if (( "${dockerstatus}" > 0 )); then
        case "$2" in
            "start")
                if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
                    output warn "Container $i was already up and running!"
                else
                    if (docker start "$i" > /dev/null 2>&1); then
                        output done "Started container $i succesfully!"
                    else
                        output erro "Failed to start container $i!"
                    fi
                fi
            ;;
            "stop")
                if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
                    if (docker stop --time=20 "$i" > /dev/null 2>&1); then
                        output done "Stopped container $i succesfully!"
                    else
                        output erro "Failed to stop container $i!"
                    fi
                else
                    output warn "Container $i was already stopped!"
                fi
            ;;
            "status")
                if (( $(echo "${dockercont}" | grep -c "$i") > 0 )); then
                    output warn "Container $i is up and running!"
                else
                    output erro "Container $i is stopped!"
                fi
            ;;
        esac
    elif (systemctl -q is-active docker); then
        output erro "An error has occured, we are sorry!"
    else
        output erro "Docker is stopped, cannot perform check!"
    fi
done 
