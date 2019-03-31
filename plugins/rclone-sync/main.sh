for i in ${#DIRS[@]}; do
  echo "info" "Syncing ${DIRS[$I]##*${DELIMIT}} with ${DIRS[$I]%%${DELIMIT}*}"
  (rclone sync -P ${DIRS[$I]%%${DELIMIT}*} ${DIRS[$I]##*${DELIMIT}}) > /dev/null 2>&1
done
