#!/usr/bin/perl
#$Id: logout.pl,v 1.2 2002/06/30 02:33:19 psionic Exp $

sub doInit {
   my ($query) = @_;

   local $cookie = $query->cookie(-name=>'session_id', -value=>'');
   print $query->header(-cookie=>$cookie);
}

sub printContent {
print '
       You are now logged out. :)
       ';
}
1;
