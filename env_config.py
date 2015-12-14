#!/usr/bin/env python

# Variables set to run the scripts on your system

# Locations for storing needed files
TMP_DIR='/tmp'

# Home Directories
T_PAP_HOME='/usr/share/argus/pap'
T_PDP_HOME='/usr/share/argus/pdp'
T_PEP_HOME='/usr/share/argus/pepd'

# Configuration scripts and locations
T_PDP_CONF=T_PDP_HOME + '/conf'
T_PEP_CONF=T_PEP_HOME + '/conf'
T_PAP_CONF=T_PAP_HOME + '/conf'
T_PDP_INI='pdp.ini'
T_PEP_INI='pepd.ini'
T_PAP_ADMIN_INI='pap-admin.properties'
T_PAP_AUTH_INI='pap_authorization.ini'
T_PAP_CONF_INI='pap_configuration.ini'

T_PAP_PORT='8150'
T_PAP_ADMIN_PORT='8151'
T_PDP_PORT='8152'
T_PDP_ADMIN_PORT='8153'
T_PEP_PORT='8154'
T_PEP_ADMIN_PORT='8155'

# Init-scripts
T_PAP_CTRL='papctl'
T_PDP_CTRL='pdpctl'
T_PEP_CTRL='pepdctl'

# CLI's
PEPCLI='/usr/bin/pepcli'
PAP_ADMIN='/usr/bin/pap-admin'

# Grid specific files
GRIDDIR='/mnt/grid-security'
GRIDMAPFILE='grid-mapfile'
GROUPMAPFILE='groupmapfile'
VOMSGRIDMAPFILE='voms-grid-mapfile'
GRIDMAPDIR='gridmapdir'

# Test specific configurations
USERCERT='~/user_cert/test0.cert.pem'
USERKEY='~/user_cert/test0.newkey.pem'
# in case of empty passphrase set this to /dev/null
USERPWD_FILE='~/user_cert/password'

VO="test.vo"
VO_PRIMARY_GROUP="/test.vo"
VO_SECONDARY_GROUP="/test.vo/G2"
VOMSES_STRING='"test.vo" "vgrid02.cnaf.infn.it" "15004" "/C=IT/O=INFN/OU=Host/CN=vgrid02.cnaf.infn.it" "test.vo"'

