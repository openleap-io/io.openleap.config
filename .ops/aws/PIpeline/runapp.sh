#!/usr/bin/env bash
echo 'Starting Spring Boot app'
cd '/home/ubuntu/app/archaius'
java -Dserver.port=80 -jar openleap-config.jar &
