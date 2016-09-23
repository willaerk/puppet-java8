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
          apt::source { 'webupd8team-java':
            location => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
            release  => 'precise',
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

          Apt::Source['webupd8team-java'] -> Class['apt::update']
          Class['apt::update'] -> Package['oracle-java8-installer']
        }
        ubuntu: {
          apt::ppa { 'ppa:webupd8team/java': }

          Apt::Ppa['ppa:webupd8team/java'] -> Class['apt::update']
          Class['apt::update'] -> Package['oracle-java8-installer']
        }
      }

      file { 'java8.preseed':
        path   => '/var/tmp/oracle-java8-installer.preseed',
        source => 'puppet:///modules/java8/java.preseed',
        mode   => '0600',
        backup => false,
      }

      package { 'oracle-java8-installer':
        responsefile => '/var/tmp/oracle-java8-installer.preseed',
        require      => File['java8.preseed']
      }

      systemenv::var { 'JAVA_HOME':
        value => '/usr/lib/jvm/java-8-oracle/jre'
      }
    }
    default: {
      notice "Unsupported operatingsystem ${::operatingsystem}"
    }
  }
}
