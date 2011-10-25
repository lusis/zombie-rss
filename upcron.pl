#!/usr/bin/perl
#
# A little tool to download RSS/RDF files and read them into a database
#
# $Id: upcron.pl,v 1.17 2004/07/04 08:39:00 psionic Exp $

#use strict;
use DBI;
use LWP::Simple;
use DirHandle;     #So we can read the modules directory
use POSIX;
use IO::File;

undef $/;

#Timestamp.
local *prefix = sub { return strftime("[%m/%d/%Y %H:%M:%S]",localtime()); };

#open(STDOUT,">> logs/upcron-out.log") or warn "Couldn't redirect STDOUT: $!\n";
#open(STDERR,">> logs/upcron-err.log") or warn "Couldn't redirect STDERR: $!\n";

autoflush STDOUT 1;
autoflush STDERR 1;

#Load up the config file.
my ($sql_type,$sql_server,$sql_dbname,$sql_user,$sql_pass,
    $portal_useauth,$portal_type,$portal_basedir);
open(CONFIG,"./rssnews.conf");
eval(<CONFIG>);
close(CONFIG);

#Load all available modules.
my $modules = new DirHandle("modules/");
if (defined $modules) {
   while (defined($_ = $modules->read)) {
      #Only load it if it's a .pl file
      if ($_ =~ m"\.pl$") {
	 require("./modules/".$_);
	 print prefix() . " Loading module: $_\n";
      }
   }
   undef $modules;
}
else {
   die prefix() . " I can't find the modules/ directory!?\n".
       prefix() . " PWD is " . $ENV{PWD} . "\n";
}


my $mysql = DBI->connect("DBI:$sql_type:database=$sql_dbname;host=$sql_server",
                      "$sql_user", "$sql_pass") or die "Connection failed.";

my $result = $mysql->prepare("SELECT title,rssurl,id,module FROM rss_locations WHERE watched=1");
$result->execute();

print prefix() . " Now updating news sources from ",scalar($result->rows)," sites.\n";

my $count = 0;

open(SQLOUT,">news.sql");

while (my $myarr = $result->fetchrow_hashref()) {

   $count++;
   my $pct = $count / scalar($result->rows)*100;

   my $channel = $myarr->{'id'};
   my $modsub = $myarr->{'module'}."_parse_data";

   #Is it safe to assume that all data is via http?
   my $content = get($myarr->{'rssurl'});

   #next if ($content eq "");
 
   my $title = $myarr->{'title'};
   if (length($title) > 46) { $title = substr($title,0,46) . "..."; }

   print prefix() . " " . $title;
   printf(" [%2.2f%%]\n",$pct);
   my @arr = &$modsub($mysql,$myarr,$content); #parses results into an @array

   $mysql->do("UPDATE rss_locations SET lastupdate='".time()."'
	       WHERE id='".$myarr{'id'}."'");

   my $SQL_STATEMENT;
   foreach my $item (@arr) {
      my ($title,$link,$descr,$date);
      $title = quotemeta($item->{'title'});
      $link = quotemeta($item->{'link'});
      $descr = quotemeta($item->{'descr'});
      $date = time();

      #Lets check if this article is already posted
      #my $check = $mysql->prepare("SELECT id FROM rss_newslist WHERE
				   #title='$title' AND channel='$channel'");
      #$check->execute();

      #If there are no matches, let's add it to the database.
      #if ($check->rows == 0) {
	 
	  #print SQLOUT "INSERT INTO rss_newslist (title,channel,link,description,date) VALUES ('$title', '$channel', '$link', '$descr', '$date')\n";
	  $descr = "No description given..." if (length($descr) == 0);
	  print SQLOUT "$title	$channel	$link	$date\n";

	 #$mysql->do("INSERT INTO rss_newslist
		     #(title,channel,link,description,date)
		     #VALUES ('$title', '$channel', '$link', '$descr',
		     #'$date')");

      #}

   }

}

close(SQLOUT);

$mysql->do("DELETE FROM rss_newslist");
$mysql->do("LOAD DATA INFILE '/u9/psionic/public_html/news/news.sql' INTO TABLE rss_newslist (title,channel,link,date)");


print prefix() . " Completed updates of watched news listings.\n";

$result->finish();
$mysql->disconnect();
