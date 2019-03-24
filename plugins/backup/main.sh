source "${CWDIR}/.env"

# MariaDB / MySQL
output info "Backing up MariaDB"
mysqldump -h "${MSQL_HOST}" -P"${MSQL_PORT}" -u"${MSQL_USER}" -p"${MSQL_PASS}" -ARE | gzip -c > "${MSQL_PATH}"/mariadb-$(date +%s).sql.gz || output erro "Failed to backup MariaDB"

# Postgres (Docker)
output info "Backing up PostgreSQL"
docker exec main-db_postgres_1 pg_dumpall -U "${PSQL_USER}" | gzip -c > "${PSQL_PATH}"/postgres-$(date +%s).sql.gz || output erro "Failed to backup PostgreSQL"

# InfluxDB (Docker)
# output info "Backing up InfluxDB"
# docker exec main-db_influxdb_1 bash -c "influxd backup -portable -database telegraf /backups > /dev/null 2>&1 && tar -cz /backups" > "${IFXDB_PATH}"/influxdb-telegraf-$(date +%s).tar.gz || output erro "Failed to backup InfluxDB"

# Backup maintenance
output info "Removing older backups"
find /root/main-db/backups/* -type f -ctime +${BR_DAYS} -exec rm -rf {} \;
