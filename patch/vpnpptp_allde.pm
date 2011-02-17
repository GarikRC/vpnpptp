package network::vpn::vpnpptp_allde;

use base qw(network::vpn);


use common;
use run_program;

sub get_type { 'vpnpptp' }
sub get_description { N("VPN PPTP/L2TP") }
sub get_packages { 'vpnpptp-allde' }

sub read_config {

run_program::rooted($::prefix,'/usr/bin/vpnpptp');
end => 1;
}

sub get_settings {
exit;
}

1;
