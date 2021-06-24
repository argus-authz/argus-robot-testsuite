FROM italiangrid/storm-testsuite:nightly

# RUN yum install -y iproute && \
#    yum clean all

COPY files/run.sh /home/tester/
#RUN chown tester:tester /home/tester/run.sh

RUN git clone https://github.com/argus-authz/argus-mw-devel /opt/argus-mw-devel

COPY files/manifest.pp /

RUN /opt/puppetlabs/bin/puppet apply --modulepath=/opt/argus-mw-devel:/etc/puppetlabs/code/environments/production/modules /manifest.pp && \
	grep -q 'failure: 0' /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml

#WORKDIR /home/tester
#USER tester

CMD /home/tester/run.sh

