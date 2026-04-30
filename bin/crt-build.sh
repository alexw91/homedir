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

export CMAKE_CXX_FLAGS="-fdiagnostics-color=always"
export CMAKE_C_FLAGS="-fdiagnostics-color=always"
export CMAKE_COLOR_MAKEFILE=1
export CTEST_OUTPUT_ON_FAILURE=1

export SDK_INSTALL_DIR=${HOME}/workspace/aws-sdks/local-c-install
mkdir -p ${SDK_INSTALL_DIR}

cmake -DCMAKE_PREFIX_PATH=${SDK_INSTALL_DIR} -DCMAKE_INSTALL_PREFIX=${SDK_INSTALL_DIR} -DBUILD_SHARED_LIBS=ON -DBUILD_DEPS=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo ../

make -j $(sysctl -n hw.ncpu) 2>&1 | tee build_make.txt
ctest --output-on-failure -j$(sysctl -n hw.ncpu) | tee build_test.txt
make install -j $(sysctl -n hw.ncpu)

# Print list of slowest tests
grep -Eo "s2n_.*" build_test.txt | grep Passed | sort -g -t ' ' -k 6 | tail -15

# Auto-format any locally modified .c and .h files
#git diff --name-only --diff-filter=M HEAD | grep -E '\.[ch]$' | xargs -r clang-format -i

RED='\033[1;31m'
GREEN='\033[1;32m'
NO_COLOR='\033[0m'
SDK_PROJECT_NAME=`basename $(dirname "$PWD")`
GIT_BRANCH_NAME=`git status | head -1`

printf "${GREEN}Build Done: ${SDK_PROJECT_NAME} @ ${GIT_BRANCH_NAME} ${NO_COLOR}\n"
