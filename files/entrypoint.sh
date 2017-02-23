#!/bin/bash
# strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# if this if the first run, generate a useful config
if [ ! -f /srv/config/config.xml ]; then
  echo "Generating config..."
  /srv/syncthing/syncthing --generate="/srv/config"
  # don't take the whole volume with the default so that we can add additional folders
  sed -e "s/id=\"default\" path=\"\/root\/Sync\/\"/id=\"default\" path=\"\/srv\/data\/default\/\"/" -i /srv/config/config.xml
  # ensure we can see the web ui outside of the docker container
	sed -e "s/<address>127.0.0.1:8384/<address>0.0.0.0:${SYNCTHING_PORT}/" -i /srv/config/config.xml
fi

# allow user override on docker start
echo "Setting up syncthing user..."
usermod -u $UID $SYNCTHING_USER
usermod -g $GID $SYNCTHING_USER

# set permissions so that we have access to volumes
echo "Setting up permissions..."
chown -R $SYNCTHING_USER:$SYNCTHING_GROUP /srv/config /srv/data /srv/syncthing
chmod 770 /srv/config /srv/data

echo "Starting syncthing..."
gosu $SYNCTHING_USER /srv/syncthing/syncthing -home=/srv/config
