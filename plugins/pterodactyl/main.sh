case "$2" in
    "update")
        cd /var/www/pterodactyl || exit
        php artisan down
        output info "Fetching latest releases"
        curl -L https://github.com/pterodactyl/panel/releases/download/"$(getlatest "Pterodactyl/panel")"/panel.tar.gz | tar --strip-components=1 -xzv
        curl -L https://github.com/RXCommunity/RedXen-Panel/archive/"$(getlatest "RXCommunity/RedXen-Panel")".tar.gz | tar --strip-components=1 -xzv
        output info "Ensuring permissions are correct"
        chown -R www-data:www-data ./*
        chmod -R 755 storage/* bootstrap/cache
        output info "Getting latest deps"
        composer install --no-dev --optimize-autoloader || output erro "Failed to get deps!"

        artisanfunc=(
            "view:clear"
            "cache:clear"
            "config:cache"
            "migrate --force"
            "db:seed --force"
            "p:migration:clean-orphaned-keys -n"
            "up"
        )

        output info "Running migrations and clearance"
        for f in "${artisanfunc[@]}"; do
            php artisan $f || output erro "Failed to execute 'artisan ${f}'"
        done
    ;;
    *); echo "Nothing to do";;
esac
