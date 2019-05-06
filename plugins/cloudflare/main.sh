# Record name $3
# Record type $4 (A)
# Record content $5 (own IP)
# Cloudflare Proxy $6 (true)

if FETCH=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records" \
    -H "X-Auth-Email: ${EMAIL}" \
    -H "X-Auth-Key: ${AUTH_KEY}" \
    -H "Content-Type: application/json"); then
  DOMAIN=($(echo "${FETCH}" | jq -r '.result[].name'))
  case "$2" in
    "list")
      for ((i=0;i<${#DOMAIN[@]};++i)); do
        echo "info ----------------------------------------------------------"
        echo "info Record name: $(echo "${FETCH}" | jq -r ".result[${i}].name")"
        echo "info Record type: $(echo "${FETCH}" | jq -r ".result[${i}].type")"
        echo "info Record cont: $(echo "${FETCH}" | jq -r ".result[${i}].content")"
        echo "info Record iden: $(echo "${FETCH}" | jq -r ".result[${i}].id")"
        echo "info ----------------------------------------------------------"
      done
    ;;
    "set")
      if ! (containsElement "$3" "${DOMAIN[@]}"); then
        if (curl -sX POST "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records" \
          -H "X-Auth-Email: ${EMAIL}" \
          -H "X-Auth-Key: ${AUTH_KEY}" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"${4:-A}\",\"name\":\"${3}\",\"content\":\"${5:-$(curl -sS https://api.ipify.org)}\",\"proxied\":"${6:-true}"}" > /dev/null 2>&1); then
          echo "done Registered entry successfully."
        else
          echo "erro Failed to add entry"
        fi
      else
        for ((i=0;i<${#DOMAIN[@]};++i)); do
          if [[ "${DOMAIN[$i]}" = "$3" ]]; then
            if (curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records/$(echo "${FETCH}" | jq --compact-output -r "{(.result[$i].id): .result[$i].name}" | grep -oP "(?<=\{\")(.*)(?=\"\:\".*\"\})")" \
            -H "X-Auth-Email: ${EMAIL}" \
            -H "X-Auth-Key: ${AUTH_KEY}" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"${4:-A}\",\"name\":\"${3}\",\"content\":\"${5:-$(curl -sS https://api.ipify.org)}\",\"proxied\":"${6:-true}"}" > /dev/null 2>&1); then
              echo "done Edited entry successfully."
            else
              echo "erro Failed to edit entry"
            fi
          fi
        done
      fi
    ;;
    "remove")
      if (containsElement "$3" "${DOMAIN[@]}"); then
        for ((i=0;i<${#DOMAIN[@]};++i)); do
          if [[ "${DOMAIN[$i]}" = "$3" ]]; then
            if (curl -sX DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records/$(echo "${FETCH}" | jq --compact-output -r "{(.result[$i].id): .result[$i].name}" | grep -oP "(?<=\{\")(.*)(?=\"\:\".*\"\})")" \
            -H "X-Auth-Email: ${EMAIL}" \
            -H "X-Auth-Key: ${AUTH_KEY}" \
            -H "Content-Type: application/json" > /dev/null 2>&1); then
              echo "done Removed entry successfully."
            else
              echo "erro Failed to remove entry"
            fi
          fi
        done
      else
        echo "warn Entry ${3} does not exist."
      fi
    ;;
  esac
fi
