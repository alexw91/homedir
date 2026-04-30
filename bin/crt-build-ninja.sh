#!/bin/bash

set -ex
set -o pipefail

rm -rf build
mkdir -p build
cd build

#export PATH=/usr/lib/go-1.22/bin/:${PATH}

export CMAKE_CXX_FLAGS="-fdiagnostics-color=always"
export CMAKE_C_FLAGS="-fdiagnostics-color=always"
export CMAKE_COLOR_MAKEFILE=1
export CTEST_OUTPUT_ON_FAILURE=1

export SDK_INSTALL_DIR=${HOME}/workspace/aws-sdks/local-c-install
mkdir -p ${SDK_INSTALL_DIR}

# Ninja
cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=${SDK_INSTALL_DIR} -DCMAKE_VERBOSE_MAKEFILE=1 ../

ninja run_tests | GREP_COLOR='1;31' grep --color=always -E "^.*Failure$|$"
rm ../awslcTestTmpFile*

ninja install

RED='\033[1;31m'
GREEN='\033[1;32m'
NO_COLOR='\033[0m'
SDK_PROJECT_NAME=`basename $(dirname "$PWD")`
GIT_BRANCH_NAME=`git status | head -1`

printf "${GREEN}Build Done: ${SDK_PROJECT_NAME} @ ${GIT_BRANCH_NAME} ${NO_COLOR}\n"
