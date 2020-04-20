all: build

build:
	make -C hello-server/
	make -C world-server/
	make -C world-server-legacy/
	make -C hello-world-client/