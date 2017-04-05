*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Setup     Ensure PAP stopped
Test Teardown  Restore PAP configuration

*** Test Cases ***

Missing configuration file
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Remove File  ${file}
  List Directory  ${T_PAP_CONF}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Missing Argus file
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  Remove File  ${file}
  List Directory  ${T_PAP_CONF}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'
  [Teardown]  Restore PAP configuration

Required pool_interval
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Comment parameter  ${file}  poll_interval
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Syntax error: missing ']'
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Replace string  ${file}  \\[paps:properties\\]  \\[paps:properties
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Argus syntax error: missing ']'
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  Replace string  ${file}  \\[dn\\]  \\[dn
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Argus syntax error: missing ':'
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 6
  Create File  ${file}  ${content}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Argus syntax error: missing 'permission'
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 7
  Create File  ${file}  ${content}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Error exit codes (bug 65542)
  ${output}=  Execute and Check Failure  ${T_PAP_CTRL} status

Status handler of PAP (bug 65802)
  [Setup]  Ensure PAP running
  Execute and Check Success  wget -O /tmp/pap_status http://localhost:${T_PAP_ADMIN_PORT}/status
  ${cmd}=  catenate
  ...  wget -O /tmp/pap_status
  ...  --certificate=/etc/grid-security/hostcert.pem
  ...  --private-key=/etc/grid-security/hostkey.pem
  ...  --ca-directory=/etc/grid-security/certificates
  ...  --no-check-certificate
  ...  https://`hostname`:8150/status
  Execute and Check Failure  ${cmd}

Port 8150 is listening on hostname (bug 75538)
  Start PAP service
  ${output}=  Execute and Check Success  ss -tlnr | grep 8150
  ${hostname}=  Get hostname
  ${ret}=  Should Match Regexp  ${output}  (::|0.0.0.0|${hostname}):8150
  Log  ${ret}

Port 8151 is listening on localhost (bug 75538)
  Start PAP service
  ${output}=  Execute and Check Success  ss -tlnr
  Should Contain  ${output}  localhost:8151

The proposed file-structure for is given (bug 77532)
  ${file}=  Set Variable  /usr/sbin/papctl
  Check file  ${file}
  ${dir}=  Set Variable  /etc/argus/pap
  Check directory  ${dir}

Check PID file (bug 80510)
  ${file}=  Set Variable  /var/run/argus-pap.pid
  Start PAP service
  Check File  ${file}

Config file is properly declared in the rpm (bug 81738)
  ${output}=  Execute and Check Success  rpm -qlc argus-pap
  Should Contain  ${output}  pap-admin.properties


*** Keywords ***
Get content test 6
  ${text}=  catenate  SEPARATOR=\n
  ...  [dn]
  ...  "/C=CH/O=CERN/OU=GD/CN=Test user 300"  ALL
  ...  "/DC=ch/DC=cern/OU=computers/CN=vtb-generic-54.cern.ch" : POLICY_READ_LOCAL|POLICY_READ_REMOTE
  ...
  ...  [fqan]
  [Return]  ${text}

Get content test 7
  ${text}=  catenate  SEPARATOR=\n
  ...  [dn]
  ...  "/C=CH/O=CERN/OU=GD/CN=Test user 300"
  ...  "/DC=ch/DC=cern/OU=computers/CN=vtb-generic-54.cern.ch" : POLICY_READ_LOCAL|POLICY_READ_REMOTE
  ...
  ...  [fqan]
  [Return]  ${text}

Start PAP
  Run Process  papctl  start
  Sleep  15s
