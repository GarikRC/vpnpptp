package network::vpn::vpnmandriva;

use base qw(network::vpn);


use common;
use run_program;

sub get_type { 'vpnmandriva' }
sub get_description { N("VPN PPTP") }
sub get_packages { 'drakx-net' }

sub read_config {

run_program::rooted($::prefix,'/usr/bin/vpnmandriva');
end => 1;
}

sub get_settings {
exit;
}

1;
