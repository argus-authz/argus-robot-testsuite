*** Variables ***

${ENV_FILE}  ${CURDIR}${/}..${/}env_config.py

${TEST_USER}           test0
${TEST_USER_DN}        "CN=Test0, O=IGI, C=IT"
${TEST_FQAN}           /test.vo

${TEST_DN_UID}         glite
${TEST_DN_UID_GROUP}   testing

${HOSTCERT}            /etc/grid-security/hostcert.pem
${HOSTKEY}             /etc/grid-security/hostkey.pem

${TEST_VO}             test.vo

${POLICY_FILE}         /tmp/policyfile.txt
${DUMMY_ID}            dummy-id
${DUMMY_FILE}          dummy.txt

${DUMMY_PAP}           Dummy
${DEFAULT_PAP}         default

${TEST_RESOURCE}       resource_1
${TEST_ACTION}         action_1
${TEST_RULE}           permit
${TEST_OBLIGATION}     http://glite.org/xacml/obligation/local-environment-map

${RULE_INDETERMINATE}  Indeterminate

${IOTA_USERKEY}        ~/.globus/iota_userkey.pem
${IOTA_USERCERT}       ~/.globus/iota_usercert.pem