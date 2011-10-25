#!/usr/bin/perl
#$Id: createaccount.pl,v 1.1 2002/08/09 06:29:52 psionic Exp $

my $errmsg;

use Digest::MD5 qw(md5_base64);

sub doInit {
   my ($query,$mysql) = @_;
   
   my $result = $mysql->prepare("INSERT INTO rss_users (user) VALUES (\"".$query->param('user')."\")");
   $result->execute();
   $errmsg = $errmsg. "<h3> Signup Successful! :) </h3>";
   
   #If DOSIGNUP is not set, then we aren't signing up just yet.
   print $query->header();
}

sub printContent {
   my ($query,undef,$userdata) = @_;
   if ($query->param('DOSIGNUP')) {
      #Here we can tell you what happened (success/fail/etc). WEEEEEEEEE!
      print $errmsg;
      return 0;
   }
   print 'Account created, huzzah!';
	print '<br>Username: ' . $userdata->{'ENV'};
}
1;
