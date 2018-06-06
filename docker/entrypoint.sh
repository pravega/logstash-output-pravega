#!/bin/sh
#
# Copyright (c) 2018 Dell Inc., or its subsidiaries. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

set -ue
PRAVEGA_SCOPE=${PRAVEGA_SCOPE:-myscope}
PRAVEGA_STREAM=${PRAVEGA_STREAM:-apacheaccess}
PRAVEGA_ENDPOINT=${PRAVEGA_ENDPOINT:-tcp://localhost:9090}
sed -i 's|scope =>.*|scope => "'"${PRAVEGA_SCOPE}"'"|' /etc/logstash/conf.d/90-pravega-output.conf
sed -i 's|stream_name =>.*|stream_name => "'"${PRAVEGA_STREAM}"'"|' /etc/logstash/conf.d/90-pravega-output.conf
sed -i 's|pravega_endpoint =>.*|pravega_endpoint => "'"${PRAVEGA_ENDPOINT}"'"|' /etc/logstash/conf.d/90-pravega-output.conf

exec "$@"
