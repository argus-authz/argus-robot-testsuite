** Settings ***

Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}

*** Keywords ***

Reload policy  [Arguments]  ${host}=${T_PDP_HOST}  ${port}=${T_PDP_ADMIN_PORT}
  ${passwd}=  Resolve PDP admin password
  ${cmd}=  Set Variable  curl -Gv http://${host}:${port}/reloadPolicy?password=${passwd}
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  HTTP/1.1 200 OK

Resolve PDP admin password
  ${file}=  Set Variable  ${T_PDP_CONF}/${T_PDP_INI}
  ${var}=  Get Environment Variable  T_PDP_ADMIN_PASSWORD  None
  ${password}=  Run Keyword If  '${var}' is 'None'  Read passwd from file  ${file}
  ...           ELSE  Set variable  %{T_PDP_ADMIN_PASSWORD}
  [Return]  ${password}

Read passwd from file  [Arguments]  ${file}
  SSHLibrary.File Should Exist  ${file}
  ${value}=  Read parameter from INI file  ${file}  adminPassword
  [Return]  ${value}
