
$packages = ['curl', 'git', 'wget', 'voms-clients-cpp', 'myproxy', 'voms-test-ca']

$voms_str = "/C=IT/O=INFN/OU=Host/L=CNAF/CN=vgrid02.cnaf.infn.it
             /C=IT/O=INFN/CN=INFN Certification Authority"


class{'puppet-infn-ca':}->

class{'puppet-test-ca':}->

class{'puppet-robot-framework':}->

package { $packages: ensure => installed, }->

user { 'tester':
  name       => 'tester',
  ensure     => present,
  managehome => true
}->

file {
  '/etc/vomses':
    ensure => directory;

  '/etc/grid-security/vomsdir/test.vo':
    ensure => directory;

  '/etc/vomses/test.vo-vgrid02.cnaf.infn.it':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => '"test.vo" "vgrid02.cnaf.infn.it" "15000" "/C=IT/O=INFN/OU=Host/L=CNAF/CN=vgrid02.cnaf.infn.it" "test.vo" "24"',
    require => File['/etc/vomses'];

  '/etc/grid-security/vomsdir/test.vo/vgrid02.cnaf.infn.it.lsc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "$voms_str",
    require => File['/etc/grid-security/vomsdir/test.vo'];
}
