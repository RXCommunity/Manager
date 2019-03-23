cd /root/yagpdb || exit
git pull
cd ./yagpdb_docker || exit
docker-compose build --force-rm --no-cache --pull
docker-compose up -d 
