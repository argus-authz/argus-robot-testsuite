#!/bin/bash
set -ex

mkdir -p $HOME/.ssh 
cp -f /certs/id_rsa* $HOME/.ssh
chown test:test $HOME/.ssh/id_rsa*
chmod 700 $HOME/.ssh/; chmod 400 $HOME/.ssh/id_rsa

voms-proxy-init --voms test.vo

export T_PDP_ADMIN_PASSWORD=${T_PDP_ADMIN_PASSWORD:-"pdpadmin_password"}

mkdir -p /tmp/reports
cd /home/test/argus-testsuite
