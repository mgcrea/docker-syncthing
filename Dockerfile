FROM ubuntu:16.04
MAINTAINER Olivier Louvignes <olivier@mgcrea.io>

RUN apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && apt-get install curl ca-certificates wget -y --no-install-recommends \
  && apt-get autoremove -y \
  && apt-get clean

ARG IMAGE_VERSION
ENV IMAGE_VERSION ${IMAGE_VERSION:-1.0.0}
ENV UID 1027
ENV GID 100

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -ex; \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu nobody true;

# grab syncthing
ENV SYNCTHING_VERSION ${IMAGE_VERSION}
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='amd64';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/syncthing-linux-${ARCH}-v${IMAGE_VERSION}.tar.gz" \
  && curl -SLO --compressed "https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/sha256sum.txt.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys D26E6ED000654A3E \
  && gpg --batch --decrypt --output sha256sum.txt sha256sum.txt.asc \
  && grep " syncthing-linux-${ARCH}-v${IMAGE_VERSION}.tar.gz\$" sha256sum.txt | sha256sum -c - \
  && tar -xzf "syncthing-linux-${ARCH}-v${IMAGE_VERSION}.tar.gz" -C /usr/local/bin --strip-components=1 "syncthing-linux-${ARCH}-v${IMAGE_VERSION}/syncthing" \
  && rm "syncthing-linux-${ARCH}-v${IMAGE_VERSION}.tar.gz" sha256sum.txt.asc sha256sum.txt

ENV SYNCTHING_USER syncthing
ENV SYNCTHING_GROUP users
RUN useradd --no-create-home -g ${SYNCTHING_GROUP} --uid ${UID} ${SYNCTHING_USER}

ENV SYNCTHING_PORT 8384
EXPOSE $SYNCTHING_PORT

WORKDIR /srv
RUN mkdir -p /srv/data /srv/config
VOLUME ["/srv/data", "/srv/config"]

ADD ./files/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 770 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

