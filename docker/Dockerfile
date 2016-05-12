FROM docker.io/centos:latest

RUN useradd -ms /bin/bash tester

RUN rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

RUN yum update -y && \
    yum install -y puppet git epel-release redhat-lsb

RUN puppet module install --force puppetlabs-stdlib && \
    puppet module install --force maestrodev-wget

RUN git clone git://github.com/cnaf/ci-puppet-modules.git /opt/ci-puppet-modules

COPY files/manifest.pp /

RUN puppet apply --modulepath=/opt/ci-puppet-modules/modules:/etc/puppet/modules /manifest.pp

RUN wget --no-clobber -O /etc/yum.repos.d/argus_el7.repo https://github.com/argus-authz/repo/raw/gh-pages/yum/argus-beta-el7.repo

RUN yum makecache &&\
    yum install -y argus-pap argus-pepcli

WORKDIR /home/tester
USER tester

COPY files/run.sh /home/tester/

CMD /home/tester/run.sh