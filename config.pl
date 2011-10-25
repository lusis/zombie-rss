#!/usr/bin/perl
#$Id: config.pl,v 1.6 2002/08/12 06:03:47 psionic Exp $

sub doInit {
   my ($query,$mysql) = @_;
   if ($query->param('DOCONFIG')) {
      my $viewlist;
      foreach $i ($query->param) {
	 if ($i =~ m/^a/) {
	    #We're looking at a selected ID number
	    $i =~ s/^a//;
	    $viewlist = $viewlist .",$i";
            local $setwatch = $mysql->prepare("UPDATE rss_locations SET watched=1 WHERE id=\"".$i."\""); 
            $setwatch->execute();
	 }
      }
      #Drop off the first comma. We want pretty strings!
      $viewlist =~ s/^\,//;
      my $sql = "UPDATE rss_users SET ";
      if ($viewlist) { $sql .= 'watchfeeds="'.$viewlist.'"'; }
      if ($query->param('email')) {
	 if ($viewlist) { $sql .= ', '; }
	 $sql .= 'email="'.$query->param('email').'"';
      }
      if ($query->param('numcols')) {
         if ($query->param('email')) { $sql.= ', '; }
         $sql .= 'numcols="'.$query->param('numcols').'"';
      }
      $sql .= 'WHERE id="'.$query->param('id').'"';

      local $result = $mysql->prepare($sql);

      $result->execute();

      #This should update automatically/next time since the cookie talks
      #to mysql *after* this happens, so the change should be instantaneous.
   }
   print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;

   if ($query->param('DOCONFIG')) {
      print 'Results: '.$query->param."<br>";
      foreach $i ($query->param) {
         print "--&gt; $i = ".$query->param($i)."<br>";
      }
      return 0;
   }

   unless (defined $userdata->{'user'}) {
      print "You aren't a valid or logged-in user. Please sign up!";
      return 0;
   }

   print '<script>
	  function tgl(obj) {
             eval("document.configForm."+obj+".click();");
	  }
          </script>
	  <table border="0" width="100%" cellpadding="0" cellspacing="0">
          <tr>
	  <td align="left" colspan="3">
	  <h3>Configure your RSSNews experience</h3></td>
          <form method="post" action="index.pl" name="topconfigForm">
          </tr>
	  <tr>
          <td>
	  <table border="0" cellpadding="0" cellspacing="0">
	  <tr>
<td><b>Email Address:</b></td>
	  <td width="30"><img src="images/spacer.gif" width="30" height="1"></td>
	  <td align="left" valign="top"><input type="text" class="large" name="email" value="'.$userdata->{'email'}.'" size="25"></td></tr>
	  <tr>
	  <td><b>Columns displayed:</b><br><small>(While reading news)</small></td>
	  <td width="30"><img src="images/spacer.gif" width="30" height="1"></td>
	  <td valign="top" align="left"><input type="text" class="large" name="numcols" size="5" value="'.$userdata->{'numcols'}.'"></td>
	  </tr>
	  <tr>
	  <td><img src="images/spacer.gif"></td>
	  <td valign="top" align="left" colspan="2"><input type="submit" class="large" value="Save Changes"></td>
	  <input type="hidden" name="DOCONFIG" value="1">
	  <input type="hidden" name="page" value="config.pl">
<input type="hidden" name="id" value="'.$userdata->{'id'}.'">
</form>
	  </table>
<tr><td colspan="3">
<hr size="1" width="100%" color="#C4D6E4">
	  <i> Please select which news feeds you want to watch. News article 
	  listings are updated every 10 minutes. If you want a specific 
	  category of feeds, or a certain website added, email me at 
	  psionic@databits.net and I\'ll add whatever I can find.</i>
	  <p>
	  </td></tr>

	  <tr><td colspan="3">
	  <form method="post" action="index.pl" name="ilovegrep">
	  <table border="0">
	  <tr>
	  <td colspan="3">
	  Too many listings? You can clean up the list by searching for a few keywords.
	  </td></tr>
	  <tr>
	  <td align="left"> <input type="text" class="large" name="pattern" size="25" value="'.$query->param('pattern').'"> </td>
	  <td align="left" width="100%"> <input type="submit" class="large" value="Search"> </td>
	  </tr>
	  <td align="left" colspan="2">
	  <input type="checkbox" name="regexp" value="1"'.
	  ( ($query->param('regexp')) ? "CHECKED" : "" ).'> 
	  <small>Regular Expression</small>
	  <input type="checkbox" name="flopmatch" value="1"'.
	  ( ($query->param('flopmatch')) ? "CHECKED" : "" ).'>
	  <small>Invert Search</small>
	  </td>
	  </tr>
	  </table>
<input type="hidden" name="DOGREP" value="1">
	  <input type="hidden" name="page" value="config.pl">
	  </form>
          <hr size="1" width="100%" color="#C4D6E4">
	  ';


   print '<tr><td colspan=2>
	  <table border="0" cellspacing="1" bgcolor="#006699" width="100%"><tr>
          <form method="post" action="index.pl" name="configForm">';

   my $cols = 3; #How many columns to display?
   my $cnt = 0; #Current count

   #Now we're going to try and match patterns...

   my ($regexp,$flopmatch,$pattern);
   if ($query->param('DOGREP')) {
      $pattern = $query->param('pattern');
      $regexp = $query->param('regexp');
      $flopmatch = $query->param('flopmatch');
   }
   else { $pattern = ""; $regexp = "0"; $flopmatch = 0; }
  
   my $sql = "SELECT * FROM rss_locations ";

   if ($pattern ne '') {
      $sql .= "WHERE ";
   }
   my ($not,$opr,$nopr);
   #Negate a pattern search
   if ($flopmatch == 1) { $not = "NOT "; $opr = "AND"; $NOPR = "OR"; } 
   else { $not = ""; $opr = "OR"; $nopr = "AND"; }

   if ($regexp == 1) {
      $sql .= "title $not REGEXP '$pattern' $opr description $not REGEXP '$pattern'";
   }
   else {
      foreach (split(' ',$pattern)) {
	 $sql .= "(title $not LIKE \"%$_%\" $opr description $not LIKE \"%$_%\") AND ";
      }
      if ($pattern ne '') { $sql = substr($sql,0,-5); }
   }
   
   $sql .= " ORDER BY id";

   #print "SQL: $sql<br>";
   my $result = $mysql->prepare($sql);
   $result->execute;

   #Keep track of what the user is already watching...
   my @watcharr = split(',',$userdata->{watchfeeds});

   while (my $myarr = $result->fetchrow_hashref()) {
      if ( ($cnt % $cols == 0) && ($cnt != 0) ) {
	 print '</tr><tr>';
      }
      $cnt++;
      printChannelInfo($myarr,$userdata);

      @watcharr = grep($_ ne $myarr->{'id'},@watcharr);
   }
   foreach (@watcharr) {
      print '<input type="hidden" name="a'.$_.'" value="1">'."\n";
   }

   $result->finish();

   if ( (($cnt % $cols) != 0) && ($cnt > 0) ) {
     for (my $i = ($cnt % $cols);$i < $cols; $i++) {
        print '<td bgcolor="#E6EFF5"><img src="images/spacer.gif"></td>';
     }
   }

   if ($cnt == 0) {
     print '<td bgcolor="#E6EFF5" width="100%" align="center"><b> No results found. </b></td>';
   }

   print '</tr></table></td>';
   print '<tr><td align="right" colspan="3"><hr color="#C4D6E4" size="1">';
   if ($cnt > 0) {
      print '<input type="submit" class="large" value="Submit!">';
   }
   print '</td></tr></table>
          <input type="hidden" name="DOCONFIG" value="1">
          <input type="hidden" name="page" value="config.pl">
          <input type="hidden" name="id" value="'.$userdata->{'id'}.'">
          </form>';
}

sub printChannelInfo {
   my ($myarr,$userdata) = @_;
   
   #Determine if we need to check this.
   my $grp = $myarr->{'id'};
   my @glob = grep(m"^$grp$",split(',',$userdata->{'watchfeeds'}));
   my $check = (@glob[0] eq $grp);
   print '
         <td valign="top" width="33%"';
   if ($check) { print 'bgcolor="#D1F5E4"'; }
   else { print 'bgcolor="#E6EFF5"'; }
   print 'onMouseOver="highlight(this);" onMouseOut="revert(this,\'a'.$myarr->{'id'}.'\');" onClick="tgl(\'a'.$myarr->{'id'}.'\');">
         <table border="0">
         <tr>
         <td valign="top"><input type="checkbox" name="a'.$myarr->{'id'}.'" value="1"';

   if ($check) { print 'CHECKED'; }

   print '></td>
         <td valign="top"><b>'.$myarr->{'title'}.'</b></td>
         <tr><td><img src="images/spacer.gif"></td>
         <td valign="top"><small>'.$myarr->{'description'}.'</small></td>
         </tr>
         </table>
         </td>
         ';
}
1;
