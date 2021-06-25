include epel
include umd4
include testvos
include testca

$packages = [
  'voms-clients-java',
  'voms-test-ca'
]

include 'mwdevel_argus::clients'

package { $packages:
  ensure => 'latest',
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
-> Class['python']
-> Class['java']
-> Class['testvos']
-> Class['testca']
-> Package[$packages]
-> Package['robotframework']
-> User['tester']
