*** Settings ***
Resource   lib/utils.robot

Test Teardown  Cleanup  host=${T_PAP_HOST}

*** Test Cases ***

Test permit rule
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_1  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Permit

Test deny rule
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_2  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny

Test not applicable rule
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_3  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Not Applicable

Test ban/unban user by subject
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  Ban by subject  ${TEST_USER_DN}  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_1  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_2  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_3  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  Un-ban by subject  ${TEST_USER_DN}  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_1  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Permit
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_2  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_3  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Not Applicable

Test ban/unban user by FQAN
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  Ban by FQAN  ${TEST_FQAN}  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_1  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_2  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_3  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  Un-ban by FQAN  ${TEST_FQAN}  host=${T_PAP_HOST}
  Reload policy  host=${T_PDP_HOST}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_1  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Permit
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_2  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Deny
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  resource_3  ANY  host=${T_PEP_HOST}
  Should Contain  ${output}  Decision: Not Applicable

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
