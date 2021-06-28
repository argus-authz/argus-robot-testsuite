FROM centos:7

RUN \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 && \
  rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-Testing-7 && \
  yum clean all && \
  yum --enablerepo=centosplus install -y deltarpm epel-release redhat-lsb

ENV PATH="/opt/puppetlabs/bin:${PATH}"

# Install utils
RUN yum install -y wget git 

# Install Puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm && \
  yum install -y puppet

RUN puppet --version

# Install specific version of puppetlabs-stdlib because latest v7 is not support by lots of modules
RUN puppet module install --force puppetlabs-stdlib --version 6.6.0

# Install Puppet modules
RUN puppet module install puppet-epel && \
    puppet module install puppet-fetchcrl && \
    puppet module install puppet-python && \
    puppet module install puppetlabs-java && \
    puppet module install cnafsd-voms && \
    puppet module install cnafsd-testca && \
    puppet module install cnafsd-umd4 

RUN git clone https://github.com/argus-authz/argus-mw-devel /opt/argus-mw-devel

COPY files/setup.sh /files/
COPY files/manifest.pp /files/

RUN sh /files/setup.sh

# Layer: Argus
WORKDIR /home/tester

USER tester

COPY files/run.sh /home/tester/

VOLUME /assets

CMD /home/tester/run.sh


