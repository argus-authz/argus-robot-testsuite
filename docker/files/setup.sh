#!/bin/bash

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh

puppet apply --detailed-exitcodes --modulepath=/opt/argus-mw-devel:/etc/puppetlabs/code/environments/production/modules /files/manifest.pp

if [ $? == 4 ] || [ $? == 6 ]; then
  echo "Puppet apply exited with $?"
  exit 1
else
  echo "Puppet apply exited with $?"
fi

# Add tester user
adduser -d /home/tester tester

exit 0