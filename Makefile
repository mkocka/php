.PHONY: build run test build-test

IMAGE_NAME=php

build:
	docker build --tag=$(IMAGE_NAME) .

run: build
	docker run -d -p 8080:8080 $(IMAGE_NAME)

build-test:
	docker build --tag=$(IMAGE_NAME)-candidate .

test: build-test
	./test/run
