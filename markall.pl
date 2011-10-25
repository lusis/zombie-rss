#!/usr/bin/perl
#$Id: markall.pl,v 1.2 2002/08/12 05:46:53 psionic Exp $

sub doInit {
   my ($query) = @_;

   print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;

   #Mark all current watched news as read.
   my @newslist;
   if ($query->param('channel')) {
      #They want to only mark a certain site as read.
      push(@newslist,$query->param('channel')); 
   }
   else {
      @newslist = split(',',$userdata->{'watchfeeds'});
   }
   my @viewed = split(',',$userdata->{'viewdata'});

   foreach $i (@newslist) {
      local $item = $mysql->prepare("SELECT * FROM rss_newslist WHERE channel=\"".$i."\" AND date<".$query->param('time')."");
      $item->execute();

      while (my $myarr = $item->fetchrow_hashref()) {
         local $id = $myarr->{'id'};
         local @res = grep(m"^$id$",@viewed);
         if (scalar(@res) == 0) {
            #This is new news, let's mark it.
            push(@viewed,$id);
         }
      }
   }

   local $result = $mysql->prepare("UPDATE rss_users SET viewdata=\"".join(",",@viewed)."\" WHERE user=\"".$userdata->{'user'}."\"");
   $result->execute();

   print "Marked all watched news items as read.";
}
1;
