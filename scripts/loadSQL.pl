#!/usr/bin/env perl

use warnings;
use strict;
use Modern::Perl;
use File::Basename;
use Data::Dumper;
use Config::Simple;
use DBI;
use DBIx::MultiStatementDo;

my $cfg;
if ( -f "DEVELOPMENT") {
    $cfg = new Config::Simple('DEVELOPMENT');
} elsif ( -f "PRODUCTION") {
    $cfg = new Config::Simple('PRODUCTION');
} else {
    die "Unable to locate DEVELOPMENT or PRODUCTION config files.";
}

my $dsn      = "DBI:mysql:database=" . $cfg->param('db') . ";host=" . $cfg->param('host');
my %attr     = ( ChopBlanks => 1, RaiseError => 1, AutoCommit => 0);

my $dbh = DBI->connect($dsn, $cfg->param('user'), $cfg->param('pass'), \%attr)
    or die "Cannot connect to database: $DBI::errstr";

my @files = <SQL/*.sql>;

for my $file (sort @files) {
    my $filename = basename($file);

    if (!$filename) {
        die "Must supply the filename of an SQL file."
    }

    my $rows;
    eval {
        $rows = $dbh->do(q{SELECT filename FROM Change_Log WHERE filename = ?}, undef, $filename);
    };

    if ($@) {
        die "Database error: $DBI::errstr\n";
    }

    if ($rows == 0) {

        my $sql = do {
            local $/ = undef;
            open my $fh, "<", $file
                or die "Unable to open $file: $!";
            <$fh>;
        };

        my $batch = DBIx::MultiStatementDo->new( dbh => $dbh );

        my @results;
        #TODO move to Try::Tiny
        eval {
            @results = $batch->do($sql)
                or die $batch->dbh->errstr;
            $dbh->do(q{INSERT INTO `Change_Log` (filename) VALUES (?)}, undef, $filename);
            $dbh->commit();
            print "SQL script $filename - " . scalar(@results) . " statements successfully executed.\n";
        };
        if ($@) {
            $dbh->rollback();
            $dbh->disconnect();
            die "Database error: $@\n";
        }


    } else {
        print "SQL script $filename has already been run.\n";
        next;
    }
}

$dbh->disconnect();

