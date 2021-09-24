*** Settings ***
Resource   lib/utils.robot

Test Teardown  Clean up


*** Test Cases ***
Add policy from file
  [Tags]  remote  cli
  ${policy}=  Prepare
  Create policy file  ${policy}
  Load policy file

Add policy from file with syntax error
  [Tags]  remote  cli
  ${policy}=  Prepare with error
  Create policy file  ${policy}
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} apf ${POLICY_FILE}
  Should Contain  ${output}  Syntax error

DN containing slash (bug 66669)
  [Tags]  remote  cli
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

Load policy to PAP
  [Tags]  remote  cli
  Remove all policies  host=${T_PAP_HOST}
  Prepare policy file
  Load policy file  host=${T_PAP_HOST}
  ${output}=  Execute and Check Success  ${PAP_ADMIN} --cert ${USERCERT} --key ${USERKEY} --host ${T_PAP_HOST} --port ${T_PAP_PORT} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${output}  6
  

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
