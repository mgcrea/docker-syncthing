SYNCTHING_VERSION := 0.12.15

all: build

build:
	@docker build --build-arg SYNCTHING_VERSION=${SYNCTHING_VERSION} --tag=mgcrea/syncthing:latest .

base:
	@docker pull ubuntu:14.04

rebuild: base
	@docker build --build-arg SYNCTHING_VERSION=${SYNCTHING_VERSION} --tag=mgcrea/syncthing:latest .

release: rebuild
	@docker build --build-arg SYNCTHING_VERSION=${SYNCTHING_VERSION} --tag=mgcrea/syncthing:${SYNCTHING_VERSION} .
