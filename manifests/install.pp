# Class: flyway::install
#
# This class installs flyway
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
class flyway::install {

  package { $flyway::package:
    ensure  => $flyway::manage_package,
    noop    => $flyway::noops,
  }
}
