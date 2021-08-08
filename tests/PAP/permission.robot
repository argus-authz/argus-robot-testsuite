*** Settings ***
Resource   lib/utils.robot

Suite Setup  Run Keywords  Open Connection And Log In  AND  Make backup of the configuration
Suite Teardown  Run Keywords  
  ...           Restore configurations  AND
  ...           Ensure PAP running  AND
  ...           Close All Connections

Test Setup     Ensure PAP stopped
Test Teardown  Restore PAP configuration



*** Test Cases ***
Argus syntax error: missing ']'
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  Replace string  ${file}  \\[dn\\]  \\[dn
  Start PAP
  Execute Command and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Argus syntax error: missing ':'
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 6
  Create File on Server  ${file}  ${content}
  Start PAP
  Execute Command and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'

Argus syntax error: missing 'permission'
  [Tags]  local
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 7
  Create File on Server  ${file}  ${content}
  Start PAP
  Execute Command and Check Failure  ${T_PAP_CTRL} status | grep -q 'PAP running'


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
