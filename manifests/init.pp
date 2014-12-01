# = Class: flyway
#
# This is the main flyway class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, flyway class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $flyway_myclass
#
# [*dependency_class*]
#   Name of the class that provides third module dependencies
#
# [*source_dir*]
#   If defined, the whole flyway configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $flyway_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $flyway_source_dir_purge
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $flyway_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $flyway_absent
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module
#   Can be defined also by the (top scope) variable $flyway_disable
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $flyway_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $flyway_puppi_helper
#   and $puppi_helper
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $flyway_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $flyway_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# Default class params - As defined in flyway::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of flyway package
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# See README for usage patterns.
#
class flyway (
  $my_class                   = params_lookup( 'my_class' ),
  $dependency_class           = params_lookup( 'dependency_class' ),
  $source_dir                 = params_lookup( 'source_dir' ),
  $source_dir_purge           = params_lookup( 'source_dir_purge' ),
  $options                    = params_lookup( 'options' ),
  $version                    = params_lookup( 'version' ),
  $absent                     = params_lookup( 'absent' ),
  $disable                    = params_lookup( 'disable' ),
  $debug                      = params_lookup( 'debug' , 'global' ),
  $audit_only                 = params_lookup( 'audit_only' , 'global' ),
  $noops                      = params_lookup( 'noops' ),
  $package                    = params_lookup( 'package' ),
  $config_dir                 = params_lookup( 'config_dir' ),
  $config_file_mode           = params_lookup( 'config_file_mode' ),
  $config_file_owner          = params_lookup( 'config_file_owner' ),
  $config_file_group          = params_lookup( 'config_file_group' ),
  $instances                  = params_lookup( 'instances' )
  ) inherits flyway::params {

  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_disable=any2bool($disable)
  $bool_debug=any2bool($debug)
  $bool_audit_only=any2bool($audit_only)

  ### Definition of some variables used in the module
  $manage_package = $flyway::bool_absent ? {
    true  => 'absent',
    false => $flyway::version,
  }

  $manage_file = $flyway::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $flyway::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $flyway::bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Include custom class if $my_class is set
  if $flyway::my_class {
    include $flyway::my_class
  }

  ### Include dependencies provided by other modules
  if $flyway::dependency_class {
    require $flyway::dependency_class
  }

  ### Managed resources
  case $flyway::bool_absent {
    true: {
      class { 'flyway::config': } ->
      class { 'flyway::install': } ->
      Class['flyway']
    }
    false:{
      class { 'flyway::install': } ->
      class { 'flyway::config': } ->
      Class['flyway']
    }
  }

  ### Create instances for integration with Hiera
  if $instances != {} {
    validate_hash($instances)
    create_resources(flyway::instance, $instances)
  }

  ### Debugging, if enabled ( debug => true )
  if $flyway::bool_debug == true {
    file { 'debug_flyway':
      ensure  => $flyway::manage_file,
      path    => "${settings::vardir}/debug-flyway",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $flyway::noops,
    }
  }

}
