FROM centos:7

ARG TEST_USER=test
ARG TEST_USER_UID=501

ENV TEST_USER $TEST_USER
ENV TEST_USER_UID $TEST_USER_UID

COPY files/*.sh /tmp/scripts/

RUN    yum install -y wget epel-release \
    && wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo \
    && yum -y install sudo \
       igi-test-ca voms-clients-java myproxy \
       python36 python36-devel python36-setuptools \
    && yum-config-manager --add-repo http://linuxsoft.cern.ch/wlcg/centos7/x86_64/ \
    && rpm --import http://repository.egi.eu/sw/production/umd/UMD-RPM-PGP-KEY \
    && yum install -y http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm \
    && yum install -y argus-authz \
    && yum remove -y argus-pap \
    && yum install -y https://ci.cloud.cnaf.infn.it/view/argus/job/pkg.argus/job/v1.7.4/lastSuccessfulBuild/artifact/artifacts/packages/centos7/RPMS/noarch/argus-pap-1.7.3-0.el7.noarch.rpm \
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
    && bash /tmp/scripts/provide_robotframework.sh \
    && rm -rf /tmp/scripts

USER ${TEST_USER}
WORKDIR /home/${TEST_USER}