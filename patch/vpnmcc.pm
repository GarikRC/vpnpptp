package network::vpn::vpnmcc;

use base qw(network::vpn);


use common;
use run_program;

sub get_type { 'vpnmcc' }
sub get_description { N("VPN PPTP") }
sub get_packages { 'drakx-net' }

sub read_config {

run_program::rooted($::prefix,'/usr/bin/vpnmcc');
end => 1;
}

sub get_settings {
exit;
}

1;
