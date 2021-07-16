#!/bin/bash

CERT_DIR="/usr/share/igi-test-ca"
TEST_USER="test"
GLOBUS_DIR="/home/${TEST_USER}/.globus"

## Copy user certificates in default directory
mkdir /home/${TEST_USER}/.config ${GLOBUS_DIR}

cp ${CERT_DIR}/test0.cert.pem ${GLOBUS_DIR}/usercert.pem
chmod 644 ${GLOBUS_DIR}/usercert.pem

echo pass > ${GLOBUS_DIR}/password
openssl rsa -in ${CERT_DIR}/test0.key.pem -out ${GLOBUS_DIR}/userkey.pem -passin file:${GLOBUS_DIR}/password
chmod 400 ${GLOBUS_DIR}/userkey.pem

chown -R ${TEST_USER}:${TEST_USER} /home/${TEST_USER}