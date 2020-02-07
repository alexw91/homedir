#!/usr/bin/env bash

# Helper Script for building https://github.com/aws/aws-sdk-java-v2

#mvn install -pl :apache-client,:netty-nio-client,:aws-crt-client -am
#mvn --projects http-clients -am install
#mvn clean install -f http-clients

mvn install -pl :aws-crt-client -am | tee sdk_output.txt

#mvn install -rf :aws-crt-client
#mvn clean install -pl :aws-crt-client -P quick --am
