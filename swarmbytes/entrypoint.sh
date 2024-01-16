#!/bin/bash

if [ "$API_KEY" = "" ]; then
  echo "Missing API_KEY"
  exit 1
fi

if [ "$BIND_IPS" = "" ]; then
  echo "Missing BIND_IPS"
  exit 1
fi

if [ "$HTTP_PORT" = "" ]; then
  echo "Missing HTTP_PORT"
  exit 1
fi

if [ "$CHILD_SPAWN_DELAY" = "" ]; then
  echo "Missing CHILD_SPAWN_DELAY"
  exit 1
fi

mkdir /etc/swarmbytes/

cat > /etc/swarmbytes/config.yaml <<EOF
# Swarmbytes API key from your dashboard
api_key: "$API_KEY"

# A list of IP addresses, IP ranges or IP subnets (CIDRs)
# to bind Swarmbytes to. These IP addresses should be
# statically bound to the machine you run Swarmbytes on
# (e.g. using linux `ip` command)
bind_ips:
  - $BIND_IPS

# Port number which will be opened on each IP address
# for HTTP proxy communications
http_port: $HTTP_PORT

# Delay between sub-processes launches for
# each IP address (in milliseconds)
child_spawn_delay: $CHILD_SPAWN_DELAY
EOF

while ! swarmbytes
do
  sleep 1
  echo "Restarting swarmbytes application..."
done