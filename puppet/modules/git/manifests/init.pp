class git( $keyname ) {

file { 'id_rsaLSGIT':
  name =>'/home/vagrant/.ssh/id_rsa',
  source  => "/vagrant/puppet/modules/git/files/${keyname}",
  mode    => '0600',
  ensure =>present,
}

  /*
exec { "add-key":
  command => "ssh-add /home/vagrant/.ssh/id_rsaLSGIT",
  timeout => 0,
  logoutput => true,
  require => Exec["start-sshagent"],
}

exec { "start-sshagent":
  command => 'echo eval "$(ssh-agent -s)" ',
  timeout => 0,
  logoutput => true,
}*/

}