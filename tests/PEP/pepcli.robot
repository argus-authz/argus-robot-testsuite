*** Settings ***
Resource   lib/utils.robot

*** Test Cases ***
Using thread-safe PEP client library (bug 77525)
  [Tags]  cli
  ${output}=  Execute and Check Success  pepcli -V
  Should Contain  ${output}  argus-pep-api-c/2

Right RPM is installed
  [Tags]  cli
  ${cmd}=  Set Variable  rpm -q argus-pep-api-c
  Execute and Check Success  ${cmd}
  
GSI dependency is set to the thread-save library (bug 77739)
  [Tags]  cli
  ${cmd}=  Set Variable  yum deplist argus-gsi-pep-callout
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  libargus-pep.so.2
  
GSI provides is set to the thread-save library (bug 77739)
  [Tags]  cli
  ${cmd}=  Set Variable  yum deplist argus-gsi-pep-callout
  ${output}=  Execute and Check Success  ${cmd}
  Should Contain  ${output}  provider: argus-pep-api-c.x86_64 2
