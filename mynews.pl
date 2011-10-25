#!/usr/bin/perl
#$id$

sub doInit {
   my ($query) = @_;
   print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;
   print STDERR "OK!\n";

   my @newslist = split(',',$userdata->{'watchfeeds'});
   my @seenlist = split(',',$userdata->{'viewdata'});

   # Split up @seenlist into 3 parts, global >time, channel>time, and id marks
   my @globalmark = grep(/^>/,@seenlist);
   my @channelmark = grep(/^[0-9]+>/,@seenlist);
   my @idmark = grep(/^[0-9]+$/,@seenlist);

   my $sql = "SELECT title,id,link FROM rss_locations WHERE 1 " . ( (scalar(@newslist) > 0) ? "AND (" . join(" OR ", map("id=$_", @newslist)) . ")" : "" );
   print STDERR "Looking for locations: \n$sql\n";

   my $newsresult = $mysql->prepare($sql);
   $newsresult->execute() or die("Failed trying to execute newsresult query, $!\n");
   print STDERR "Finished...\n";

   my $newslist_sql = "SELECT * FROM rss_newslist";
	$newslist_sql .= " WHERE (".join(" OR ", map("channel=$_",@newslist)).")" if (scalar(@newslist));
   #$newslist_sql .= " AND ".join(" AND ", map("id!=$_",@seenlist) . " ORDER BY date DESC") if (scalar(@seenlist) > 0);
	$newslist_sql .= " ORDER BY date DESC";
   my $newsitems = $mysql->prepare($newslist_sql);

   print STDERR "SQL: $newslist_sql";
   $newsitems->execute() or die("Failed trying to execute newsitems query, $!\n");
   print STDERR "DONE!\n";
   
   print STDERR "<b>FOO SQL: </b><code>$newslist_sql</code><hr>";
   # Ok, now we have to go through all the news items.
   #my $all = $newsitems->fetchall_hashref('id');
   my $allitems;
   while (my $myarr = $newsitems->fetchrow_hashref()) {
      #print $myarr->{'title'} . "<br>\n";
      next if (scalar(@{$allitems->{$myarr->{'channel'}}}) > 20);
      push(@{$allitems->{$myarr->{'channel'}}}, $myarr);
   }
   #foreach (keys(%{$allitems})) {
      #print "$_ = " . $allitems->{$_} . "<br>\n";
   #}

   my @nonews;

   #print "News sources are updated every ten minutes.<br>";
   #print '<hr size="1" width="100%" color="#C4D6E4">';

   if (scalar(@newslist) == 0) {
      print "<b> You aren't subscribed to any news sources. You can change your subscriptions in the <a href=\"?page=config.pl\">Settings panel</a>.</b>";
   }

   print '<table border="0" width="100%">';
   my $cnt = 0;
   while (my $i = $newsresult->fetchrow_hashref()) {

      local $title = $i;

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
		<a href="?page=markall.pl&channel='.$title->{'id'}.'&time='.$title->{'id'}.'>'.time().'">
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

      # ITERATE OVER ALL NEWS ITEMS FOR THIS CHANNEL
      foreach my $myarr (@{$allitems->{$title->{'id'}}}) {
	 local $id = $myarr->{'id'};
         #local @res = grep(m"^$id$",@seenlist);
         #if (scalar(@res) == 0) {
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

	 #}
   
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
