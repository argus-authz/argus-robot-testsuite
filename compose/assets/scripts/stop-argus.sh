#!/bin/bash

function wait_for_service() {
	local start_ts=$(date +%s)
	local host=$1
	local port=$2
	local timeout=$3
	local sleeped=0
	while true; do
	    (echo > /dev/tcp/$host/$port) >/dev/null 2>&1
	    result=$?
	    if [[ $result -eq 1 ]]; then
	        end_ts=$(date +%s)
	        echo "$host:$port is down after $((end_ts - start_ts)) seconds"
	        break
	    fi
	    echo "Waiting"
	    sleep 5
	
	    sleeped=$((sleeped+5))
	    if [ $sleeped -ge $timeout ]; then
	    	echo "Timeout!"
	    	exit 1
		fi
	done
}

set -xe

PAP_PORT="${PAP_PORT:-8150}"
PDP_PORT="${PDP_PORT:-8152}"
PEP_PORT="${PEP_PORT:-8154}"
TIMEOUT="${TIMEOUT:-300}"

## Wait for services and stop
systemctl stop argus-pepd
echo "Wait for PEP"
set +e
#wait_for_service ${HOSTNAME} ${PEP_PORT} ${TIMEOUT}
set -e
echo "PEP is down. Stop PDP"


systemctl stop argus-pdp
echo "Wait for PDP"
set +e
wait_for_service ${HOSTNAME} ${PDP_PORT} ${TIMEOUT}
set -e
echo "PDP is down. Stop PEP"

systemctl stop argus-pap
echo "Wait for PAP"
set +e
wait_for_service ${HOSTNAME} ${PAP_PORT} ${TIMEOUT}

set -e
echo "PAP is down"