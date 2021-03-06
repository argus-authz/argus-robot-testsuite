*** Settings ***
Resource   lib/utils.robot

Suite Setup     Make backup of the configuration
Suite Teardown  Restore configurations

Test Setup     Ensure PAP running
Test Teardown  Clean up


*** Test Cases ***

Update from file with non existing file
  Execute and Check Failure  ${PAP_ADMIN} upf ${DUMMY_ID} ${DUMMY_FILE}

Update from file with non existing resource id
  [Setup]  Prepare
  Remove policy file
  Prepare new policy file
  Execute and Check Failure  ${PAP_ADMIN} upf ${DUMMY_ID} ${POLICY_FILE}

Update from file with correct resource id
  [Setup]  Prepare
  Remove policy file
  Prepare new policy file
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep 'id=[^p][0-9a-f\-]*' | sed 's/id=//'
  Execute and Check Success  ${PAP_ADMIN} upf ${output} ${POLICY_FILE}

Update from file with changing only an action
  [Setup]  Prepare
  Remove policy file
  Prepare new policy file with only an action
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep 'id=public' | awk '{print $1}' | sed 's/id=//'
  Execute and Check Success  ${PAP_ADMIN} upf ${output} ${POLICY_FILE}


*** Keywords ***

Prepare
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Prepare PAP environment  ${policy}

Prepare new policy file
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource ".*" {
  ...    action ".*" {
  ...      rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Create policy file  ${policy}

Prepare new policy file with only an action
  ${policy}=  catenate  SEPARATOR=\n
  ...  action ".*" {
  ...   rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...  }
  Create policy file  ${policy}
