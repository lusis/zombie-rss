#!/usr/bin/perl
#
# Usage: addrss <[-f urlfile]> OR addrss <RSS URL>
#       a "urlfile" contains URLs of RSS's. Separated by \n characters.
#
# $Id: addrss.pl,v 1.3 2004/07/04 08:39:08 psionic Exp $

use strict;

use Getopt::Long;
use XML::RSS;
use DBI;
use LWP::Simple;
use FileHandle;

undef $/;

my ($file, $ver91);
GetOptions( "f" => \$file, "V" => \$ver91 );

my @lines;

#If the -f flag was specified, assume the next argument is a url.
if ($file) {
   my $file = new FileHandle($ARGV[0]);
   @lines = split("\n",<$file>);
}
else {
   if (!$ARGV[0]) {
      die "Usage: addrss <rssURL>";
   }
   push(@lines,$ARGV[0]);
}


my $dsn = "DBI:mysql:database=newsportal;host=localhost";
my $db = DBI->connect($dsn,"someuser","somepass");

my $count = 0;
foreach my $url (@lines) {

   $count++;
   if ( ($count % 10) == 0) {
      print "\r", ($count / 3.34), "\% done reading.";
   }
   if ($url !~ /^http:\/\//) {
      print STDERR "Invalid url at line $count\n\t$url";
   }
   
   my $rsscontent = get($url);
   
   my $rss;
   if ($ver91) {
      $rss = new XML::RSS( "version" => "0.91" );
   } else {
      $rss = new XML::RSS();
   }
   my ($title, $link, $descr);
   
   $rss->parse($rsscontent);
   $title = $rss->channel('title');
   $link = $rss->channel('link');
   $descr = $rss->channel('description');
   $title =~ s"\'"\\'";
   $descr =~ s"\'"\\'";
   my $time = time();
   
   my $result = $db->prepare("INSERT INTO rss_locations (title,rssurl,link,description,dateadded) VALUES ('$title', '$url', '$link', '$descr', '$time')");
#   print "INSERT INTO rss_locations (title,rssurl,link,description) VALUES ('$title', '$url', '$link', '$descr')\n\n";
   $result->execute();
   $result->finish();
}
print "\r";
$db->disconnect();
