*** Settings ***
Resource   lib/utils.robot

Test Teardown  Clean up


*** Test Cases ***
Add policy from file
  [Tags]  remote
  ${policy}=  Prepare
  Create policy file  ${policy}
  Load policy file

Add policy from file with error
  [Tags]  remote
  ${policy}=  Prepare with error
  Create policy file  ${policy}
  Execute and Check Failure  ${PAP_ADMIN} apf ${POLICY_FILE}

DN containing slash (bug 66669)
  [Tags]  remote
  Remove all policies
  ${pol}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name/testslash" }
  ...    }
  ...  }
  Create policy file  ${pol}
  Load policy file
  Remove policy file
  ${pol}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action ".*" {
  ...      rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/slashtest/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Create policy file  ${pol}
  Load policy file
  Execute and Check Success  ${PAP_ADMIN} lp --resource ${TEST_RESOURCE}
  

*** Keywords ***
Prepare
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource ".*" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  ...  resource ".*" {
  ...    action ".*" {
  ...      rule deny { fqan="/badvo" }
  ...    }
  ...  }
  [Return]  ${policies}

Prepare with error
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource ".*" {
  ...    action ".*" {
  ...      rule deni { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  [Return]  ${policies}
