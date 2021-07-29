#!/bin/bash
set -ex

# the igi-test-ca was installed during image building, but mounting
# the /etc/grid-security/certificates volume overwrites the contents
# of that directory
sudo yum -y reinstall igi-test-ca

mkdir -p $HOME/.ssh 
cp /files/id_rsa* $HOME/.ssh
chown test:test $HOME/.ssh/id_rsa*
chmod 700 $HOME/.ssh/; chmod 400 $HOME/.ssh/id_rsa

#ssh -o 'StrictHostKeyChecking=no' root@argus-centos7.cnaf.test echo -e 'Hello from argus server: `pwd`'

export T_PDP_ADMIN_PASSWORD=${T_PDP_ADMIN_PASSWORD:-"pdpadmin_password"}

mkdir -p /tmp/reports
cd /home/test/argus-testsuite
REPORTS_DIR="/tmp/reports" ./run-testsuite.sh "$@"