#!/bin/bash

echo "Starting agent"

DIR=$(cd "$(dirname "$0")"; pwd -P)
docker run -v $DIR/conf:/opt/spinnaker/config armory/kubesvc:0.3.0-rc.4 