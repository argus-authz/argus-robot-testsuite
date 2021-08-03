*** Settings ***
Resource   lib/utils.robot

Test Teardown  Clean up

*** Test Cases ***

Attempt policy update from a non-existing file
  [Tags]   remote  cli
  ${out}   Execute and Check Failure  ${PAP_ADMIN} upf ${DUMMY_ID} ${DUMMY_FILE}
  Should contain   ${out}   does not exists.
  

Update from file with non-existing resource id
  [Tags]   remote  cli
  [Setup]  Prepare
  Remove policy file
  Prepare new policy file
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} upf ${DUMMY_ID} ${POLICY_FILE}
  Should contain  ${output}  does not exists.

Update from file with correct resource id
  [Tags]   remote  cli
  [Setup]  Prepare
  Remove policy file
  Prepare new policy file
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep 'id=[^p][0-9a-f\-]*' | sed 's/id=//'
  Execute and Check Success  ${PAP_ADMIN} upf ${output} ${POLICY_FILE}

Update from file with changing only an action
  [Tags]   remote  cli
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
