#!/bin/bash
set -ex

# the igi-test-ca was installed during image building, but mounting
# the /etc/grid-security/certificates volume overwrites the contents
# of that directory
sudo yum -y reinstall igi-test-ca

mkdir -p $HOME/.ssh 
cp -f /certs/id_rsa* $HOME/.ssh
chown test:test $HOME/.ssh/id_rsa*
chmod 700 $HOME/.ssh/; chmod 400 $HOME/.ssh/id_rsa

voms-proxy-init --voms test.vo

export T_PDP_ADMIN_PASSWORD=${T_PDP_ADMIN_PASSWORD:-"pdpadmin_password"}

mkdir -p /tmp/reports
cd /home/test/argus-testsuite
REPORTS_DIR="/tmp/reports" OUT_FILE="output-remote.xml" LOG_FILE="log-remote.html" REPORT_FILE="report-remote.html" \
   DEFAULT_EXCLUDES="--include remote" ./run-testsuite.sh "$@"

ssh -o 'StrictHostKeyChecking=no' root@argus-centos7.cnaf.test \
    'cd /root/argus-testsuite; \
     REPORTS_DIR="/tmp/reports" OUT_FILE="output-local.xml" LOG_FILE="log-local.html" REPORT_FILE="report-local.html" \
     DEFAULT_EXCLUDES="--exclude remote" ./run-testsuite.sh "$@"'