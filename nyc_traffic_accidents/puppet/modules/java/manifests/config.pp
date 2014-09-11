# On Debian systems, if alternatives are set, manually assign them.
class java::config ( ) {
  case $::osfamily {
    Debian: {
      if $java::use_java_alternative != undef and $java::use_java_alternative_path != undef {
        exec { 'update-java-alternatives':
          path    => '/usr/bin:/usr/sbin:/bin:/sbin',
          command => "update-java-alternatives --set ${java::use_java_alternative} --jre",
          unless  => "test /etc/alternatives/java -ef '${java::use_java_alternative_path}'",
        }
      }
    }
    default: {
      # Do nothing.
    }
  }
}
