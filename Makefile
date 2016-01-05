all: build

build:
	@docker build --tag=joeybaker/syncthing:latest .

base:
	@docker pull ubuntu:14.04

rebuild: base
	@docker build --tag=joeybaker/syncthing:latest .

release: rebuild
	@docker build --tag=joeybaker/syncthing:0.12.11 .
