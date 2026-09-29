# requires
#   puppetlabs-apt
#   puppetlabs-stdlib
#
# @api private
#
# @param location
# @param repos
# @param include_src
# @param key
#   Deprecated. The signing key is now installed as a keyring file under
#   /etc/apt/keyrings so the key ID is no longer used. Kept so existing Hiera
#   data continues to work.
# @param key_source
# @param key_content
# @param architecture
# @param append_osname
#
class rabbitmq::repo::apt (
  String[1] $location            = 'https://packagecloud.io/rabbitmq/rabbitmq-server',
  String[1] $repos               = 'main',
  Boolean $include_src           = false,
  String[1] $key                 = '8C695B0219AFDEB04A058ED8F4E789204D206F89',
  String[1] $key_source          = $rabbitmq::package_gpg_key,
  Optional[String[1]] $key_content  = $rabbitmq::key_content,
  Optional[String[1]] $architecture = undef,
  Boolean $append_osname            = true,
) {
  $osname = downcase($facts['os']['name'])
  $pin    = $rabbitmq::package_apt_pin

  $full_location = $append_osname ? {
    true    => "${location}/${osname}",
    default => $location,
  }

  # apt-key has been removed from newer releases (Ubuntu 26.04 onwards), so
  # install the signing key as a keyring file and reference it with signed-by
  # rather than adding it to the legacy trusted.gpg via apt::key.
  #
  # apt tells a binary keyring from an ASCII armoured one by the file
  # extension, so match the extension of the source: .gpg for a binary
  # keyring, otherwise .asc for the armoured format that keyservers and
  # key_content provide.
  if $key_content {
    $keyring_name = 'rabbitmq.asc'

    apt::keyring { $keyring_name:
      content => $key_content,
    }
  } else {
    $keyring_name = $key_source ? {
      /\.gpg$/ => 'rabbitmq.gpg',
      default  => 'rabbitmq.asc',
    }

    apt::keyring { $keyring_name:
      source => $key_source,
    }
  }

  $keyring_path = "/etc/apt/keyrings/${keyring_name}"

  apt::source { 'rabbitmq':
    ensure       => present,
    location     => $full_location,
    repos        => $repos,
    include      => { 'src' => $include_src },
    keyring      => $keyring_path,
    architecture => $architecture,
    require      => Apt::Keyring[$keyring_name],
  }

  if $pin {
    apt::pin { 'rabbitmq':
      packages => '*',
      priority => $pin,
      origin   => inline_template('<%= require \'uri\'; URI(@location).host %>'),
    }
  }
}
