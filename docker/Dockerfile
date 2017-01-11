FROM docker.io/centos:latest

# Layer: base
RUN yum install -y https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && \
    yum update -y && \
    yum install -y puppet git wget epel-release redhat-lsb iproute && \
    yum clean all && \
    puppet module install --force puppetlabs-stdlib && \
    puppet module install --force maestrodev-wget

# Layer: Argus
RUN useradd -ms /bin/bash tester
COPY files/run.sh /home/tester/
RUN chown tester:tester /home/tester/run.sh

RUN git clone git://github.com/cnaf/ci-puppet-modules.git /opt/ci-puppet-modules && \
    git clone https://github.com/argus-authz/argus-mw-devel /opt/argus-mw-devel

COPY files/manifest.pp /

RUN puppet apply --modulepath=/opt/ci-puppet-modules/modules:/opt/argus-mw-devel:/etc/puppet/modules /manifest.pp

WORKDIR /home/tester
USER tester

CMD /home/tester/run.sh