** Settings ***

Library    OperatingSystem
Library    Process
Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}

*** Keywords ***

Check PAP running
  ${cmd}=  Set Variable  papctl status
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  0

Check PDP running
  ${cmd}=  Set Variable  pdpctl status
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  0

Check PEP running
  ${cmd}=  Set Variable  pepdctl status
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  0

Check port  [Arguments]  ${hostname}  ${port}
  ${cmd}=  Set Variable  pepdctl status
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  0

Port not reachable  [Arguments]  ${hostname}  ${port}
  ${cmd}=  Set Variable  (echo > /dev/tcp/${hostname}/${port}) &>/dev/null
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  1

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
  Start Command  papctl start
  Wait Until Keyword Succeeds  90 sec  5 sec  Check PAP running
  Log  PAP started

Start PDP service
  Start Command  pdpctl start  
  Wait Until Keyword Succeeds  90 sec  5 sec  Check PDP running
  Log  PDP started

Start PEP service
  Start Command  pepdctl start
  Wait Until Keyword Succeeds  90 sec  5 sec  Check PEP running
  Log  PEP started

Stop PAP service
  Start Command  papctl stop
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  90 sec  5 sec  Port not reachable  ${hostname}  ${T_PAP_PORT}
  Log  PAP stopped

Stop PDP service
  Start Command  pdpctl stop
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  90 sec  5 sec  Port not reachable  ${hostname}  ${T_PDP_PORT}
  Log  PDP stopped

Stop PEP service
  Start Command  pepdctl stop
  ${hostname}=  Get hostname
  Wait Until Keyword Succeeds  90 sec  5 sec  Port not reachable  ${hostname}  ${T_PEP_PORT}
  Log  PEP stopped
