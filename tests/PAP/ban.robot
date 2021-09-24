*** Settings ***
Resource   lib/utils.robot

Test Teardown  Clean up

*** Test Cases ***
Ban/un-ban user
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} ban subject ${TEST_USER_DN}
  Execute and Check Success  ${PAP_ADMIN} un-ban subject ${TEST_USER_DN}

Ban/un-ban VO FQAN
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} ban fqan "/${TEST_VO}"
  Execute and Check Success  ${PAP_ADMIN} un-ban fqan "/${TEST_VO}"
  
Un-ban not existing user
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} un-ban subject ${TEST_USER_DN}
  Should Contain  ${output}  ban policy not found.

Un-ban not existing VO FQAN
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} un-ban fqan "/${TEST_VO}"
  Should Contain  ${output}  ban policy not found.