/**
 * Set defaults
 */
# set default path for execution
Exec { path => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin' }

/**
 * Run "apt-get update" before installing packages
 */
exec { 'apt-update':
    command => '/usr/bin/apt-get update'
}
Exec['apt-update'] -> Package <| |>

/*exec { 'wget -O /home/vagrant/bin/modman https://raw.github.com/colinmollenhour/modman/master/modman':
  creates => "/home/vagrant/bin/modman",
  require => Package['wget'],
}*/

exec { 'git-install':
  command => '/usr/bin/apt-get -y install build-essential git'
}
exec{'retrieve-modman':
  command => "/usr/bin/wget -q https://raw.github.com/colinmollenhour/modman/master/modman -O /usr/local/bin/modman",
  creates => "/usr/local/bin/modman",
}



file{'/usr/local/bin/modman':
  mode => 0755,
  require => Exec["retrieve-modman"],
}

package { 'curl':
    ensure => 'present',
}

group { 'puppet':
    ensure => 'present',
}

class { 'apache2':
    document_root => '/vagrant/www',
}

/**
 * MySQL config
 */
class { 'mysql':
    root_pass => 'r00t',
}

/**
 * Magento config
 */
class { 'magento':
    /* install magento [true|false] */
    install =>  false,

  /* source url in : puppet/modules/magento/manifests/init.pp
   http://www.magentocommerce.com/downloads/assets/${version}/magento-${version}.tar.gz",*/
    /*  magento community versions (downloaded online)*/
    #version     => '1.9.0.1',
    #version     => '1.8.1.0',
    #version    => '1.7.0.2',
    #version    => '1.7.0.1',
    #version    => '1.7.0.0',
    #version    => '1.6.2.0',
    #version    => '1.6.1.0',
    #version    => '1.6.0.0',
    #version    => '1.5.1.0',
    #version    => '1.5.0.1',
  /*  local tar.gz Magento source available in puppet/modules/magento/files folder?
     Use this for Enterprise versions! (set true when local file available)
     */
  #version => 'Magento-EE-1.14.0.1.tar.gz',

  local =>  false,



  /* magento database settings */
    db_user     => 'magento',
    db_pass     => 'magento',

    /* magento admin user */
    admin_user  => 'admin',
    admin_pass  => '123123abc',

    /* use rewrites [yes|no] */
    use_rewrites => 'no',
  /*
  For base_url => 'http://magento.localhost:8080/magento'
  add :192.168.33.10       magento.localhost in hostmachine's hosts
  */
    base_url => 'http://newmagento.localhost.com/',
}


class { 'git':
  keyname => 'id_rsa',
}

/**
 * Import modules
 */
include apt
include mysql
include apache2
include php5
include composer
include magento
include git
