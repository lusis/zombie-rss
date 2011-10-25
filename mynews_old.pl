#!/usr/bin/perl
#$id$

sub doInit {
   my ($query) = @_;
   print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;

   my @newslist = split(',',$userdata->{'watchfeeds'});
   my @seenlist = split(',',$userdata->{'viewdata'});

   #print "You are currently watching: ";
   #print join(", ",@newslist);
   #print '<br>';
   #print "You have viewed: ";
   #print join(", ",@seenlist);
   #print '<p>';
   my @nonews;

   #print "News sources are updated every ten minutes.<br>";
   #print '<hr size="1" width="100%" color="#C4D6E4">';

   if (scalar(@newslist) == 0) {
      print "<b> You aren't subscribed to any news sources. You can change your subscriptions in the <a href=\"?page=config.pl\">Settings panel</a>.</b>";
   }

   print '<table border="0" width="100%">';
   my $cnt = 0;
   foreach $i (@newslist) {

      local $channel = $mysql->prepare("SELECT title,id,link FROM rss_locations WHERE id=\"".$i."\"");
      local $item = $mysql->prepare("SELECT * FROM rss_newslist WHERE channel=\"".$i."\" ORDER BY date DESC LIMIT 0,30");
      $channel->execute();
      $item->execute();

      #$channel should only return one entry here.
      my $title = $channel->fetchrow_hashref();
      my $HTML = "";
      $HTML .= '<td valign="top" style="border-color=black;" width="';

      $HTML .= pctWid($userdata->{'numcols'});
      $HTML .= '" height="100%">
	     <table border="0" cellspacing="1" bgcolor="#636C73" width="100%" height="100%">
	     <tr>
	     <td bgcolor="#CDDDEA" valign="center" width="100%">
	     <table border="0" cellspacing="0" cellpadding="0">
	     <td width="100%">
		<b>&nbsp;'.$title->{'title'}.'</b>
	     </td>
	     <td align="right" valign="top" bgcolor="#CDDDEA" nowrap>
		<small>
		<a href="?page=markall.pl&channel='.$title->{'id'}.'&time='.time().'">
		Mark Read
		</a>
		</small>
             </td>
	     </table>
	     </td>
	     </tr>
	     <tr>
	     <td bgcolor="#E2EAF0" valign="top" colspan="2" height="100%">';
      my $itemcount = 0;
      while (my $myarr = $item->fetchrow_hashref()) {
	 local $id = $myarr->{'id'};
         local @res = grep(m"^$id$",@seenlist);
         if (scalar(@res) == 0) {
	    $itemcount++;
            $HTML .= '
	          <table border="0">
	          <tr>
	          <td colspan="2" valign="bottom">&middot;&nbsp;<a href="?page=view.pl&itemid='.$myarr->{'id'}.'" target="_new">'.$myarr->{'title'}.'</a></td>
	          </tr>
		  ';
            if ($myarr->{'description'} =~ m//) {
	       $HTML .= '
		     <tr>
		     <td valign="top"><img src="images/spacer.gif" width="20" height="1"><small>'.$myarr->{'description'}.'</small></td>
		     </tr>';
            }
	    $HTML .= '
		     </table>';

	 }
   
      }
      $HTML .= "</td></tr></table></td>";
      if ($itemcount == 0) {
	 push(@nonews,$title);
      }
      else {
         if ( ($cnt % $userdata->{'numcols'} == 0) && ($cnt != 0) ) {
            print '</tr><tr>';
         }
         $cnt++;
         print $HTML;
      }
      
   }
   print "</td></tr></table>";
   #print '<hr size="1" width="100%" color="#C4D6E4">';
   if (scalar(@nonews) > 0) {
      print 'There were no unread articles for the following source(s):<br>';
      foreach $i (@nonews) {
         print '&nbsp;&nbsp;&nbsp;&middot &nbsp;'.$i->{'title'}.
	       ' <i>&lt;'.$i->{'link'}.'&gt; ['.$i->{'id'}.']</i><br>';
      }
   }
}

sub pctWid {
   my ($cols) = @_;

   local $temp = sprintf("%2d",(1.0 / $cols)*100);
   return $temp.'%';
}
1;
