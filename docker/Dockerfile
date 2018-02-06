FROM docker.io/centos:latest

# Layer: base
RUN yum install -y https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum install -y puppet git wget epel-release redhat-lsb iproute && \
    yum clean all

RUN /opt/puppetlabs/bin/puppet module install --force puppetlabs-stdlib && \
    /opt/puppetlabs/bin/puppet module install --force maestrodev-wget && \
    /opt/puppetlabs/bin/puppet module install --force stahnma-epel

# Layer: Argus
RUN useradd -ms /bin/bash tester
COPY files/run.sh /home/tester/
RUN chown tester:tester /home/tester/run.sh

RUN git clone git://github.com/cnaf/ci-puppet-modules.git /opt/ci-puppet-modules && \
    git clone https://github.com/argus-authz/argus-mw-devel /opt/argus-mw-devel

COPY files/manifest.pp /

RUN /opt/puppetlabs/bin/puppet apply --modulepath=/opt/ci-puppet-modules/modules:/opt/argus-mw-devel:/etc/puppetlabs/code/environments/production/modules /manifest.pp && \
	grep -q 'failure: 0' /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml

WORKDIR /home/tester
USER tester

CMD /home/tester/run.sh
