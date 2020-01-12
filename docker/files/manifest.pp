
$packages = ['ca_TERENA-eScience-SSL-CA-3', 'curl', 'voms-clients-java', 'myproxy', 'voms-test-ca']

$voms_str = '/DC=org/DC=terena/DC=tcs/C=IT/ST=Lazio/L=Frascati/O=Istituto Nazionale di Fisica Nucleare/CN=vgrid02.cnaf.infn.it
/C=NL/ST=Noord-Holland/L=Amsterdam/O=TERENA/CN=TERENA eScience SSL CA 3'

class { 'mwdevel_infn_ca': } ->
class { 'mwdevel_test_ca': } ->
class { 'mwdevel_robot_framework': } ->
class { 'mwdevel_argus::clients': } ->
package { $packages: ensure => latest, } ->
user { 'tester':
  ensure     => present,
  name       => 'tester',
  managehome => true
} ->
file {
  '/etc/vomses':
    ensure => directory;

  '/etc/grid-security/vomsdir':
    ensure => directory;

  '/etc/grid-security/vomsdir/test.vo':
    ensure => directory;

  '/etc/vomses/test.vo-vgrid02.cnaf.infn.it':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => '"test.vo" "vgrid02.cnaf.infn.it" "15000" "/DC=org/DC=terena/DC=tcs/C=IT/ST=Lazio/L=Frascati/O=Istituto Nazionale di Fisica Nucleare/CN=vgrid02.cnaf.infn.it" "test.vo" "24"',
    require => File['/etc/vomses'];

  '/etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $voms_str,
    require => File['/etc/grid-security/vomsdir/test.vo'];
}
