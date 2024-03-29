*** Settings ***
Resource   lib/utils.robot

Suite Setup  Run Keywords  Open Connection And Log In  AND  Make backup of the configuration
Suite Teardown  Run Keywords  
...   Restore PEP configuration  AND  
...   Restart PEP service  AND
...   Close All Connections

*** Test Cases ***
User group mapping (bug 64340)
  [Tags]  local  cli
  &{dict}=  Create Dictionary  vo_map=no  dn_map=yes
  ...  grp_vo_map=no  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  Create user proxy
  Mapping tests setup
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}  ${VO}
  Should Contain  ${output}  ${TEST_RESOURCE}  Did not find expected resource: ${TEST_RESOURCE}
  Should Contain Ignore Case  ${output}  ${TEST_RULE}  Did not find expected rule: ${TEST_RULE}
  ${username}=  Get match  ${output}  Username: (.*)
  Should Not Be Empty  ${username}  No user account mapped.
  ${group}=  Get match  ${output}  Group: (.*)
  Should Not Be Empty  ${group}  No user group mapped.
  ${sec_group}=  Get match  ${output}  Secondary Groups: (.*)
  Should Not Be Empty  ${sec_group}  No user secondary group mapped.
  Should Be Equal  ${group}  ${sec_group}
  [Teardown]  Restore PEP configuration

DN group mapping (bug 68805)
  [Tags]  local  cli
  Init authentication profile file
  Init test CAs policy files
  ${host_dn}=  Get host dn
  ${str}=  Escape char  ${host_dn}  /
  Replace string  ${GRIDDIR}/${VOMSGRIDMAPFILE}  "${str}"  \# Ignore
  ${file}=  Set Variable  ${GRIDDIR}/${GRIDMAPFILE}
  Empty file  ${file}
  Append To File  ${file}  \n"${host_dn}" ${TEST_DN_UID}
  ${file}=  Set Variable  ${GRIDDIR}/${GROUPMAPFILE}
  Empty file  ${file}
  Append To File  ${file}  \n"${host_dn}" ${TEST_DN_UID_GROUP}
  Ensure PAP running
  Ensure PDP running
  Restart PEP service
  Remove all policies
  ${action}=  Set Variable  do_not_test
  Add policy with obligation  ${TEST_RESOURCE}  ${TEST_ACTION}  ${TEST_OBLIGATION}  ${TEST_RULE}  ${host_dn}
  Add policy  ${TEST_RESOURCE}  ${action}  ${TEST_RULE}  subject="${host_dn}"
  Reload policy
  ${cmd}=  Build PEPCLI command line  ${HOSTKEY}  ${HOSTCERT}  ${HOSTCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}  None  ${T_PEP_HOST}  ${T_PEP_PORT}
  ${output}=  Execute Command and Check Success  ${cmd}
  Should Contain  ${output}  ${TEST_RESOURCE}
  Should Contain Ignore Case  ${output}  ${TEST_RULE}
  ${username}=  Get match  ${output}  Username: (.*)
  Should Not Be Empty  ${username}  No user account mapped.
  ${group}=  Get match  ${output}  Group: (.*)
  Should Not Be Empty  ${group}  No user group mapped.
  ${sec_group}=  Get match  ${output}  Secondary Groups: (.*)
  Should Not Be Empty  ${sec_group}  No user secondary group mapped.
  [Teardown]  Restore PEP configuration
