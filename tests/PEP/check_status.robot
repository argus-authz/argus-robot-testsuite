*** Settings ***
Resource   lib/utils.robot

*** Test Cases ***


Check PEP status endpoint
  [Tags]  remote
  ${cmd}=  Set variable  curl -sk --cert ${USERCERT} --key ${USERKEY} https://${T_PEP_HOST}:${T_PEP_PORT}/status
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  Status: OK
