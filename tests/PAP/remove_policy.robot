*** Settings ***
Resource   lib/utils.robot

Test Teardown  Clean up

*** Test Cases ***

Remove all policies
  [Tags]  remote  cli
  [Setup]  Prepare
  Execute and Check Success  ${PAP_ADMIN} rap
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${output}  0

Remove with non existing id
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} rp ${DUMMY_ID}
  Should Contain  ${output}  Id not found

Remove with resource id
  [Tags]  remote  cli
  [Setup]  Prepare
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep -m 1 'id=' | awk '{print $1}' | sed 's/id=//'
  Execute and Check Success  ${PAP_ADMIN} rp ${output}

Remove with action id
  [Tags]  remote  cli
  [Setup]  Prepare test 3
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep 'id=' | tail -1 | awk '{print $1}' | sed 's/id=//'
  Execute and Check Success  ${PAP_ADMIN} rp ${output}
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -srai | egrep -c 'id='
  Should Be Equal As Integers  ${rc}  0
  Should Be Equal As Integers  ${output}  2

Remove with rule id
  [Tags]  remote  cli
  [Setup]  Prepare test 4
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep 'id=' | tail -1 | awk '{print $1}' | sed 's/id=//' | xargs
  Execute and Check Success  ${PAP_ADMIN} rp ${output}
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${rc}  0
  Should Be Equal As Integers  ${output}  3

Remove with multiple rules
  [Tags]  remote  cli
  [Setup]  Prepare test 5
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep 'id=' | tail -4 | head -3 | awk '{print $1}' | sed 's/id=//' | xargs
  Execute and Check Success  ${PAP_ADMIN} rp ${output}
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${rc}  0
  Should Be Equal As Integers  ${output}  3

Remove with multiple rules and one wrong
  [Tags]  remote  cli
  [Setup]  Prepare test 5
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep 'id=' | tail -4 | head -3 | awk '{print $1}' | sed 's/id=//' | xargs
  Execute and Check Failure  ${PAP_ADMIN} rp ${output} ${DUMMY_ID}
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${rc}  0
  Should Be Equal As Integers  ${output}  3

Remove with empty repository
  [Tags]  remote  cli
  [Setup]  Remove all policies
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} rp ${DUMMY_ID}
  Should Contain  ${output}  Id not found


*** Keywords ***

Prepare
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  ...  resource "resource_2" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  ...  resource "resource_3" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Prepare PAP environment  ${policies}

Prepare test 3
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action "submit-job" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...
  ...    action "get-status" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Prepare PAP environment  ${policies}

Prepare test 4
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action "get-status" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
  ...    }
  ...  }
  Prepare PAP environment  ${policies}

Prepare test 5
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action "get-status" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name 3" }
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
  ...    }
  ...  }
  Prepare PAP environment  ${policies}
