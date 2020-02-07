#!/usr/bin/env bash

# Helper script for building https://github.com/awslabs/aws-crt-java

set -e

ulimit -c unlimited


#rm -rf target

#mvn -B test -DreuseForks=false -Ddebug.native -DredirectTestOutputToFile=true
# mvn -B install -DreuseForks=false -Ddebug.native -DforkCount=0 -DredirectTestOutputToFile=true
mvn -B install -Ddebug-native | tee crt_build.txt
#mvn install

# Print any code formatting issues in red
sdk-format.sh
