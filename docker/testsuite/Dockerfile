FROM centos:7

ARG TEST_USER=test
ARG TEST_USER_UID=501

ENV TEST_USER $TEST_USER
ENV TEST_USER_UID $TEST_USER_UID

COPY files/*.sh /tmp/scripts/
COPY files/argus_el7.repo /etc/yum.repos.d/

RUN    yum install -y wget sudo epel-release \
    && wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo \
    && yum -y install igi-test-ca voms-clients-java myproxy \
       argus-pap argus-pdp argus-pep-server argus-pepcli \
       python36 python36-devel python36-setuptools \
    && rm -rf /var/cache/yum \
    && cat /etc/grid-security/certificates/igi-test-ca.pem >> /etc/pki/tls/certs/ca-bundle.crt \
    && mkdir -p /etc/grid-security/vomsdir/test.vo/ /etc/vomses/ \
    && wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc -O /etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc \
    && wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses -O /etc/vomses/test.vo.vomses \
    && adduser --uid ${TEST_USER_UID} ${TEST_USER} \
    && echo ${TEST_USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${TEST_USER} \
    && chmod 0440 /etc/sudoers.d/${TEST_USER} \
    && bash /tmp/scripts/setup_user_certificate.sh \
    && bash /tmp/scripts/provide_robotframework.sh \
    && rm -rf /tmp/scripts

USER ${TEST_USER}
WORKDIR /home/${TEST_USER}