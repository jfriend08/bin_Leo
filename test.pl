#!/usr/bin/perl -w

# Copyright 2012- Christopher M. Frenz
# This script is free software - it may be used, copied, redistributed, and/or modified
# under the terms laid forth in the Perl Artistic License

use Parallel::Loops;
use WWW::Mechanize;
use strict;

my @links=('http://www.apress.com','http://www.oreilly.com','http://www.osborne.com','http://samspublishing.ca');

my $maxProcs = 4;
my $pl = Parallel::Loops->new($maxProcs);

my @newlinks;
$pl->share(\@newlinks);

$pl->foreach (\@links, sub{
    my $link=$_;
    my $ua=WWW::Mechanize->new();
    $ua->get($link);
    my @urls=$ua->links();
    for my $url(@urls){
        $url=$url->url;
        push (@newlinks, $url);
    }
    
});

for my $newlink(@newlinks){
    print "$newlink \n";
}
