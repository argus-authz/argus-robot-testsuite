*** Settings ***
Resource   lib/utils.robot

Suite Setup  Open Connection And Log In
Suite Teardown  Close All Connections

#Suite Setup     Make backup of the configuration
#Suite Teardown  Restore configurations

*** Test Cases ***
PDP status
  [Tags]  local
  Ensure PDP running
  ${cmd}=  Set Variable  ${T_PDP_CTRL} status | grep -q "Status: OK"
  Execute and Check Success  ${cmd}

Error exit codes (bug 65542)
  [Tags]  local
  Ensure PDP stopped
  Execute and Check Failure  ${T_PDP_CTRL} status

XACML SOAP handler error (bug 75860)
  [Tags]  local
  Ensure PAP running
  Ensure PDP running
  ${cmd}=  Set Variable  echo "POST /authz" | openssl s_client -connect `hostname`:8152 -quiet
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  soap11:Fault

The proposed file-structure for is given (bug 77532)
  [Tags]  local
  ${file}=  Set Variable  /usr/sbin/pdpctl
  Check file  ${file}
  ${dir}=  Set Variable  /etc/argus/pdp
  Check directory  ${dir}

Check PID file (bug 80510)
  [Tags]  local
  ${file}=  Set Variable  /var/run/argus-pdp.pid
  Ensure PDP running
  Check File  ${file}