# Class: flyway::params
#
# This class defines default parameters used by the main module class flyway
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to flyway class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class flyway::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'flyway',
  }

  $config_dir = $::operatingsystem ? {
    default => '/root/.flw',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  # General Settings
  $my_class = ''
  $dependency_class = ''
  $source_dir = undef
  $source_dir_purge = false
  $options = {}
  $version = 'present'
  $absent = false
  $disable = false
  $instances = {}

  ### General module variables that can have a site or per module default
  $debug = false
  $audit_only = false
  $noops = undef

}
