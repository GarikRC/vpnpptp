package network::vpn::vpnpptp;

use base qw(network::vpn);


use common;
use run_program;

sub get_type { 'vpnpptp' }
sub get_description { N("VPN PPTP/L2TP/OpenL2TP") }
sub get_packages { 'drakconf' }

sub read_config {

run_program::rooted($::prefix,'/usr/bin/vpnpptp');
end => 1;
}

sub get_settings {
exit;
}

1;
