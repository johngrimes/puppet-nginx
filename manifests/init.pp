class nginx {
  include apt

  $pid_file = '/var/run/nginx.pid'

  apt::key { 'nginx':
    key        => '7BD9BF62',
    key_source => 'http://nginx.org/keys/nginx_signing.key',
  }

  apt::source { 'nginx':
    location    => 'http://nginx.org/packages/ubuntu/',
    release     => 'precise',
    repos       => 'nginx',
    include_src => true,
    require     => Apt::Key['nginx']
  }

  package { 'nginx':
    ensure  => present,
    require => Apt::Source['nginx']
  }

  group { 'nginx': ensure => present }

  user { 'nginx':
    ensure  => present,
    gid     => 'nginx',
    groups  => ['soupmail'],
    require => Group['nginx']
  }

  file { 'nginx.conf':
    path    => '/etc/nginx/nginx.conf',
    ensure  => file,
    content => template('nginx/nginx.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    require => Package['nginx'],
    notify  => Service['nginx']
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['nginx'],
      User['nginx'],
      File['nginx.conf']
    ]
  }

  file { ['/etc/nginx/sites-available', '/etc/nginx/sites-enabled']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    recurse => true,
    purge   => true,
    require => Package['nginx']
  }

  monit::conf { 'nginx':
    content => template('nginx/nginx.monit.erb'),
    require => Service['nginx']
  }
}
