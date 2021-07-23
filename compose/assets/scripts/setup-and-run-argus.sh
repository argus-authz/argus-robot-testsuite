#!/bin/bash

set -xe

wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo
yum reinstall -y igi-test-ca

wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo -O /etc/yum.repos.d/EGI-trustanchors.repo
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
sed -i -e "s#argus-pap.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini
sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pepd/pepd.ini

mkdir -p /etc/grid-security/vomsdir/test.vo/ /etc/vomses/
wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc -O /etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc
wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses -O /etc/vomses/test.vo.vomses
touch /etc/grid-security/voms-grid-mapfile

touch /etc/grid-security/grid-mapfile
touch /etc/grid-security/groupmapfile
mkdir -p /etc/grid-security/gridmapdir

sh /scripts/start-argus.sh