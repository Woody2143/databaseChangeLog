#!/usr/local/bin/env perl

use strict;
use warnings;
use Config::Simple;
use DBI;

my $cfg;

#TODO Need to get this in a config file
# LIkely don't need to, nor should, do this with the root user
my $rootUser = 'root';
my $rootPass = 'secret';
my @cfgParams = qw(host db user pass);

#NOTE In the original script I had the full path to mysql / mysqldump
#     likely need to make this a var set at the top of the script

if ( -f 'DEVELOPMENT' ) {
    print "\nReading config file DEVELOPMENT. \n\n";
    $cfg = new Config::Simple('DEVELOPMENT');
} else {
    print "\nConfig file DEVELOPMENT missing!\n";
    exit 1;
}

for my $param (@cfgParams) {
   die "Please check your config file, $param is not set!" if (! $cfg->param($param));
}

my $dbName = $cfg->param('db');

print "WARNING! This script will drop your development database: $dbName!\n";
print "Are you sure? (YES / NO)\n";
my $answer = <STDIN>;
chomp $answer;

if ( $answer eq "YES" ) {
    my $dbServerParams = "-h " . $cfg->param('host') . " -u $rootUser -p'$rootPass'";
    eval {
        print "Dropping $dbName\n";
        system "mysql $dbServerParams -e 'DROP DATABASE $dbName;' ";

        print "Creating $dbName\n";
        system "mysql $dbServerParams -e 'CREATE DATABASE $dbName;' ";

        print "Copying data from fraud to $dbName\n";
        system "mysqldump $dbServerParams fraud | mysql $dbServerParams $dbName";
    };
    if ($@) {
        print "Error: $@\n";
    }
} else {
    print "A non-'YES' answer was received.\n";
    print "Exiting...\n";
    exit 1;
}

