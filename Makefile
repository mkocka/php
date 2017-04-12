.PHONY: build run test

IMAGE_NAME=php
VERSION=7

build:
	docker build --tag=$(IMAGE_NAME):$(VERSION) .
	
run: build
	docker run -d -p 8080:8080 $(IMAGE_NAME)

test: build
	./run-test.sh
