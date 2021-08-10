** Settings ***

Library    OperatingSystem
Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}


*** Variables ***
${tmp_userkey}  /tmp/tmp-userkey.pem


*** Keywords ***

Create user proxy  [Arguments]  ${cert}=${USERCERT}  ${key}=${USERKEY}  ${vo}=${VO}  ${passwd_file}=${USERPWD_FILE}
  ${user}=  Get user name
  ${owner}=  Get key owner
  ${key}=  Set Variable If  '${user}' == '${owner}'  ${key}  Get temporary user key
  ${cmd}=  Set Variable  voms-proxy-init --voms ${vo} --cert ${cert} --key ${key} --pwstdin < ${passwd_file}
  Execute and Check Success  ${cmd}
  [Teardown]  Remove temporary user key

Get host DN
  ${cmd}=  Set Variable  openssl x509 -in ${HOSTCERT} -subject -noout | sed 's/subject= //'
  ${output}=  Execute Command and Check Success  ${cmd}
  [Return]  ${output}

Get user DN  [Arguments]  ${cert}=${USERCERT}
  ${output}=  Get DN  ${cert}
  [Return]  ${output}

Get DN  [Arguments]  ${cert_path}
  ${cmd}=  Set Variable  openssl x509 -in ${cert_path} -subject -noout | sed 's/subject= //'
  ${output}=  Execute and Check Success  ${cmd}
  [Return]  ${output}

Get key owner  [Arguments]  ${key}=${USERKEY}
  ${output}=  Execute and Check Success  stat -c '%U' ${key}
  [Return]  ${output}

Get user proxy path
  ${uid}=  Get user id
  [Return]  /tmp/x509up_u${uid}

Get temporary user key  [Arguments]  ${key}=${USERKEY}
  OperatingSystem.Copy File  ${key}  ${tmp_userkey}
  [Return]  ${tmp_userkey}

Remove user proxy certificate
  ${filepath}=  Get user proxy path
  OperatingSystem.Remove File  ${filepath}

Remove temporary user key
  OperatingSystem.Remove File  ${tmp_userkey}
