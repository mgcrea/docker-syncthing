all: build

build:
	@docker build --tag=mgcrea/syncthing:latest .

base:
	@docker pull ubuntu:14.04

rebuild: base
	@docker build --tag=mgcrea/syncthing:latest .

release: rebuild
	@docker build --tag=mgcrea/syncthing:0.12.15 .
