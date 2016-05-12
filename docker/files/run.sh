#!/bin/bash

set -ex

CERT_DIR="/usr/share/igi-test-ca"
GLOBUS_DIR="/home/tester/.globus"
TESTSUITE_REPO="${TESTSUITE_REPO:-https://github.com/marcocaberletti/argus-robot-testsuite.git}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"

## Copy user certificates in default directory
mkdir $GLOBUS_DIR

cp $CERT_DIR/test0.cert.pem $GLOBUS_DIR/usercert.pem
chmod 644 $GLOBUS_DIR/usercert.pem

echo pass > $GLOBUS_DIR/password
openssl rsa -in /$CERT_DIR/test0.key.pem -out $GLOBUS_DIR/userkey.pem -passin file:$GLOBUS_DIR/password
chmod 400 $GLOBUS_DIR/userkey.pem

chown -R tester:tester $GLOBUS_DIR/


## Clone testsuite code
echo "Clone argus-robot-testsuite repository ..."
git clone $TESTSUITE_REPO

echo "Switch branch ..."
pushd /home/tester/argus-robot-testsuite
git checkout $TESTSUITE_BRANCH

## Edit configuration
sed -i '/^T_PAP_HOST.*/d' env_config.py
sed -i '/^T_PDP_HOST.*/d' env_config.py
sed -i '/^T_PEP_HOST.*/d' env_config.py

echo "T_PAP_HOST='$PAP_HOST'" >> env_config.py
echo "T_PDP_HOST='$PDP_HOST'" >> env_config.py
echo "T_PEP_HOST='$PEP_HOST'" >> env_config.py

echo "Run ..."
pybot --pythonpath .:lib  -d reports --include=remote tests/

echo "Done."
