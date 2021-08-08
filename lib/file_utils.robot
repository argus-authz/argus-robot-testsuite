** Settings ***

Library    OperatingSystem
Library    String
Resource   variables.robot

Resource   common_utils.robot

Variables  ${ENV_FILE}


*** Keywords ***

Check directory  [Arguments]  ${directory}
  SSHLibrary.Directory Should Exist  ${directory}
  Execute Command and Check Success  [ ! -z "$(ls -A ${directory})" ]

Check file  [Arguments]  ${file}
  SSHLibrary.File Should Exist  ${file}
  Execute Command and Check Success  [ -s ${file} ]

Copy Directory  [Arguments]  ${source}  ${destination}
  Execute Command and Check Success  cp -rf ${source} ${destination}

Copy File  [Arguments]  ${source}  ${destination}
  Execute Command and Check Success  cp -f ${source} ${destination}

Create Directory  [Arguments]  ${directory}
  Execute Command and Check Success  mkdir -p ${directory}

Create File on Server  [Arguments]  ${file}  ${content}
  Execute Command and Check Success  echo "${content}" > ${file}
  [Return]  ${file}

Create working directory
  ${time}=  Get Time
  ${time}=  Replace String Using Regexp  ${time}  ${SPACE}  _
  ${time}=  Replace String Using Regexp  ${time}  :|-  ${EMPTY}
  ${workdir}=  Join Path  ${TMP_DIR}  argus-testsuite_${time}
  Create Directory  ${workdir}
  [Return]  ${workdir}
  
Empty file  [Arguments]  ${file}
  Create File  ${file}

Make backup of the configuration
#  ${workdir}=  Create working directory
#  Set Environment Variable  WORKDIR  ${workdir}
  ${workdir}=  Set Variable  ${BCK_DIR}
  ${bck_conf_dir}=  Join Path  ${workdir}  conf_backup
  Create Directory  ${bck_conf_dir}
  Copy File  ${T_PDP_CONF}/${T_PDP_INI}  ${bck_conf_dir}
  Copy File  ${T_PEP_CONF}/${T_PEP_INI}  ${bck_conf_dir}
  Copy File  ${T_PEP_CONF}/vo-ca-ap-file  ${bck_conf_dir}
  Copy File  ${T_PAP_CONF}/${T_PAP_ADMIN_INI}  ${bck_conf_dir} 
  Copy File  ${T_PAP_CONF}/${T_PAP_AUTH_INI}  ${bck_conf_dir}
  Copy File  ${T_PAP_CONF}/${T_PAP_CONF_INI}  ${bck_conf_dir}
  Copy File  ${GRIDDIR}/${GRIDMAPFILE}  ${bck_conf_dir}
  Copy File  ${GRIDDIR}/${GROUPMAPFILE}  ${bck_conf_dir}
  Copy File  ${GRIDDIR}/${VOMSGRIDMAPFILE}  ${bck_conf_dir}
  Copy File  ${GRIDDIR}/${AUTHN_PROFILE_FILE}  ${bck_conf_dir}
  Copy Directory  ${GRIDDIR}/${GRIDMAPDIR}    ${bck_conf_dir}

Remove all leases in gridmapdir
  Remove File  ${GRIDDIR}/${GRIDMAPDIR}/%*

Remove Directory  [Arguments]  ${directory}
  SSHLibrary.Directory Should Exist  ${directory}
  Execute Command and Check Success  rm -rfv ${directory}

Remove File  [Arguments]  ${file}
  SSHLibrary.File Should Exist  ${file}
  Execute Command and Check Success  rm -fv ${file}

Restore grid files
  ${bck_conf_dir}=  Join Path  ${BCK_DIR}  conf_backup
  Copy File  ${bck_conf_dir}/${GRIDMAPFILE}  ${GRIDDIR}/${GRIDMAPFILE}
  Copy File  ${bck_conf_dir}/${GROUPMAPFILE}  ${GRIDDIR}/${GROUPMAPFILE}
  Copy File  ${bck_conf_dir}/${VOMSGRIDMAPFILE}  ${GRIDDIR}/${VOMSGRIDMAPFILE}
  Copy File  ${bck_conf_dir}/${AUTHN_PROFILE_FILE}  ${GRIDDIR}/${AUTHN_PROFILE_FILE}

Restore PAP configuration
  ${bck_conf_dir}=  Join Path  ${BCK_DIR}  conf_backup
  Copy File  ${bck_conf_dir}/${T_PAP_CONF_INI}  ${T_PAP_CONF}/${T_PAP_CONF_INI}
  Copy File  ${bck_conf_dir}/${T_PAP_AUTH_INI}  ${T_PAP_CONF}/${T_PAP_AUTH_INI}
  Copy File  ${bck_conf_dir}/${T_PAP_ADMIN_INI}  ${T_PAP_CONF}/${T_PAP_ADMIN_INI}

Restore PDP configuration
  ${bck_conf_dir}=  Join Path  ${BCK_DIR}  conf_backup
  Copy File  ${bck_conf_dir}/${T_PDP_INI}  ${T_PDP_CONF}/${T_PDP_INI}

Restore PEP configuration
  ${bck_conf_dir}=  Join Path  ${BCK_DIR}  conf_backup
  Copy File  ${bck_conf_dir}/${T_PEP_INI}  ${T_PEP_CONF}/${T_PEP_INI}
  Copy File  ${bck_conf_dir}/vo-ca-ap-file  ${T_PEP_CONF}/vo-ca-ap-file
  Restore grid files
  
Restore configurations
  Restore PAP configuration
  Restore PDP configuration
  Restore PEP configuration
  Remove Directory  ${BCK_DIR}  
  
Touch pool account  [Arguments]  ${account}
  ${file}=  Set Variable  ${GRIDDIR}/${GRIDMAPDIR}/${account}
  Touch  ${file}
  