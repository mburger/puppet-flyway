# Class: flyway::spec
#
# This class is used only for rpsec-puppet tests
# Can be taken as an example on how to do custom classes but should not
# be modified.
#
# == Usage
#
# This class is not intended to be used directly.
# Use it as reference
#
class flyway::spec inherits flyway {

  # This just a test to override the arguments of an existing resource
  # Note that you can achieve this same result with just:
  # class { "flyway": template => "flyway/spec.erb" }

  File['flyway.conf'] {
    content => template('flyway/spec.erb'),
  }

}
