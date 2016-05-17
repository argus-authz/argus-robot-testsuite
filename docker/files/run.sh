#!/bin/bash

function wait_for_service() {
	start_ts=$(date +%s)
	host=$1
	port=$2
	timeout=$3
	sleeped=0
	while true; do
	    (echo > /dev/tcp/$host/$port) >/dev/null 2>&1
	    result=$?
	    if [[ $result -eq 0 ]]; then
	        end_ts=$(date +%s)
	        echo "$host:$port is available after $((end_ts - start_ts)) seconds"
	        break
	    fi
	    echo "Waiting"
	    sleep 5
	
	    sleeped=$((sleeped+5))
	    if [ $sleeped -ge $timeout  ]; then
	    	echo "Timeout!"
	    	exit 1
		fi
	done
}


set -ex

CERT_DIR="/usr/share/igi-test-ca"
GLOBUS_DIR="/home/tester/.globus"

TESTSUITE_REPO="${TESTSUITE_REPO:-https://github.com/marcocaberletti/argus-robot-testsuite.git}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"
OUTPUT_REPORTS="${OUTPUT_REPORTS:-reports}"
PAP_PORT="${PAP_PORT:-8150}"
PDP_PORT="${PDP_PORT:-8152}"
PEP_PORT="${PEP_PORT:-8154}"

T_PDP_ADMIN_PASSWORD="${T_PDP_ADMIN_PASSWORD:-pdpadmin_password}"

export T_PDP_ADMIN_PASSWORD

## Copy user certificates in default directory
mkdir $GLOBUS_DIR

cp $CERT_DIR/test0.cert.pem $GLOBUS_DIR/usercert.pem
chmod 644 $GLOBUS_DIR/usercert.pem

echo pass > $GLOBUS_DIR/password
openssl rsa -in $CERT_DIR/test0.key.pem -out $GLOBUS_DIR/userkey.pem -passin file:$GLOBUS_DIR/password
chmod 400 $GLOBUS_DIR/userkey.pem

chown -R tester:tester $GLOBUS_DIR/


## Clone testsuite code
echo "Clone argus-robot-testsuite repository ..."
git clone $TESTSUITE_REPO

pushd /home/tester/argus-robot-testsuite

echo "Switch branch ..."
git checkout $TESTSUITE_BRANCH

## Edit configuration
sed -i '/^T_PAP_HOST.*/d' env_config.py
sed -i '/^T_PDP_HOST.*/d' env_config.py
sed -i '/^T_PEP_HOST.*/d' env_config.py

echo "T_PAP_HOST='$PAP_HOST'" >> env_config.py
echo "T_PDP_HOST='$PDP_HOST'" >> env_config.py
echo "T_PEP_HOST='$PEP_HOST'" >> env_config.py

## Wait for services
echo "Wait for PAP"
wait_for_service $PAP_HOST $PAP_PORT 300
echo "PAP is ready. Wait for PDP"
wait_for_service $PDP_HOST $PDP_PORT 300
echo "PDP is ready. Wait for PEP"
wait_for_service $PEP_HOST $PEP_PORT 300
echo "PEP is ready."


## Run
echo "Run ..."
pybot --pythonpath .:lib  -d $OUTPUT_REPORTS --include=remote tests/

echo "Done."
