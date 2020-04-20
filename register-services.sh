#!/bin/bash

curl -X PUT -d @consul.d/services/hello-server.json \
    "http://localhost:8500/v1/agent/service/register"

curl -X PUT -d @consul.d/services/world-server-legacy.json \
    "http://localhost:8500/v1/agent/service/register"

curl -X PUT -d @consul.d/services/client.json \
    "http://localhost:8500/v1/agent/service/register"