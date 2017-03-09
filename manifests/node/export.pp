# Class to export the munin node.
#
# This is separated into its own class to avoid warnings about missing
# storeconfigs.
#
class munin::node::export (
  $address,
  $fqn,
  $masterconfig,
  $masternames,
)
{
  validate_array($masternames)

  if (empty($masternames)) {
    $tag_array = ['munin::master::']
  } else {
    $tag_array = prefix($masternames, "munin::master::")
  }

  @@munin::master::node_definition{ $fqn:
    address    => $address,
    config     => $masterconfig,
    tag        => $tag_array,
  }
}
