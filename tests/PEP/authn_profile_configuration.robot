*** Settings ***
Resource   lib/utils.robot

Suite Setup  Run Keywords  Open Connection And Log In  AND  Make backup of the configuration
Suite Teardown  Run Keywords  Restore configurations  AND  Close All Connections


*** Keywords ***
Setup PEP
  &{dict}=  Create Dictionary
  ...  vo_map=yes  dn_map=yes
  ...  grp_vo_map=yes  grp_vo_sec_map=no  grp_dn_map=yes
  ...  pref_dn_for_login=true  pref_dn_for_primary_grp=true  no_primary_grp_is_error=true
  Log Dictionary  ${dict}
  Create Directory  /etc/vomses
  Create File on Server  /etc/vomses/${VO}  ${VOMSES_STRING}
  Remove all leases in gridmapdir
  Init grid map file  ${dict.vo_map}  ${dict.dn_map}
  Init grid group map file  ${dict.grp_vo_map}  ${dict.grp_vo_sec_map}  ${dict.grp_dn_map}
  Init pool accounts
  Remove file  ${GRIDDIR}/${AUTHN_PROFILE_FILE}
  Init fallback authentication profile file
  Init test CAs policy files
  ${file}=  Set Variable  ${T_PEP_CONF}/${T_PEP_INI}
  Check string presence into file  ${file}  'org.glite.authz.pep.obligation.dfpmap.DFPMObligationHandlerConfigurationParser'
  Init configuration  ${dict.pref_dn_for_login}  ${dict.pref_dn_for_primary_grp}  ${dict.no_primary_grp_is_error}
  Ensure PAP running
  Ensure PDP running
  Restart PEP service


*** Test Cases ***
Check AUTHN_PROFILE_PIP is enabled
  [Tags]  local
  ${pips}=  Read parameter from INI file  ${T_PEP_CONF}/${T_PEP_INI}  pips
  Should Contain  ${pips}  AUTHN_PROFILE_PIP
  
Start PEP with missing auth profile policy file
  [Tags]  local
  Ensure PEP stopped
  ${value}=  Escape char  ${GRIDDIR}/${AUTHN_PROFILE_FILE}  /
  Change parameter value  ${T_PEP_CONF}/${T_PEP_INI}  authenticationProfilePolicyFile  ${value}
  ${auth_profile_conf}=  Read parameter from INI file  ${T_PEP_CONF}/${T_PEP_INI}  authenticationProfilePolicyFile
  Should Be Equal As Strings  ${auth_profile_conf}  ${GRIDDIR}/${AUTHN_PROFILE_FILE}
  Remove file  ${GRIDDIR}/${AUTHN_PROFILE_FILE}
  Start PEP service
  ${cmd}=  Set Variable  ${T_PEP_CTRL} status | grep -q "Status: OK"
  Execute Command and Check Success  ${cmd}
  [Teardown]  Restore PEP configuration
    
Classis CA is accepted with fallback authentication profile file
  [Tags]  local  cli
  Setup PEP
  Mapping tests setup
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  [Teardown]  Restore PEP configuration

Classis CA with VOMS extension is accepted with fallback authentication profile file
  [Tags]  local  cli
  Setup PEP
  Create user proxy
  Mapping tests setup
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${USERKEY}  ${USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Check if rule match  ${output}  ${TEST_RULE}
  Check if username match  ${output}  ${TEST_DN_UID}
  [Teardown]  Restore PEP configuration  
  
IOTA CA is rejected with fallback authentication profile file
  [Tags]  local  cli
  Setup PEP
  Mapping tests setup
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${IOTA_USERCERT}  ${TEST_RESOURCE}  ${TEST_ACTION}
  Should Contain  ${output}  Not Applicable 
  [Teardown]  Restore PEP configuration 

IOTA CA with VOMS extensions is rejected with fallback authentication profile file
  [Tags]  local  cli
  Setup PEP
  Mapping tests setup
  Create user proxy  ${IOTA_USERCERT}  ${IOTA_USERKEY}
  ${user_proxy}=  Get user proxy path
  ${output}=  Perform PEP request  ${IOTA_USERKEY}  ${IOTA_USERCERT}  ${user_proxy}  ${TEST_RESOURCE}  ${TEST_ACTION} 
  Should Contain  ${output}  Not Applicable 
  [Teardown]  Restore PEP configuration 
  