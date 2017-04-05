** Settings ***

Library    OperatingSystem
Library    Collections
Resource   variables.robot

Resource   common_utils.robot
Resource   file_utils.robot
Resource   pap_utils.robot
Resource   service_utils.robot
Resource   x509_utils.robot

Variables  ${ENV_FILE}


*** Keywords ***

Add PEP authz test policy
  ${user_dn}=  Get user dn
  Add policy with obligation  ${TEST_RESOURCE}  ${TEST_ACTION}  ${TEST_OBLIGATION}  ${TEST_RULE}  ${user_dn}

Check if username match  [Arguments]  ${output}  ${pattern_to_match}
  ${username}=  Get match  ${output}  Username: (.*)
  Should Not Be Empty  ${username}  No user account mapped.
  Should Match Regexp  ${username}  ${pattern_to_match}

Check if group match  [Arguments]  ${output}  ${pattern_to_match}
  ${group}=  Get match  ${output}  Group: (.*)
  Should Not Be Empty  ${group}  No user group mapped.
  Should Match Regexp  ${group}  ${pattern_to_match}

Check if secondary group match  [Arguments]  ${output}  ${pattern_to_match}
  ${sec_group}=  Get match  ${output}  Secondary Groups: (.*)
  Should Not Be Empty  ${sec_group}  No user secondary group mapped.
  Should Match Regexp  ${sec_group}  ${pattern_to_match}

Check if rule match  [Arguments]  ${output}  ${rule}
  Should Contain Ignore Case  ${output}  ${rule}  Did not find expected rule: ${rule}

Init configuration  [Arguments]  ${pref_dn_for_login}  ${pref_dn_for_primary_group}  ${no_primary_group_is_error}
  ${file}=  Set Variable  ${T_PEP_CONF}/${T_PEP_INI}
  Add conf parameter  ${file}  preferDNForLoginName  ${pref_dn_for_login}
  Add conf parameter  ${file}  preferDNForPrimaryGroupName  ${pref_dn_for_primary_group}
  Add conf parameter  ${file}  noPrimaryGroupNameIsError  ${no_primary_group_is_error}

Init grid map file  [Arguments]  ${vo_map}  ${dn_map}
  ${file}=  Set Variable  ${GRIDDIR}/${GRIDMAPFILE}
  ${user_dn}=  Get user dn
  Empty file  ${file}
  Run Keyword If  '${vo_map}' == 'yes'  Append To File  ${file}  \n"${VO_PRIMARY_GROUP}" .${VO}
  Run Keyword If  '${dn_map}' == 'yes'  Append To File  ${file}  \n"${user_dn}" ${TEST_DN_UID}

Init grid group map file  [Arguments]  ${group_vo_map}  ${group_vo_secondary_map}  ${group_dn_map}
  ${file}=  Set Variable  ${GRIDDIR}/${GROUPMAPFILE}
  ${user_dn}=  Get user dn
  Empty file  ${file}
  Run Keyword If  '${group_vo_map}' == 'yes'  Append To File  ${file}  \n"${VO_PRIMARY_GROUP}" ${VO}
  Run Keyword If  '${group_vo_secondary_map}' == 'yes'  Append To File  ${file}  \n"${VO_SECONDARY_GROUP}" ${VO}-secondary
  Run Keyword If  '${group_dn_map}' == 'yes'  Append To File  ${file}  \n"${user_dn}" ${TEST_DN_UID_GROUP}

Init authentication profile file
  ${file}=  Set Variable  ${GRIDDIR}/${AUTHN_PROFILE_FILE}
  ${content}=  catenate  SEPARATOR=\n
  ...  /test.vo${SPACE}${SPACE}file:policy-test-classic.info, file:policy-test-iota.info
  ...  /*${SPACE}${SPACE}file:policy-test-classic.info
  ...  "-"${SPACE}${SPACE}file:policy-test-classic.info  
  Create File  ${file}  ${content}
  
Init test CAs policy files
  ${classic}=  Set Variable  ${GRIDDIR}/certificates/policy-test-classic.info
  ${content}=  catenate  SEPARATOR=\n
  ...  alias = policy-test-classic
  ...  subjectdn = "/C=IT/O=INFN/CN=INFN Certification Authority", \\
  ...    "/C=IT/O=IGI/CN=Test CA"
  ...    
  Create File  ${classic}  ${content}
  ${iota}=  Set Variable  ${GRIDDIR}/certificates/policy-test-iota.info
  ${content}=  catenate  SEPARATOR=\n
  ...  alias = policy-test-iota
  ...  subjectdn = "/C=IT/O=IGI/CN=Test CA 2"
  ...    
  Create File  ${iota}  ${content}

Init pool accounts
  :FOR  ${idx}  IN RANGE  1  3
  \  Touch pool account  ${VO}00${idx}

Perform PEP request  [Arguments]  ${client_key}  ${client_cert}  ${subject_keyinfo}  ${resource}  ${action}  ${fqan}=None  ${host}=%{HOSTNAME}  ${port}=${T_PEP_PORT}
  ${cmd}=  Build PEPCLI command line  ${client_key}  ${client_cert}  ${subject_keyinfo}  ${resource}  ${action}  ${fqan}  ${host}  ${port}
  ${output}=  Execute and Check Success  ${cmd}
  [Return]  ${output}

Build PEPCLI command line  [Arguments]  ${client_key}  ${client_cert}  ${subject_keyinfo}  ${resource}  ${action}  ${fqan}  ${host}  ${port}
  #${str}=  Escape char  ${fqan}  .
  ${cmd}=  catenate
  ...  ${PEPCLI} -p https://${host}:${port}/authz
  ...  --capath /etc/grid-security/certificates/
  ...  --key ${client_key}
  ...  --cert ${client_cert}
  ...  --keyinfo ${subject_keyinfo}
  ...  -r "${resource}"
  ...  -a "${action}"
  ${cmd}=  Run Keyword If  '${fqan}' is 'None'  Set Variable  ${cmd}
  ...      ELSE  catenate  ${cmd}  -f "/${fqan}"
  [Return]  ${cmd}

Prepare PEP environment  [Arguments]  &{dict}
  Log Dictionary  ${dict}
  Create Directory  /etc/vomses
  Create File  /etc/vomses/${VO}  ${VOMSES_STRING}
  Remove all leases in gridmapdir
  Init grid map file  ${dict.vo_map}  ${dict.dn_map}
  Init grid group map file  ${dict.grp_vo_map}  ${dict.grp_vo_sec_map}  ${dict.grp_dn_map}
  Init pool accounts
  Init authentication profile file
  Init test CAs policy files
  ${file}=  Set Variable  ${T_PEP_CONF}/${T_PEP_INI}
  Check string presence into file  ${file}  'org.glite.authz.pep.obligation.dfpmap.DFPMObligationHandlerConfigurationParser'
  Init configuration  ${dict.pref_dn_for_login}  ${dict.pref_dn_for_primary_grp}  ${dict.no_primary_grp_is_error}
  Ensure PAP running
  Ensure PDP running
  Restart PEP service
  
Mapping tests setup
  Create user proxy
  Remove all policies
  Add PEP authz test policy
  Reload policy

