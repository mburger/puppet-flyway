define flyway::instance (
  $db,
  $db_user,
  $db_pass,
  $db_owner,
  $db_schema     = 'public',
  $db_server     = 'localhost',
  $db_port       = '5432',
  $db_url_params = 'ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory',
  $flyway_table  = 'flyway_schema_version',
  $flyway_base   = $::flyway::config_dir,
) {

  require flyway

  if $title =~ /^(flw-)/ {
    $instance_name = $title
  } else {
    $instance_name = "flw-${title}"
  }

  file { "${flyway_base}/${instance_name}.cfg":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 0400,
    content => template('jumio/flyway/flyway.cfg.erb'),
  }

  case $db_server {
    '', 'localhost','127.0.0.1': {
      postgresql::hba { "flyway_${::fqdn}_${db_server}_${db}":
        ensure    => present,
        type      => 'hostssl',
        database  => $db,
        user      => $db_user,
        address   => 'localhost',
        method    => 'md5',
        tag       => "postgresql_${::environment}_${::location}"
      }

      postgresql::role { "flyway_role_${::fqdn}_${db_server}_${db}_${db_user}":
        rolename  => $db_user,
        superuser => true,
        password  => $db_pass,
      }
    }
    default: {
      @@postgresql::hba { "flyway_${::fqdn}_${db_server}_${db}":
        ensure    => present,
        type      => 'hostssl',
        database  => $db,
        user      => $db_user,
        address   => $::fqdn,
        method    => 'md5',
        tag       => "postgresql_${::environment}_${::location}"
      }

      @@postgresql::role { "flyway_role_${::fqdn}_${db_server}_${db}_${db_user}":
        rolename  => $db_user,
        superuser => true,
        password  => $db_pass,
        tag       => "postgresql_${::environment}_${::location}"
      }
    }
  }

}
