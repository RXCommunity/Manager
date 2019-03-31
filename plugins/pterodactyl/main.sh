case "$2" in
  "update")
    cd /var/www/pterodactyl || exit
    php artisan down
    echo "info Fetching latest releases"
    curl -L https://github.com/pterodactyl/panel/releases/download/"$(getlatest "Pterodactyl/panel")"/panel.tar.gz | tar --strip-components=1 -xzv
    curl -L https://github.com/RXCommunity/RedXen-Panel/archive/"$(getlatest "RXCommunity/RedXen-Panel")".tar.gz | tar --strip-components=1 -xzv
    echo "info Ensuring permissions are correct"
    chown -R www-data:www-data ./*
    chmod -R 755 storage/* bootstrap/cache
    echo "info Getting latest deps"
    composer install --no-dev --optimize-autoloader || echo "erro Failed to get deps!"

    artisanfunc=(
      "view:clear"
      "cache:clear"
      "config:cache"
      "migrate --force"
      "db:seed --force"
      "p:migration:clean-orphaned-keys -n"
      "up"
    )

    echo "info Running migrations and clearance"
    for f in "${artisanfunc[@]}"; do
      php artisan $f || echo "erro Failed to execute 'artisan ${f}'"
    done
  ;;
  *); echo "warn Nothing to do";;
esac
