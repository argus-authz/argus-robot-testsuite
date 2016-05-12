
$packages = ['curl', 'git', 'wget', 'voms-clients-cpp', 'myproxy', 'voms-test-ca']

class{'puppet-infn-ca':}->

class{'puppet-test-ca':}->

class{'puppet-robot-framework':}->

package { $packages: ensure => installed, }->

user { 'tester':
  name       => 'tester',
  ensure     => present,
  managehome => true
}
