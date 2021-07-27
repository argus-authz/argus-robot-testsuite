#!/bin/bash
set -ex

# the igi-test-ca was installed during image building, but mounting
# the /etc/grid-security/certificates volume overwrites the contents
# of that directory
sudo yum -y reinstall igi-test-ca
#sudo update-ca-trust

export T_PDP_ADMIN_PASSWORD=${T_PDP_ADMIN_PASSWORD:-"pdpadmin_password"}

mkdir -p /tmp/reports
cd /home/test/argus-testsuite
REPORTS_DIR="/tmp/reports" ./run-testsuite.sh "$@"