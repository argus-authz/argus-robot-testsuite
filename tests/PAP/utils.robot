*** Settings ***
Resource   lib/utils.robot

*** Variables ***
${PRINCIPAL_WITH_COLON}  CN=Robot:argo-egi@cro-ngi.hr, O=SRCE, O=Robots, C=HR, DC=EGI, DC=EU
${PERMISSIONS}           POLICY_READ_LOCAL|POLICY_READ_REMOTE|CONFIGURATION_READ


*** Test Cases ***

Config file is properly declared in the rpm (bug 81738)
  [Tags]  cli
  ${output}=  Execute and Check Success  rpm -qlc argus-pap
  Should Contain  ${output}  pap-admin.properties

Add permission with colon into principal
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} add-ace "${PRINCIPAL_WITH_COLON}" '${PERMISSIONS}'
  ${output}=  Execute and Check Success  pap-admin list-acl
