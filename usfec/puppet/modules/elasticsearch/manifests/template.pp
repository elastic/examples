# == Define: elasticsearch::template
#
#  This define allows you to insert, update or delete templates that are used within Elasticsearch for the indexes
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*file*]
#   File path of the template ( json file )
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*content*]
#   Contents of the template ( json )
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*host*]
#   Host name or IP address of the ES instance to connect to
#   Value type is string
#   Default value: localhost
#   This variable is optional
#
# [*port*]
#   Port number of the ES instance to connect to
#   Value type is number
#   Default value: 9200
#   This variable is optional
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch::template(
  $ensure  = 'present',
  $file    = undef,
  $content = undef,
  $host    = 'localhost',
  $port    = 9200
) {

  require elasticsearch

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if ! is_integer($port) {
    fail("\"${port}\" is not an integer")
  }

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 6,
    try_sleep => 10
  }

  # Build up the url
  $es_url = "http://${host}:${port}/_template/${name}"

  # Can't do a replace and delete at the same time

  if ($ensure == 'present') {

    # Fail when no file or content is supplied
    if $file == undef and $content == undef {
      fail('The variables "file" and "content" cannot be empty when inserting or updating a template.')
    } elsif $file != undef and $content != undef {
      fail('The variables "file" and "content" cannot be used together when inserting or updating a template.')
    } else { # we are good to go. notify to insert in case we deleted
      $insert_notify = Exec[ "insert_template_${name}" ]
    }

  } else {

    $insert_notify = undef

  }

  # Delete the existing template
  # First check if it exists of course
  exec { "delete_template_${name}":
    command     => "curl -s -XDELETE ${es_url}",
    onlyif      => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
    notify      => $insert_notify,
    refreshonly => true
  }

  if ($ensure == 'absent') {

    # delete the template file on disk and then on the server
    file { "${elasticsearch::configdir}/templates_import/elasticsearch-template-${name}.json":
      ensure  => 'absent',
      notify  => Exec[ "delete_template_${name}" ],
      require => Exec[ 'mkdir_templates_elasticsearch' ],
    }
  }

  if ($ensure == 'present') {

    if $content == undef {
      # place the template file using the file source
      file { "${elasticsearch::configdir}/templates_import/elasticsearch-template-${name}.json":
        ensure  => 'present',
        source  => $file,
        notify  => Exec[ "delete_template_${name}" ],
        require => Exec[ 'mkdir_templates_elasticsearch' ],
      }
    } else {
      # place the template file using content
      file { "${elasticsearch::configdir}/templates_import/elasticsearch-template-${name}.json":
        ensure  => 'present',
        content => $content,
        notify  => Exec[ "delete_template_${name}" ],
        require => Exec[ 'mkdir_templates_elasticsearch' ],
      }
    }

    exec { "insert_template_${name}":
      command     => "curl -sL -w \"%{http_code}\\n\" -XPUT ${es_url} -d @${elasticsearch::configdir}/templates_import/elasticsearch-template-${name}.json -o /dev/null | egrep \"(200|201)\" > /dev/null",
      unless      => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
      refreshonly => true,
      loglevel    => 'debug'
    }

  }

}
