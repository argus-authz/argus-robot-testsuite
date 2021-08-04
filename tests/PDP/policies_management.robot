*** Settings ***
Resource   lib/utils.robot

*** Test Cases ***


Reload policy on PDP
  [Tags]  remote
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  ${password}=  Resolve PDP admin password
  ${cmd}=  Set Variable  curl -sGv http://${T_PDP_HOST}:${T_PDP_ADMIN_PORT}/reloadPolicy?password=${password}
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  HTTP/1.1 200 OK

Reload policy on PDP with wrong password
  [Tags]  remote
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  ${cmd}=  Set Variable  curl -sGv http://${T_PDP_HOST}:${T_PDP_ADMIN_PORT}/reloadPolicy?password=wrong_password
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  HTTP/1.1 401 Unauthorized


*** Keywords ***

Prepare policy file
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action "ANY" {
  ...      rule permit { subject="CN=test0,O=IGI,C=IT" }
  ...    }
  ...  }
  ...
  ...  resource "resource_2" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action "ANY" {
  ...      rule deny { subject="CN=test0,O=IGI,C=IT" }
  ...    }
  ...  }
  Create policy file  ${policy}
