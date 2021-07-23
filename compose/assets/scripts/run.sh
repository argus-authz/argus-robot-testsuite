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
	    if [[ $result -eq 0 ]]; then
	        end_ts=$(date +%s)
	        echo "$host:$port is available after $((end_ts - start_ts)) seconds"
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

TEST_CA_REPO_URL=${TEST_CA_REPO_URL:-https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo}

PAP_PORT=${PAP_PORT:-8150}
PDP_PORT=${PDP_PORT:-8152}
PEP_PORT=${PEP_PORT:-8154}
TIMEOUT=${TIMEOUT:-300}

T_PDP_ADMIN_PASSWORD=${T_PDP_ADMIN_PASSWORD:-pdpadmin_password}

export T_PDP_ADMIN_PASSWORD

# install igi-test-ca 
wget ${WGET_OPTIONS} ${TEST_CA_REPO_URL} -O /etc/yum.repos.d/igi-test-ca.repo

yum clean all
yum -y install igi-test-ca

# Setup host certificate
cp /certs/__cnaf_test.cert.pem /etc/grid-security/hostcert.pem
cp /certs/__cnaf_test.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem


## Wait for services and run
papctl start
echo "Wait for PAP"
set +e
wait_for_service ${HOSTNAME} ${PAP_PORT} ${TIMEOUT}

set -e
echo "PAP is ready. Start PDP"


pdpctl start
echo "Wait for PDP"
set +e
wait_for_service ${HOSTNAME} ${PDP_PORT} ${TIMEOUT}
set -e
echo "PDP is ready. Start for PEP"

pepdctl start
echo "Wait for PEP"
set +e
wait_for_service ${HOSTNAME} ${PEP_PORT} ${TIMEOUT}
set -e
echo "PEP is ready."