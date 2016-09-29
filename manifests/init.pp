# Class: java8
#
# This module manages Oracle java8
# Parameters: none
# Requires:
#  apt
# Sample Usage:
#  include java8
class java8 {
  case $::operatingsystem {
    debian, ubuntu: {

      include apt
      include systemenv

      case $::operatingsystem {
        debian: {
          $release = 'precise'
        }
        ubuntu: {
          $release = $::lsbdistcodename
        }
      }

      apt::source { 'webupd8team-java':
        location => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
        release  => $release,
        repos    => 'main',
        key      => {
          'id'     => '7B2C3B0889BF5709A105D03AC2518248EEA14886',
          'server' => 'keyserver.ubuntu.com',
        },
        include  => {
          'deb' => true,
          'src' => true,
        }
      }

      file { 'oracle-java8-installer.preseed':
        path   => '/var/tmp/oracle-java8-installer.preseed',
        source => 'puppet:///modules/java8/oracle-java8-installer.preseed',
        mode   => '0600',
        backup => false,
      }

      package { 'oracle-java8-installer':
        responsefile => '/var/tmp/oracle-java8-installer.preseed',
        require      => File['oracle-java8-installer.preseed']
      }

      systemenv::var { 'JAVA_HOME':
        value => '/usr/lib/jvm/java-8-oracle'
      }

      Class['apt::update'] -> Package['oracle-java8-installer']
    }
    default: {
      notice "Unsupported operatingsystem ${::operatingsystem}"
    }
  }
}
