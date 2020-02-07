#!/usr/bin/env bash

# Helper script for building the following AWS Common Runtime Projects
#  - https://github.com/awslabs/aws-c-http
#  - https://github.com/awslabs/aws-c-mqtt
#  - https://github.com/awslabs/aws-c-io
#  - https://github.com/awslabs/aws-c-cal
#  - https://github.com/awslabs/aws-c-common

set -e

rm -rf build
mkdir -p build
cd build

export SDK_INSTALL_DIR=${HOME}/workspace/aws-sdks/local-c-install
cmake -DCMAKE_PREFIX_PATH=${SDK_INSTALL_DIR} -DCMAKE_INSTALL_PREFIX=${SDK_INSTALL_DIR} -DBUILD_SHARED_LIBS=ON -DBUILD_DEPS=OFF -DCMAKE_BUILD_TYPE=Debug ../

make -j 32
make test
make install


RED='\033[1;31m'
GREEN='\033[1;32m'
NO_COLOR='\033[0m'
SDK_PROJECT_NAME=`basename $(dirname "$PWD")`
GIT_BRANCH_NAME=`git status | head -1`

printf "${GREEN}Build Done: ${SDK_PROJECT_NAME} @ ${GIT_BRANCH_NAME} ${NO_COLOR}\n"
