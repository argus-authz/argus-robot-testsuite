** Settings ***

Library    OperatingSystem
Library    Process
Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}

*** Keywords ***

Port not reachable  [Arguments]  ${hostname}  ${port}
  ${cmd}=  Set Variable  (echo > /dev/tcp/${hostname}/${port}) &>/dev/null
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  1

Check service running  [Arguments]  ${t_ctrl}  ${hostname}  ${port}
  ${cmd}=  Set Variable  ${t_ctrl} status
  Execute Command and Check Success  ${cmd}
  ${cmd}=  Set Variable  curl --capath ${GRIDDIR}/certificates/ --cert ${USERCERT} --key ${USERKEY} https://${hostname}:${port} &> /dev/null
  Execute and Check Success  ${cmd}

Check service stopped  [Arguments]  ${t_ctrl}  ${hostname}  ${port}
  ${cmd}=  Set Variable  ${t_ctrl} status
  Execute Command and Check Failure  ${cmd}
  ${cmd}=  Set Variable  curl --capath ${GRIDDIR}/certificates/ --cert ${USERCERT} --key ${USERKEY} https://${hostname}:${port} &> /dev/null
  Execute and Check Failure  ${cmd}

Ensure PAP running
  ${status}=  Get PAP status
  Run Keyword If  ${status}!=0  Start PAP service

Ensure PDP running
  ${status}=  Get PDP status
  Run Keyword If  ${status}!=0  Start PDP service

Ensure PEP running
  ${status}=  Get PEP status
  Run Keyword If  ${status}!=0  Start PEP service

Ensure PAP stopped
  ${status}=  Get PAP status
  Run Keyword If  ${status}==0  Stop PAP service

Ensure PDP stopped
  ${status}=  Get PDP status
  Run Keyword If  ${status}==0  Stop PDP service

Ensure PEP stopped
  ${status}=  Get PEP status
  Run Keyword If  ${status}==0  Stop PEP service

Get PAP status
  ${output}  ${rc}=  Execute Command  papctl status  return_rc=True
  [Return]  ${rc}

Get PDP status
  ${output}  ${rc}=  Execute Command  pdpctl status  return_rc=True
  [Return]  ${rc}

Get PEP status
  ${output}  ${rc}=  Execute Command  pepdctl status  return_rc=True
  [Return]  ${rc}

Restore services
  Stop PAP service
  Stop PDP service
  Stop PEP service
  Sleep  5
  Start PAP service
  Start PDP service
  Start PEP service

Restart PAP service
  Ensure PAP stopped
  Sleep  5
  Ensure PAP running

Restart PDP service
  Ensure PDP stopped
  Sleep  5
  Ensure PDP running

Restart PEP service
  Ensure PEP stopped
  Sleep  5
  Ensure PEP running

Start PAP service
  Start Command  systemctl start argus-pap
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  60 sec  5 sec  Check service running  ${T_PAP_CTRL}  ${hostname}  ${T_PAP_PORT}
  Log  PAP started

Start PDP service
  Start Command  systemctl start argus-pdp
  ${hostname}=  Get hostname 
  Wait Until Keyword Succeeds  60 sec  5 sec  Check service running  ${T_PDP_CTRL}  ${hostname}  ${T_PDP_PORT}
  Log  PDP started

Start PEP service
  Start Command  systemctl start argus-pepd
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  60 sec  5 sec  Check service running  ${T_PEP_CTRL}  ${hostname}  ${T_PEP_PORT}
  Log  PEP started

Stop PAP service
  Start Command  systemctl stop argus-pap
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  60 sec  5 sec  Port not reachable  ${hostname}  ${T_PAP_PORT}
  Log  PAP stopped

Stop PDP service
  Start Command  systemctl stop argus-pdp
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  60 sec  5 sec  Port not reachable  ${hostname}  ${T_PDP_PORT}
  Log  PDP stopped

Stop PEP service
  Start Command  systemctl stop argus-pepd
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  60 sec  5 sec  Port not reachable  ${hostname}  ${T_PEP_PORT}
  Log  PEP stopped
