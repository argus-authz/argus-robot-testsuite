*** Settings ***
Resource   lib/utils.robot


*** Test Cases ***
List empty repository
  [Tags]  remote  cli
  Remove all policies
  ${output}=  Execute and Check Success  ${PAP_ADMIN} lp
  Should Contain  ${output}  No policies has been found.

List policies
  [Tags]  remote  cli
  Prepare
  ${rc}  ${output}=  Run And Return Rc And Output  ${PAP_ADMIN} lp -sai | egrep -c 'id='
  Should Be Equal As Integers  ${rc}  0
  Should Be Equal As Integers  ${output}  9
  [Teardown]  Clean up

List policies with wrong pap-alias
  [Tags]  remote  cli
  ${output}=  Execute And Check Failure  ${PAP_ADMIN} lp -sai --pap "dummy_pap"
  Should Contain  ${output}  Not found

List by resource or action with incremental loading (bug 60044)
  [Tags]  remote  cli
  @{list}=  Get policy list
  FOR  ${pol}  IN  @{list}
    Create policy file  ${pol}
    Load policy file
    Remove policy file
  END
  ${cmd}=  Set Variable  ${PAP_ADMIN} lp --resource "resource_2" | grep -q "999998"
  Execute and Check Success  ${cmd}
  ${cmd}=  Set Variable  ${PAP_ADMIN} lp --action "execute" | grep -q "999997"
  Execute and Check Success  ${cmd}
  ${cmd}=  Set Variable  ${PAP_ADMIN} lp --action "spare" | grep -q "No policies has been found."
  Execute and Check Success  ${cmd}
  [Teardown]  Clean up

Calling pap-admin from a symlink (bug 63180)
  [Tags]  remote  cli
  ${tmp_bin}=  Set Variable  /tmp/bin
  OperatingSystem.Create Directory  ${tmp_bin}
  Execute and Check Success  ln -fs ${T_PAP_HOME}/bin/pap-admin ${tmp_bin}/pap-admin
  Execute and Check Success  ${tmp_bin}/pap-admin remove-all-policies
  @{list}=  Get policy list
  FOR  ${pol}  IN  @{list}
    Create policy file  ${pol}
    Execute and Check Success  ${tmp_bin}/pap-admin add-policies-from-file ${POLICY_FILE}
    Remove policy file
  END
  Execute and Check Success  ${tmp_bin}/pap-admin lp > /dev/null
  [Teardown]  Clean up

List policy with obligation (bug 68595)
  [Tags]  remote  cli
  Remove all policies
  ${user_dn}=  Get user dn
  Add policy with obligation  ${TEST_RESOURCE}  ${TEST_ACTION}  ${TEST_OBLIGATION}  ${TEST_RULE}  ${user_dn}
  ${output}=  List policy with resource and action ids
  Should Contain  ${output}  obligation
  Should Contain  ${output}  ${TEST_OBLIGATION}
  ${id}=  Execute and Check Success  ${PAP_ADMIN} lp -srai | grep 'id=[^p][0-9a-f\-]*' | cut -d'=' -f2
  Remove obligation  ${id}  ${TEST_OBLIGATION}
  ${output}=  List policy with resource and action ids
  Should Not Contain  ${output}  ${TEST_OBLIGATION}
  Add obligation  ${id}  ${TEST_OBLIGATION}
  ${output}=  List policy with all ids
  Should Contain  ${output}  obligation
  Should Contain  ${output}  ${TEST_OBLIGATION}
  [Teardown]  Clean up


*** Keywords ***

Prepare
  ${policies}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  ...  resource "resource_2" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  ...  resource "resource_3" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  Prepare PAP environment  ${policies}

Get policy 1
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource "resource_1" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
  ...    }
  ...  }
  [Return]  ${policy}

Get policy 2
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource "resource_2" {
  ...    action ".*" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name" }
  ...    }
  ...  }
  [Return]  ${policy}

Get policy 3
  ${policy}=  catenate  SEPARATOR=\n
  ...  resource "resource_3" {
  ...    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
  ...    action "execute" {
  ...      rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name" }
  ...    }
  ...  }
  [Return]  ${policy}

Get policy list
  ${pol1}=  Get policy 1
  ${pol2}=  Get policy 2
  ${pol3}=  Get policy 3
  @{list}=  Create List  ${pol1}  ${pol2}  ${pol3}
  [Return]  @{list}
