class apt::update {
  include apt::params

  exec { 'apt_update':
    command     => "${apt::params::provider} update",
    logoutput   => 'on_failure',
    refreshonly => true,
    timeout     => $apt::update_timeout,
    tries       => $apt::update_tries,
    try_sleep   => 1
  }
}
