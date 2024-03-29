#!/bin/bash

set -xe

# TEST_CA_REPO_URL=${TEST_CA_REPO_URL:-https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo}
# wget ${TEST_CA_REPO_URL} -O /etc/yum.repos.d/test-ca.repo

VGRID02_LSC=${VGRID02_LSC:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc}
TESTVO_VOMSES=${TESTVO_VOMSES:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses}

# Setup host certificate
cp /certs/__cnaf_test.cert.pem /etc/grid-security/hostcert.pem
cp /certs/__cnaf_test.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Setup services configuration
sed -i -e "s#pap.example.id#${HOSTNAME}#g" /etc/argus/pap/pap_configuration.ini
sed -i -e "s#localhost#${HOSTNAME}#g" /etc/argus/pap/pap_configuration.ini

sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini
if ! grep -q adminHost /etc/argus/pdp/pdp.ini; then
    sed -i -e "s#8153#8153\nadminHost = 0.0.0.0#g" /etc/argus/pdp/pdp.ini
fi
sed -i -e "s#argus-pap.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini

sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pepd/pepd.ini
sed -i -e "s#\/etc\/argus\/pepd\/vo-ca-ap-file#\/etc\/grid-security\/vo-ca-ap-file#g" /etc/argus/pepd/pepd.ini

# set DEBUG log to pepd service
sed -i -e "s#\"INFO\"#\"DEBUG\"#g" /etc/argus/pepd/logging.xml

cp /files/policy-test.info /etc/grid-security/certificates/policy-test.info
cp /files/vo-ca-ap-file /etc/grid-security/vo-ca-ap-file

mkdir -p /etc/grid-security/vomsdir/test.vo/ /etc/vomses/
wget ${VGRID02_LSC} -O /etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc
wget ${TESTVO_VOMSES} -O /etc/vomses/test.vo.vomses
touch /etc/grid-security/voms-grid-mapfile

cp /files/groupmapfile /etc/grid-security/groupmapfile
cp /files/grid-mapfile /etc/grid-security/grid-mapfile
mkdir -p /etc/grid-security/gridmapdir

# Setup SSHD to support local tests
systemctl start sshd

# Setup ssh authorized keys for root user
mkdir -p /root/.ssh 
cat /certs/id_rsa.pub > /root/.ssh/authorized_keys
chmod 700 /root/.ssh/; chmod 600 /root/.ssh/authorized_keys
