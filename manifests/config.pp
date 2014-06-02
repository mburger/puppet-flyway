# Class: flyway::config
#
# This class manages flyway configuration
#
# == Variables
#
# Refer to flyway class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by flyway
#
class flyway::config {

  # The whole flyway configuration directory can be recursively overriden
  file { 'flyway.dir':
    ensure  => directory,
    path    => $flyway::config_dir,
    source  => $flyway::source_dir,
    recurse => true,
    purge   => $flyway::bool_source_dir_purge,
    force   => $flyway::bool_source_dir_purge,
    replace => $flyway::manage_file_replace,
    audit   => $flyway::manage_audit,
    noop    => $flyway::noops,
  }
}
