.PHONY: build build-7 run test

IMAGE_NAME=php

build: build-7

build-7:
	docker build --tag=$(IMAGE_NAME):7 .
run: build
	docker run -d $(IMAGE_NAME)
test: build
	./run-test.sh
