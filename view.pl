#!/usr/bin/perl
#$Id: view.pl,v 1.1 2002/07/25 20:55:01 psionic Exp $

sub doInit {
   my ($query,$mysql,$userdata) = @_;
   
   print $query->header(-cookie=>$cookie);
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;
   local @viewed = split(',',$userdata->{'viewdata'});
   push(@viewed,$query->param('itemid'));

   $mysql->do("UPDATE rss_users SET viewdata=\"".join(',',@viewed)."\" WHERE id=\"".$userdata->{'id'}."\"");
   local $url;
   local $res = $mysql->prepare("SELECT * FROM rss_newslist WHERE id=\"".$query->param('itemid')."\"");
   $res->execute();
   local $href = $res->fetchrow_hashref();
   print '<a href="'.$href->{'link'}.'">Click here to view "'.$href->{'title'}.'"</a>';

   #print join(',',@viewed);
}
1;
