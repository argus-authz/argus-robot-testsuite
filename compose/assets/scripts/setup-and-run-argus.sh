#!/bin/bash

set -xe

#yum downgrade -y java-1.8.0-openjdk java-1.8.0-openjdk-headless 

TEST_CA_REPO_URL=${TEST_CA_REPO_URL:-https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo}
EGI_TRUSTANCHORS_REPO_URL=${EGI_TRUSTANCHORS_REPO_URL:-http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo}

VGRID02_LSC=${VGRID02_LSC:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc}
TESTVO_VOMSES=${TESTVO_VOMSES:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses}

wget ${TEST_CA_REPO_URL} -O /etc/yum.repos.d/test-ca.repo
wget ${EGI_TRUSTANCHORS_REPO_URL} -O /etc/yum.repos.d/EGI-trustanchors.repo

yum install -y ca-policy-egi-core

# Setup host certificate
cp /certs/__cnaf_test.cert.pem /etc/grid-security/hostcert.pem
cp /certs/__cnaf_test.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Setup services configuration
sed -i -e "s#pap.example.id#${HOSTNAME}#g" /etc/argus/pap/pap_configuration.ini
sed -i -e "s#localhost#${HOSTNAME}#g" /etc/argus/pap/pap_configuration.ini

sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini
sed -i -e "s#8153#8153\nadminHost = 0.0.0.0#g" /etc/argus/pdp/pdp.ini
sed -i -e "s#argus-pap.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini

sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pepd/pepd.ini

cp /files/policy-test.info /etc/grid-security/certificates/policy-test.info
echo -e '\n/test.vo file:policy-test.info' >> /etc/argus/pepd/vo-ca-ap-file

mkdir -p /etc/grid-security/vomsdir/test.vo/ /etc/vomses/
wget ${VGRID02_LSC} -O /etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc
wget ${TESTVO_VOMSES} -O /etc/vomses/test.vo.vomses
touch /etc/grid-security/voms-grid-mapfile

cp /files/groupmapfile /etc/grid-security/groupmapfile
cp /files/grid-mapfile /etc/grid-security/grid-mapfile
mkdir -p /etc/grid-security/gridmapdir

sh /scripts/start-argus.sh