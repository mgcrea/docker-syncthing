# docker-syncthing [![Docker Pulls](https://img.shields.io/docker/pulls/mgcrea/syncthing.svg)](https://registry.hub.docker.com/u/mgcrea/syncthing/)

Run syncthing from a docker container

## Install
```sh
docker pull mgcrea/syncthing
```

## Usage

```sh
docker run -d --restart=always \
  -v /srv/sync:/srv/data \
  -v /srv/syncthing:/srv/config \
  -p 22000:22000  -p 21025:21025/udp -p 8080:8080 \
  --name syncthing \
  mgcrea/syncthing
```

```sh
docker-compose up -d
```

If you want to add a new folder, make sure you set the path to something in `/srv/data`.

**NOTE**: for security reasons, starting this docker container will change the permissions of all files in your data directory to a new, docker-only user. This ensures that the docker container can access the files.
