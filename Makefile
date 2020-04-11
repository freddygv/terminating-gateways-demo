all: build

build:
	make -C hello-server/
	make -C world-server/
	make -C hello-world-client/