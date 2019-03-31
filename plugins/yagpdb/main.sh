# TODO: More variables and push statsh if encountering problems

cd /root/yagpdb || exit
echo "info Getting latest version"
git pull
cd ./yagpdb_docker || exit
echo "info Building latest version"
docker-compose build --force-rm --no-cache --pull
echo "info Starting bot"
docker-compose up -d 
