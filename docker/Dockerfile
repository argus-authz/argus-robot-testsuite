FROM centos:7

ARG TEST_USER=test
ARG TEST_USER_UID=501

ENV TEST_USER $TEST_USER
ENV TEST_USER_UID $TEST_USER_UID

COPY files/*.sh /tmp/scripts/
COPY files/argus_el7.repo /etc/yum.repos.d/

RUN    yum install -y wget epel-release \
    && wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo \
    && yum -y install sudo \
       igi-test-ca voms-clients-java myproxy \
       argus-pap argus-pepcli argus-pdp \
       python36 python36-devel python36-setuptools \
    && rm -rf /var/cache/yum \
    && mkdir -p /etc/grid-security/vomsdir/test.vo/ /etc/vomses/ \
    && wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc -O /etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc \
    && wget https://raw.githubusercontent.com/italiangrid/voms-testsuite/master/compose/assets/vomses/test.vo.vomses -O /etc/vomses/test.vo.vomses \
    && adduser --uid ${TEST_USER_UID} ${TEST_USER} \
    && echo ${TEST_USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${TEST_USER} \
    && chmod 0440 /etc/sudoers.d/${TEST_USER} \
    && mkdir /home/${TEST_USER}/.config /home/${TEST_USER}/.globus \
    && cp /usr/share/igi-test-ca/test0.p12 /home/${TEST_USER}/.globus/usercred.p12 \
    && chmod 600 /home/${TEST_USER}/.globus/usercred.p12 \
    && chown -R ${TEST_USER}:${TEST_USER} /home/${TEST_USER} \
    && openssl pkcs12 -passin pass:pass -in /home/${TEST_USER}/.globus/usercred.p12 -clcerts -nokeys -out /home/${TEST_USER}/.globus/usercert.pem \
    && openssl pkcs12 -passin pass:pass -passout pass:pass -in /home/${TEST_USER}/.globus/usercred.p12 -nocerts -out /home/${TEST_USER}/.globus/userkey.pem \
    && openssl rsa -in /home/${TEST_USER}/.globus/userkey.pem -out /home/${TEST_USER}/.globus/userkey.pem -passin pass:pass \
    && chmod 400 /home/${TEST_USER}/.globus/userkey.pem \
    && chmod 644 /home/${TEST_USER}/.globus/usercert.pem \
    && chown ${TEST_USER}:${TEST_USER} /home/${TEST_USER}/.globus/* \
    && bash /tmp/scripts/provide_robotframework.sh \
    && rm -rf /tmp/scripts

USER ${TEST_USER}
WORKDIR /home/${TEST_USER}