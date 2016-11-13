#!/usr/bin/perl

use strict;
use warnings;
use Fatal qw(open close);
use File::Spec;
use Carp;
use Data::Dumper;

use constant DEBUG => 0;

my %command = (
   "query node"            => "q_node.txt",
   "q node"                => "q_node.txt",
   "query node MYJUNKNODE" => "q_node_empty.txt",
   "show threads"          => "show_threads.txt",
   "query status"          => "q_status.txt",
   "q status"              => "q_status.txt",
   "-quiet query status"   => "q_status_quiet.txt",
   "query session"         => "q_session.txt",
   "select * from nodes"   => "select_nodes.txt",
   "select * from domains" => "select_domains.txt",
   "select * from domains, nodes where domains.DOMAIN_NAME = nodes.DOMAIN_NAME" =>
                              "select_nodes_domains_join.txt",
);

my @command;

foreach my $arg (@ARGV) {
   next if ($arg =~ m/^-/);   
   push @command, $arg;
}

my $command = join ' ', @command;

DEBUG && carp "DEBUG:dsmadmc:command: ", Dumper(\@command);

# Nettoyage de la commande
$command =~ s/\s+/ /g;
$command =~ s/^\s+//;
$command =~ s/\s+$//;

if (exists $command{$command}) {
    my $file = File::Spec->catfile($ENV{DSM_DIR}, $command{$command});
    if (-f $file) {
        my $rc;
        open my $fh, '<', $file;
        while (<$fh>) {
            print;
            if (m/return code was (\d+)/) {
                $rc = $1;
            }
        }
        close $fh;
        DEBUG && carp "DEBUG:dsmadmc:command: '$command' rc=$rc\n";
        exit $rc if $rc;
    } else {
        croak "Emulate file '$command{$command}' => '$file' does not exist.\n";
    }
} else {
    croak "Command '$command' not emulated.\n";
}
