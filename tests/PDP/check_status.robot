*** Settings ***
Resource   lib/utils.robot

*** Test Cases ***


Check PDP status endpoint
  [Tags]  remote
  ${cmd}=  Set variable  curl -sk --cert ${USERCERT} --key ${USERKEY} https://${T_PDP_HOST}:${T_PDP_PORT}/status
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  Status: OK