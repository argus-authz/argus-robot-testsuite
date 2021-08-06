** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    SSHLibrary
Resource   variables.robot

Resource   file_utils.robot
Resource   service_utils.robot
Resource   x509_utils.robot

Variables  ${ENV_FILE}

*** Keywords ***

Add conf parameter  [Arguments]  ${file}  ${parameter}  ${value}
  ${cmd}=  Set Variable  sed -i '/^${parameter}.*/d' ${file}
  Execute and Check Success  ${cmd}
  ${row}=  Set Variable  ${parameter} = ${value}
  Append To File  ${file}  \n${row}

Change parameter value  [Arguments]  ${file}  ${parameter}  ${value}
  Execute and Check Success  sed -i 's/${parameter}\ =.*/${parameter}\ =\ ${value}/' ${file}

Check string presence into file  [Arguments]  ${file}  ${string}
  ${cmd}=  Set Variable  grep -q ${string} ${file}
  Execute and Check Success  ${cmd}

Comment parameter  [Arguments]  ${file}  ${parameter}
  Execute and Check Success  sed -i 's/${parameter}/#${parameter}/g' ${file}

Escape char  [Arguments]  ${str}  ${char}
  ${output}=  String.Replace String  ${str}  ${char}  \\${char}
  [Return]  ${output}

Execute and Check Success  [Arguments]  ${cmd}
  ${rc}  ${output}=  Run and Return RC And Output  ${cmd}
  Should Be Equal As Integers  ${rc}  0  ${cmd} failed with ${output}  False
  [Return]  ${output}

Execute and Check Failure  [Arguments]   ${cmd}
  ${rc}  ${output}=   Run and Return RC And Output  ${cmd}
  Should Not Be Equal As Integers  ${rc}  0  ${cmd} failed with ${output}
  [Return]  ${output}

Execute Command and Check Success  [Arguments]  ${cmd}
  ${output}  ${rc}=  Execute Command  ${cmd}  return_rc=True
  Should Be Equal As Integers  ${rc}  0  ${cmd} failed with ${output}  False
  [Return]  ${output}

Execute Command and Check Failure  [Arguments]   ${cmd}
  ${output}  ${rc}=   Execute Command  ${cmd}  return_rc=True
  Should Not Be Equal As Integers  ${rc}  0  ${cmd} failed with ${output}
  [Return]  ${output}

Get hostname
  ${output}=  Execute Command  hostname
  [Return]  ${output}

Get match  [Arguments]  ${item}  ${regexp}
  ${result}=  Get Regexp Matches  ${item}  ${regexp}  1
  ${elem}=  Get From List  ${result}  0
  [Return]  ${elem}

Get user id
  ${output}=  Execute and Check Success  id -u
  [Return]  ${output}

Get user name
  ${output}=  Execute and Check Success  id -nu
  [Return]  ${output}

Replace string  [Arguments]  ${file}  ${old_string}  ${new_string}
  ${cmd}=  Set Variable  sed -i 's/${old_string}/${new_string}/g' ${file}
  Execute and Check Success  ${cmd}

Read parameter from INI file  [Arguments]  ${file}  ${parameter}
  ${cmd}=  Set Variable  awk -F "=" '/${parameter}/ {print $2}' ${file} | xargs
  ${output}=  Execute and Check Success  ${cmd}
  [Return]  ${output}

Setup Argus suite
  Make backup of the configuration
  Start PAP service
  Start PDP service
  Start PEP service

Should Contain Ignore Case  [Arguments]  ${item1}  ${item2}  ${msg}=None
  ${str1}=  Convert To Lowercase  ${item1}
  ${str2}=  Convert To Lowercase  ${item2}
  Should Contain  ${str1}  ${str2}  ${msg}

Teardown Argus suite
  Restore configurations
  Restore services

Open Connection And Log In  [Arguments]  ${hostname}=${SSH_HOST}
   Open Connection     ${hostname}
   Login With Public Key  ${SSH_USER}  ${SSH_KEYFILE}
