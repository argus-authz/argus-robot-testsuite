*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Setup     Ensure PAP stopped
Test Teardown  Restore PAP configuration


*** Variables ***
${PRINCIPAL_WITH_COLON}  CN=Robot:argo-egi@cro-ngi.hr, O=SRCE, O=Robots, C=HR, DC=EGI, DC=EU
${PERMISSIONS}           POLICY_READ_LOCAL|POLICY_READ_REMOTE|CONFIGURATION_READ


*** Test Cases ***
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

Add permission with colon into principal
  Ensure PAP running
  Execute and Check Success  pap-admin add-ace "${PRINCIPAL_WITH_COLON}" '${PERMISSIONS}'
  ${output}=  Execute and Check Success  pap-admin list-acl
  Restart PAP service


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
