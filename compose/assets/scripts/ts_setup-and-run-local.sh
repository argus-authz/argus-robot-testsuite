#!/bin/bash

set -xe

VGRID02_LSC=${VGRID02_LSC:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc}
TESTVO_VOMSES=${TESTVO_VOMSES:-https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses}

# Setup host certificate
cp /certs/__cnaf_test.cert.pem /etc/grid-security/hostcert.pem
cp /certs/__cnaf_test.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Setup services configuration
sed -i -e "s#pap.example.id#${HOSTNAME}#g" /etc/argus/pap/pap_configuration.ini

sed -i -e "s#argus.example.org#${HOSTNAME}#g" /etc/argus/pdp/pdp.ini
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

sh /scripts/ts_start-argus.sh

cd /home/test/argus-testsuite/
export PATH=$PATH:/usr/local/bin
sh /scripts/ci-run-testsuite.sh
