** Settings ***

Library    OperatingSystem
Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}

*** Keywords ***

Add policy with obligation  [Arguments]  ${resource}  ${action}  ${obligation}  ${rule}  ${subject}
  ${cmd}=  Set Variable  ${PAP_ADMIN} add-policy --resource "${resource}" --action "${action}" --obligation "${obligation}" "${rule}" subject="${subject}"
  Execute and Check Success  ${cmd}

Add policy  [Arguments]  ${resource}  ${action}  ${rule}  ${attributes}
  ${cmd}=  Set Variable  ${PAP_ADMIN} add-policy --resource "${resource}" --action "${action}" "${rule}" ${attributes}
  Execute and Check Success  ${cmd}
  
Add obligation  [Arguments]  ${policy_id}  ${obligation}
  Execute and Check Success  ${PAP_ADMIN} add-obligation ${policy_id} ${obligation}

Remove all policies  [Arguments]  ${host}=${T_PAP_HOST}  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}
  Execute And Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} rap

Ban by subject  [Arguments]  ${subject}  ${host}=localhost  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}
  Execute And Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} ban subject ${subject}

Un-ban by subject  [Arguments]  ${subject}  ${host}=localhost  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}
  Execute And Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} un-ban subject ${subject}

Ban by FQAN  [Arguments]  ${fqan}  ${host}=localhost  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}
  Execute And Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} ban fqan ${fqan}

Un-ban by FQAN  [Arguments]  ${fqan}  ${host}=localhost  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}
  Execute And Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} un-ban fqan ${fqan}

Clean up  [Arguments]  ${host}=${T_PAP_HOST}  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}  ${file}=${POLICY_FILE}
  Remove all policies  ${host}  ${port}  ${cert}  ${key}
  Remove policy file  ${file}

Create policy file  [Arguments]  ${policies}
  Create File  ${POLICY_FILE}  ${policies}

Load policy file  [Arguments]  ${host}=${T_PAP_HOST}  ${port}=${T_PAP_PORT}  ${cert}=${USERCERT}  ${key}=${USERKEY}  ${file}=${POLICY_FILE}
  Execute and Check Success  ${PAP_ADMIN} --host ${host} --port ${port} --cert ${cert} --key ${key} apf ${file}

List policy with resource and action ids
  ${output}=  Execute and Check Success  ${PAP_ADMIN} lp -srai
  [Return]  ${output}

List policy with all ids
  ${output}=  Execute and Check Success  ${PAP_ADMIN} lp -sai
  [Return]  ${output}

Prepare PAP environment  [Arguments]  ${policies}
  Create policyfile  ${policies}
  Remove all policies
  Load policy file

Remove obligation  [Arguments]  ${policy_id}  ${obligation}
  Execute and Check Success  ${PAP_ADMIN} remove-obligation ${policy_id} ${obligation}

Remove policy file  [Arguments]  ${file}=${POLICY_FILE}
  OperatingSystem.Remove File  ${file}

Start PAP
  Execute Command  papctl start
  Sleep  15s