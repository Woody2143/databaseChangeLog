#!/usr/local/bin/env perl

use strict;
use warnings;
use Try::Tiny;
use Config::Simple;
use DBI;

#TODO figure out how to handle the 'path' issues.
#     maybe just a variable in the beginning of the script.

my @cfgParams = qw(host db user pass prodDB);
my $cfg;

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
my $user   = $cfg->param('user');
my $pass   = $cfg->param('pass');
my $host   = $cfg->param('host');
my $prodDB = $cfg->param('prodDB');

print "WARNING! This script will drop your development database: $dbName!\n";
print "Are you sure? (YES / NO)\n";
my $answer = <STDIN>;
chomp $answer;

if ( $answer eq "YES" ) {

    my $dsn  = "DBI:mysql:database=$dbName;host=$host";
    my %attr = ( ChopBlanks => 1, RaiseError => 1, AutoCommit => 1);

    my $dbh = DBI->connect($dsn, $user, $pass, \%attr)
        or die "Cannot connect to database: $DBI::errstr";

    try {
        print "Dropping $dbName\n";
        $dbh->do("DROP DATABASE $dbName;");

        print "Creating $dbName\n";
        $dbh->do("CREATE DATABASE $dbName;");

        #NOTE 'system' returns the exit code of what was run;
        #     so '0' is successful. Thus I use 'and' instead
        #     of 'or' if one of the commands fails to run.
        #     This is silly and likely to cause confusion so
        #     at some point I'll work away from using 'system'
        print "Copying data from $prodDB to $dbName\n";
        my $dbServerParams = "-h $host -u $user -p'$pass'";
        system "/usr/local/mysql/bin/mysqldump $dbServerParams $prodDB | /usr/local/bin/mysql $dbServerParams $dbName" and die "Failed to dump $prodDB to $dbName.";

    } catch {
        print "Error: $@\n";
        $dbh->disconnect();
    };

    $dbh->disconnect();

} else {
    print "A non-'YES' answer was received.\n";
    print "Exiting...\n";
    exit 1;
}

