include epel
include umd4
include testca

include voms::testvo
include mwdevel_argus::clients

$packages = [
  'voms-clients-java',
  'voms-test-ca',
]

package { $packages:
  ensure => 'present',
  install_options => ['--nogpgcheck'],
}

include python

package { 'robotframework':
  ensure   => installed,
  require  => Package['pip'],
  provider => 'pip',
}
package { 'robotframework-httplibrary':
  ensure   => installed,
  require  => [Package['pip'], Package['robotframework']],
  provider => 'pip',
}

class { 'java' :
  package => 'java-1.8.0-openjdk-devel',
}

user { 'tester':
  ensure     => present,
  name       => $title,
  password   => Sensitive('password'),
  managehome => true,
  groups     => ['wheel'],
}

Class['epel']
-> Class['umd4']
-> Class['testca']
-> Class['voms::testvo']
-> Class['mwdevel_argus::clients']
-> Class['python']
-> Class['java']
-> Package[$packages]
-> Package['robotframework']
-> User['tester']
