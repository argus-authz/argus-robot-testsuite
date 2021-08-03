*** Settings ***
Resource   lib/utils.robot

#Suite Setup     Make backup of the configuration
#Suite Teardown  Restore configurations

#Test Setup  Ensure PAP running

*** Variables ***
${alias}  mypap
${new_pap}  NewPAP

${std_poll_interval}  14400
${poll_interval}  100
${FAKE_KERB_DN}  CN=host/argus.example.ch,C=CH


*** Test Cases ***

PAP ping
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} ping

Refresh cache with non existing alias
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} refresh-cache Do-Not-Exist
  Should Contain  ${output}  pap doesn't exist

Refresh cache with a local PAP
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} refresh-cache default
  Should Contain  ${output}  nothing to refresh

Add PAP with existing alias
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} add-pap ${DEFAULT_PAP}
  Should Contain  ${output}  already exists.

Add PAP with wrong endpoint
  [Tags]  remote  cli
  Execute and Check Failure  ${PAP_ADMIN} add-pap somePAP --url "https://localhost:8555/pap/services/"

Add and remove PAP local
  [Tags]  remote  cli
  Add PAP  ${new_pap}
  ${cmd}=  Set Variable  ${PAP_ADMIN} list-paps | grep -q ${new_pap}
  Execute and Check Success  ${cmd}
  Remove PAP  ${new_pap}

Remove local default PAP
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} remove-pap ${DEFAULT_PAP}
  Should Contain  ${output}  is not allowed

Remove non-existing PAP
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} remove-pap ${DUMMY_PAP}
  Should Contain  ${output}=  PAP not found

Disable PAP with non existing PAP
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} disable-pap ${DUMMY_PAP}
  Should Contain  ${output}=  PAP not found

Disable PAP with already disabled PAP
  [Tags]  remote  cli
  Add PAP  ${alias}
  Execute and Check Success  ${PAP_ADMIN} disable-pap ${alias}
  [Teardown]  Remove PAP  ${alias}

Enable PAP with wrong alias
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} enable-pap ${DUMMY_PAP}
  Should Contain  ${output}=  PAP not found

Enable/disable PAP with good alias
  [Tags]  remote  cli
  Add PAP  ${alias}
  Execute and Check Success  ${PAP_ADMIN} enable-pap ${alias}
  ${cmd}=  Set Variable  ${PAP_ADMIN} list-paps | grep ${alias} | grep -q enabled
  Execute and Check Success  ${cmd}
  Execute and Check Success  ${PAP_ADMIN} disable-pap ${alias}
  ${cmd}=  Set Variable  ${PAP_ADMIN} list-paps | grep ${alias} | grep -q disabled
  Execute and Check Success  ${cmd}
  [Teardown]  Remove PAP  ${alias}

Disable/Enable default PAP
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} disable-pap ${DEFAULT_PAP}
  ${cmd}=  Set Variable  ${PAP_ADMIN} list-paps | grep ${DEFAULT_PAP} | grep -q disabled
  Execute and Check Success  ${cmd}
  Execute and Check Success  ${PAP_ADMIN} enable-pap ${DEFAULT_PAP}
  ${cmd}=  Set Variable  ${PAP_ADMIN} list-paps | grep ${DEFAULT_PAP} | grep -q enabled
  Execute and Check Success  ${cmd}

Update PAP with non existing alias
  [Tags]  remote  cli
  ${output}=  Execute and Check Failure  ${PAP_ADMIN} update-pap ${DUMMY_PAP}
  Should Contain  ${output}=  PAP doesn't exists.

Get PAPs order with non order
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} get-paps-order

Set PAPs order and change it with 3 PAPs
  [Tags]  remote  cli
  @{paps}=  Create List  local-pap1  local-pap2  local-pap3
  Add PAPs list  @{paps}
  ${cmd}=  Set Variable  ${PAP_ADMIN} set-paps-order local-pap1 local-pap2 local-pap3 ${DEFAULT_PAP}
  Execute and Check Success  ${cmd}
  ${cmd}=  Set Variable  ${PAP_ADMIN} set-paps-order ${DEFAULT_PAP} local-pap3 local-pap2 local-pap1
  Execute and Check Success  ${cmd}
  [Teardown]  Remove PAPs list  @{paps}

Set PAPs order using a non existing alias
  [Tags]  remote  cli 
  @{paps}=  Create List  local-pap1  local-pap2  local-pap3
  Add PAPs list  @{paps}
  ${cmd}=  Set Variable  ${PAP_ADMIN} set-paps-order local-pp1 local-pp2 local-pp3 ${DEFAULT_PAP}
  ${output}=  Execute and Check Failure  ${cmd}
  Should Contain  ${output}  unknown alias
  [Teardown]  Remove PAPs list  @{paps}

Setting polling time
  [Tags]  remote  cli
  Execute and Check Success  ${PAP_ADMIN} set-polling-interval ${poll_interval}
  ${cmd}=  Set Variable  ${PAP_ADMIN} gpi | sed 's/Polling interval in seconds: //g'
  ${rc}  ${output}=  Run And Return Rc And Output  ${cmd}
  Should Be Equal As Integers  ${output}  ${poll_interval}

List policies with no authorization
  [Tags]  local  cli
  [Setup]  Ensure PAP stopped
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 1
  Create File  ${file}  ${content}
  Start PAP service
  Execute and Check Failure  ${PAP_ADMIN} list-policies >/dev/null 2>&1
  [Teardown]  Restore PAP configuration

List policies with anyone full power
  [Tags]  local  cli
  [Setup]  Ensure PAP stopped
  ${file}=  Join Path  ${T_PAP_CONF}  ${T_PAP_AUTH_INI}
  ${content}=  Get content test 2
  Create File  ${file}  ${content}
  Start PAP service
  Execute and Check Success  ${PAP_ADMIN} list-policies >/dev/null 2>&1
  [Teardown]  Restore PAP configuration

Restart after a kerberized DN was added as acl (bug 82193)
  [Tags]  local  cli
  Execute and Check Success  ${PAP_ADMIN} add-ace ${FAKE_KERB_DN} ALL
  Restart PAP service
  Execute and Check Success  ${PAP_ADMIN} lp
  Execute and Check Success  ${PAP_ADMIN} remove-ace ${FAKE_KERB_DN}


*** Keywords ***
Add PAP  [Arguments]  ${pap_name}
  Execute And Check Success   ${PAP_ADMIN} add-pap ${pap_name}

Remove PAP  [Arguments]  ${pap_name}
  Execute And Check Success   ${PAP_ADMIN} remove-pap ${pap_name}

Add PAPs list  [Arguments]  @{list}
  FOR  ${elem}  IN  @{list}
    Add PAP  ${elem}
  END

Remove PAPs list  [Arguments]  @{list}
  FOR  ${elem}  IN  @{list}
    Remove PAP  ${elem}
  END

Get content test 1
  ${text}=  catenate  SEPARATOR=
  ...  [dn]\n
  ...  ANYONE : CONFIGURATION_READ\n
  ...  \n
  ...  [fqan]\n
  [Return]  ${text}

Get content test 2
  ${text}=  catenate  SEPARATOR=
  ...  [dn]\n
  ...  ANYONE : ALL\n
  ...  \n
  ...  [fqan]\n
  [Return]  ${text}
