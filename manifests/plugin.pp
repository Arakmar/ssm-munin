# Define: munin::plugin
#
# Parameters:
#
# - ensure: link, present, absent
# - source: when ensure => present, source file
# - target: when ensure => link, link target
# - config: array of lines for munin plugin config
# - config_label: label for munin plugin config
# - config_dir: directory for plugin configuration. Default: /etc/munin/plugin-conf.d
# - plugin_dir: directory for active munin plugins. Default: /etc/munin/plugins
# - plugin_share_dir: directory for available munin plugins: Default: /usr/share/munin/plugins

define munin::plugin (
    $ensure=undef,
    $source=undef,
    $target=undef,
    $config=undef,
    $config_label=undef,
    $config_dir='/etc/munin/plugin-conf.d',
    $plugin_dir='/etc/munin/plugins',
    $plugin_share_dir='/usr/share/munin/plugins',
)
{

    File {
        require => Package['munin-node'],
        notify  => Service['munin-node'],
    }

    case $ensure {
        present: {
            $handle_plugin = true
            $plugin_ensure = present
        }
        absent: {
            $handle_plugin = true
            $plugin_ensure = absent
        }
        link: {
            $handle_plugin = true
            $plugin_ensure = link
            case $target {
                '': {
                    $plugin_target = "${plugin_share_dir}/${title}"
                }
                default: {
                    $plugin_target = "${plugin_share_dir}/${target}"
                }
            }
        }
        default: {
            $handle_plugin = false
        }
    }

    if $config {
        $config_ensure = $ensure ? {
            absent  => absent,
            default => present,
        }
    }
    else {
        $config_ensure = absent
    }


    if $handle_plugin {
        # Install the plugin
        file {"${plugin_dir}/${name}":
            ensure  => $plugin_ensure,
            source  => $source,
            target  => $plugin_target,
            mode    => '0755',
        }
    }

    # Config

    file{"${config_dir}/${name}.conf":
        ensure  => $config_ensure,
        content => template('munin/plugin_conf.erb'),
    }

}
