*** Settings ***
Resource   lib/utils.robot

*** Test Cases ***

Check PAP status endpoint
  [Tags]  remote
  ${cmd}=  Set variable  curl -sk --cert ${USERCERT} --key ${USERKEY} https://${T_PAP_HOST}:${T_PAP_PORT}/pap/status
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  Status: OK

Check PDP status endpoint
  [Tags]  remote
  ${cmd}=  Set variable  curl -sk --cert ${USERCERT} --key ${USERKEY} https://${T_PDP_HOST}:${T_PDP_PORT}/status
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  Status: OK

Check PEP status endpoint
  [Tags]  remote
  ${cmd}=  Set variable  curl -sk --cert ${USERCERT} --key ${USERKEY} https://${T_PEP_HOST}:${T_PEP_PORT}/status
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  Status: OK
