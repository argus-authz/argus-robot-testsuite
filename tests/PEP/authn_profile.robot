*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Teardown  Restore PEP configuration

*** Keywords ***
Setup IOTA profile policies
  Remove all policies
  Add policy  ${TEST_RESOURCE}   ${TEST_ACTION}   permit   vo="${TEST_VO}" x509-authn-profile="policy-test-classic"
  Add policy  ${TEST_RESOURCE}   ${TEST_ACTION}   deny     vo="${TEST_VO}" x509-authn-profile="policy-test-iota"
  Reload policy  

Setup IOTA CA policies
  Remove all policies
  Add policy  ${TEST_RESOURCE}   ${TEST_ACTION}   permit   vo="${TEST_VO}" x509-subject-issuer="CN=Test CA,O=IGI,C=IT"
  Add policy  ${TEST_RESOURCE}   ${TEST_ACTION}   deny     vo="${TEST_VO}" x509-subject-issuer="CN=Test CA 2,O=IGI,C=IT"
  Reload policy 

Setup PEP
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}


*** Test Cases ***
Perform request with plain certificate in supported profile
  Setup PEP
  Mapping tests setup
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
    
Perform request with VOMS extension in supported profile
  Setup PEP
  Create user proxy
  Mapping tests setup
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
    
Perform request with IOTA plain certificate in not-supported profile
  Setup PEP
  Mapping tests setup
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${IOTA_USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Should Contain  ${output}  Not Applicable
    
Perform request with IOTA and VOMS extension in supported profile
  Setup PEP
  Mapping tests setup
  Create user proxy  ${IOTA_USERCERT}  ${IOTA_USERKEY}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}

Request resource with classic profile
  Setup PEP
  Setup IOTA profile policies
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  Permit
  
Request resource with IOTA profile
  Setup PEP
  Setup IOTA profile policies
  Create user proxy  ${IOTA_USER_CERT}  ${IOTA_USERKEY}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  Deny
  
Request resource with classic CA issuer
  Setup PEP
  Setup IOTA CA policies
  Create user proxy
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  Permit
  
Request resource with IOTA CA issuer
  Setup PEP
  Setup IOTA CA policies
  Create user proxy  ${IOTA_USER_CERT}  ${IOTA_USERKEY}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  Deny
