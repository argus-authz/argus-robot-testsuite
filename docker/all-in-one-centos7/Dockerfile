FROM centos:7

# Allow customization of test user ID and name
ARG TEST_USER=test
ARG TEST_USER_UID=501

ARG UMD_RELEASE_PACKAGE_URL=http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm

COPY files/provide_robotframework.sh /tmp/scripts/

RUN echo "include_only=.garr.it,.cern.ch" >> /etc/yum/pluginconf.d/fastestmirror.conf && \
  yum install -y wget sudo openssh-server epel-release ${UMD_RELEASE_PACKAGE_URL} && \
  wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo && \
  yum install -y argus-authz igi-test-ca \
  python36 python36-devel python36-setuptools && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  adduser --uid ${TEST_USER_UID} ${TEST_USER} && \
  echo ${TEST_USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${TEST_USER} && \
  chmod 0440 /etc/sudoers.d/${TEST_USER} && \
  bash /tmp/scripts/provide_robotframework.sh && \
  rm -rf /tmp/scripts

ENV container=docker

# Layer: Argus
EXPOSE 8150
EXPOSE 8151
EXPOSE 8152
EXPOSE 8153
EXPOSE 8154
EXPOSE 8155

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]