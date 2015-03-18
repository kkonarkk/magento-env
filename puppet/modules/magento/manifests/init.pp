class magento( $install, $local,  $db_user, $db_pass, $version, $admin_user, $admin_pass, $use_rewrites, $base_url ) {

/* keep the this in the single line*/
$mageinstall = "${apache2::document_root}/install.php -- --license_agreement_accepted yes  --locale en_US  --timezone America/Los_Angeles  --default_currency USD  --db_host localhost  --db_name magentodb  --db_user ${db_user}  --db_pass ${db_pass}  --url ${base_url} --use_rewrites ${use_rewrites}  --use_secure no  --secure_base_url ${base_url}  --use_secure_admin no  --skip_url_validation yes  --admin_firstname Store  --admin_lastname Owner  --admin_email magento@example.com  --admin_username ${admin_user}  --admin_password ${admin_pass}"

host { 'newmagento.localhost.com':
  ip      => '192.168.33.10',
}

if $install {
exec { "create-magentodb-db":
  unless  => "/usr/bin/mysql -uroot -p${mysql::root_pass} magentodb",
  command => "/usr/bin/mysqladmin -uroot -p${$mysql::root_pass} create magentodb",
  require => Service["mysql"],
}

exec { "grant-magentodb-db-all":
  unless  => "/usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
  command => "/usr/bin/mysql -uroot -p${$mysql::root_pass} -e \"grant all on *.* to magento@'%' identified by '${db_pass}' WITH GRANT OPTION;\"",
  require => [ Service["mysql"], Exec["create-magentodb-db"] ],
}

exec { "grant-magentodb-db-localhost":
  unless  => "/usr/bin/mysql -u${db_user} -p${db_pass} magentodb",
  command => "/usr/bin/mysql -uroot -p${$mysql::root_pass} -e \"grant all on *.* to magento@'localhost' identified by '${db_pass}' WITH GRANT OPTION;\"",
  require => Exec["grant-magentodb-db-all"],
}
if $local
{
/* $a = file("/vagrant/puppet/modules/magento/files/${version}",'/dev/null')
 if($a != '')
 {
   file { 'magesrc':
     name =>"/tmp/magento-${version}",
     content  => $a,
     mode    => '777',
   }
 */

file { 'download-magento':
  name =>"/tmp/${version}",
  source  => "/vagrant/puppet/modules/magento/files/${version}",
  ensure =>present,
}
exec { "untar-magento":
  cwd     => $apache2::document_root,
  command => "sudo /bin/tar xzf /tmp/${version}",
  timeout => 0,
  logoutput => true,
}
}
else
{
exec { "download-magento":
  cwd     => "/tmp",
  command => "/usr/bin/wget http://www.magentocommerce.com/downloads/assets/${version}/magento-${version}.tar.gz",
  creates => "/tmp/magento-${version}.tar.gz",
}
exec { "untar-magento":
  cwd     => $apache2::document_root,
  command => "/bin/tar xzf /tmp/magento-${version}.tar.gz",
  timeout => 0,
  logoutput => true,
  require => Exec["download-magento"],
}
}
exec { "move-magentofiles":
  cwd     => $apache2::document_root,
  command => "mv magento/* magento/.htaccess . ",
  timeout => 0,
  logoutput => true,
  require => Exec["untar-magento"],
}

exec { "magento-cleanup":
  cwd     => $apache2::document_root,
  command => "rm -r magento*",
  timeout => 0,
  logoutput => true,
  require => Exec["move-magentofiles"],
}

exec { "setting-permissions":
  cwd     => "${apache2::document_root}",
  command => "/bin/chmod 550 mage; /bin/chmod o+w var var/.htaccess app/etc; /bin/chmod -R o+w media",
  require => Exec["untar-magento"],
}

exec { "install-magento":
  cwd     => "${apache2::document_root}",
  creates => "${apache2::document_root}/app/etc/local.xml",
  command => "/usr/bin/php -f ${mageinstall} ",
  logoutput => true,
  timeout => 0,
  require => [ Exec["setting-permissions"], Exec["create-magentodb-db"], Package["php5-cli"] ],

}

exec { "register-magento-channel":
  cwd     => "${apache2::document_root}",
  onlyif  => "/usr/bin/test `${apache2::document_root}/mage list-channels | wc -l` -lt 2",
  command => "${apache2::document_root}/mage mage-setup",
  require => Exec["install-magento"],
}
}

file { "/etc/apache2/sites-available/magento":
  source  => '/vagrant/puppet/modules/magento/files/vhost_magento',
  require => Package["apache2"],
  notify  => Service["apache2"],
}

file { "/etc/apache2/sites-enabled/magento":
  ensure  => 'link',
  target  => '/etc/apache2/sites-available/magento',
  require => Package["apache2"],
  notify  => Service["apache2"],
}

exec { "sudo a2enmod rewrite":
  require => Package["apache2"],
  notify  => Service["apache2"],
}
}
