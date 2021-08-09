*** Settings ***
Resource   lib/utils.robot

Suite Setup  Run Keywords  Open Connection And Log In  AND  Make backup of the configuration
Suite Teardown  Run Keywords  Restore configurations  AND  Close All Connections

Test Setup  Mapping tests setup
Test Teardown  Restore PEP configuration


*** Test Cases ***
User mapping case 1 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${TEST_DN_UID_GROUP}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${TEST_DN_UID_GROUP}

User mapping case 2 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${TEST_DN_UID_GROUP}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 3 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=false  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${TEST_DN_UID_GROUP}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 4 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=false  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${TEST_DN_UID_GROUP}
  Check if secondary group match  ${output}  ${TEST_DN_UID_GROUP}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 5 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${RULE_INDETERMINATE}
  Should Contain  ${output}  Failed to map subject
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 5a (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=false
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 6 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${RULE_INDETERMINATE}
  Should Contain  ${output}  Failed to map subject
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 6a (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=true  no_primary_grp_is_error=false
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 7 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=false  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${RULE_INDETERMINATE}
  Should Contain  ${output}  Failed to map subject
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 7a (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=false  no_primary_grp_is_error=false
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 8 (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=false  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${RULE_INDETERMINATE}
  Should Contain  ${output}  Failed to map subject
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
User mapping case 8a (bug 69197)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=false  pref_dn_for_primary_grp=false  no_primary_grp_is_error=false
  Prepare PEP environment  &{dict}
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${VO}\\d+
  Check if group match  ${output}  ${VO}
  Check if secondary group match  ${output}  ${VO}|${TEST_DN_UID_GROUP}
  
Renew timestamp of leases (bug 83281)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=no
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${user_proxy}=  Get user proxy path
  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  ${file}=  Execute Command and Check Success  ls ${GRIDDIR}/${GRIDMAPDIR} | grep %
  ${lease_file}=  Join Path  ${GRIDDIR}/${GRIDMAPDIR}  ${file}
  ${timestamp}=  Get Modified Time  ${lease_file}
  Sleep  5
  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  ${new_timestamp}=  Get Modified Time  ${lease_file}
  Should Not Be Equal  ${timestamp}  ${new_timestamp}

PEPD write the secondary group into the lease (bug 83317)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=no
  ...  grp_vo_map=yes  grp_vo_sec_map=yes  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${file}=  Join Path  ${T_PEP_CONF}  ${T_PEP_INI}
  Add conf parameter  ${file}  useSecondaryGroupNamesForMapping  true
  Restart PEP service
  ${user_proxy}=  Get user proxy path
  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Change parameter value  ${file}  useSecondaryGroupNamesForMapping  false
  Restart PEP service
  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  ${leases_num}=  Execute Command and Check Success  ls ${GRIDDIR}/${GRIDMAPDIR}/%* | wc -l
  Should Be Equal  ${leases_num}  2

Legacy LCAS/LCMAPS lease filename encoding (bug 83419)
  [Tags]  local  cli
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=no
  ...  grp_vo_map=yes  grp_vo_sec_map=yes  grp_dn_map=no
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Prepare PEP environment  &{dict}
  ${user_proxy}=  Get user proxy path
  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Execute Command and Check Success  ls ${GRIDDIR}/${GRIDMAPDIR}/%* | grep ${VO}
