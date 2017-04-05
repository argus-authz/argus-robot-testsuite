*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Setup     Start PAP service
Test Teardown  Clean up

*** Test Cases ***
Ban/un-ban user
  Execute and Check Success  ${PAP_ADMIN} ban subject ${TEST_USER_DN}
  Execute and Check Success  ${PAP_ADMIN} un-ban subject ${TEST_USER_DN}

Ban/un-ban VO FQAN
  Execute and Check Success  ${PAP_ADMIN} ban fqan "/${TEST_VO}"
  Execute and Check Success  ${PAP_ADMIN} un-ban fqan "/${TEST_VO}"
  
Un-ban not existing user
  Execute and Check Failure  ${PAP_ADMIN} un-ban subject ${TEST_USER_DN}

Un-ban not existing VO FQAN
  Execute and Check Failure  ${PAP_ADMIN} un-ban fqan "/${TEST_VO}"
