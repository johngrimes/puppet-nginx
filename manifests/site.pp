define nginx::site($content) {
  file { "/etc/nginx/sites-available/${title}":
    ensure  => file,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    require => Package['nginx'],
    notify  => Service['nginx']
  }

  file { "/etc/nginx/sites-enabled/${title}":
    ensure  => link,
    target  => "/etc/nginx/sites-available/${title}",
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    require => Package['nginx'],
    notify  => Service['nginx']
  }
}
