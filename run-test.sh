# Script builds and run test application as docker container 

BUILDER_IMAGE=php:7
APP_NAME=my-app
SOURCE_REPO=./test/test-app

s2i build ${SOURCE_REPO} ${BUILDER_IMAGE} ${APP_NAME}
docker run -p 8080:8080 ${APP_NAME}
