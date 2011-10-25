#!/usr/bin/perl
#
# Clean up the database
#
# $Id: cleanup.pl,v 1.6 2004/07/04 08:38:57 psionic Exp $

use DBI;
use POSIX;

undef $/;

#Timestamp
local *prefix = sub { return strftime("[%m/%d/%Y %H:%M:%S]",localtime()); };

open(STDOUT,">>logs/cleanup-out.log") or warn "Couldn't redirect STDOUT: $!\n";
open(STDERR,">>logs/cleanup-err.log") or warn "Couldn't redirect STDERR: $!\n";

my ($sql_type,$sql_server,$sql_dbname,$sql_user,$sql_pass,
   $portal_useauth,$portal_type,$portal_basedir);
open(CONFIG,"./rssnews.conf");
eval(<CONFIG>);
close(CONFIG);

my $db = DBI->connect("DBI:$sql_type:database=$sql_dbname;host=$sql_server",
                      "$sql_user", "$sql_pass") or die "Connection failed.";

#Update the watched-feed list
$db->do("UPDATE rss_locations SET watched=0");

my $result = $db->prepare("SELECT watchfeeds FROM rss_users");
$result->execute;

my @watch;
while (my $myarr = $result->fetchrow_hashref()) {
   local @sp = split(',',$myarr->{'watchfeeds'});
   foreach $i (@sp) {
      local @find = grep(m"^$i$",@watch);
      if (scalar(@find) == 0) { push(@watch,$i); }
   }
}

#Now make sure only the ones which are watched, are flagged that way.
$db->do("UPDATE rss_locations SET watched=0");
print prefix() . " Watching: ";
foreach $i (@watch) {
  $db->do("UPDATE rss_locations SET watched=1 WHERE id=\"".$i."\"");
  print "$i, ";
}
print "\n";
$result->finish();
print prefix() . " Wiping articles that are older than 10 days\n";
#10 days = 864000 seconds
local $time = time() - 864000;
$result = $db->prepare("SELECT * FROM rss_newslist WHERE date<\"".$time."\"");
$result->execute();
print prefix() . " There are ".$result->rows." old articles to remove.\n";
if ($result->rows > 0) {
   print prefix() . " REMOVING ". $result->rows." ARTICLES FROM THE DB!\n";
}

#Make the ID array:
my @oldids;
while (my $myarr = $result->fetchrow_hashref()) {
   push(@oldids,$myarr->{'id'});
}

my $users = $db->prepare("SELECT * FROM rss_users");
$users->execute();

################################################################
if (0) {
   while (my $user = $users->fetchrow_hashref()) {
      print prefix() . " Processing UID ".$user->{'id'}."\n";
      my @list = split(',',$user->{'viewdata'});
      print prefix() . " B:\t".@list." items\n";
      foreach $id (@oldids) {
	 @list = grep(/[^($id)]/,@list);
      }
      print prefix() . " A:\t".@list." items\n";
      $db->do("UPDATE rss_users SET viewdata=\"".join(',',@list)."\" 
	       WHERE id=\"".$user->{'id'}."\"");
      print prefix() . " Removed old entries from userid ".$user->{'id'}."\n";
   }
}
################################################################

$db->do("DELETE FROM rss_newslist WHERE date<\"".$time."\"");
print prefix() . " Wiped the articles from the news list.\n";

$db->disconnect();
