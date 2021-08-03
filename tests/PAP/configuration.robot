*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Setup     Ensure PAP stopped
Test Teardown  Restore PAP configuration

*** Test Cases ***

Missing configuration file
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Remove File  ${file}
  List Directory  ${T_PAP_CONF}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Missing Argus file
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  Remove File  ${file}
  List Directory  ${T_PAP_CONF}
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'
  [Teardown]  Restore PAP configuration

Required pool_interval
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Comment parameter  ${file}  poll_interval
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Syntax error: missing ']'
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_CONF_INI}
  Replace string  ${file}  \\[paps:properties\\]  \\[paps:properties
  Start PAP
  Execute and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Error exit codes (bug 65542)
  [Tags]  local
  ${output}=  Execute and Check Failure  ${T_PAP_CTRL} status

Status handler of PAP (bug 65802)
  [Tags]  local
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
  [Tags]  local
  Start PAP service
  ${output}=  Execute and Check Success  ss -tlnr sport eq 8150
  ${hostname}=  Get hostname
  ${ret}=  Should Match Regexp  ${output}  (\\*|::|0.0.0.0|${hostname}):8150
  Log  ${ret}

Port 8151 is listening on localhost (bug 75538)
  [Tags]  local
  Start PAP service
  ${output}=  Execute and Check Success  ss -tlnr sport eq 8151
  Should Contain  ${output}  localhost:8151

The proposed file-structure for is given (bug 77532)
  [Tags]  local
  ${file}=  Set Variable  /usr/sbin/papctl
  Check file  ${file}
  ${dir}=  Set Variable  /etc/argus/pap
  Check directory  ${dir}

Check PID file (bug 80510)
  [Tags]  local
  ${file}=  Set Variable  /var/run/argus-pap.pid
  Start PAP service
  Check File  ${file}