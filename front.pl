#!/usr/bin/perl
#$Id: front.pl,v 1.3 2003/02/14 19:21:47 psionic Exp $

sub doInit {
   my ($query,$mysql,$userdata) = @_;

   print $query->header();

}

sub printContent {
   my ($query,$mysql,$userdata) = @_;
 
   local $result = $mysql->prepare("SELECT * FROM rss_newslist ORDER BY date DESC LIMIT 0,15");
   $result->execute();

   print '
	  <table border="0" bgcolor="#006699" cellspacing="1" width="70%" align="center">
	  <tr>
	  <td bgcolor="#D3DFED" valign="top">
	  <font size="+1"> Today\'s latest news stories. Now.</font>
	  <br>
	  <small>
	  Are you tired of having to float from website to website reading news stor ies? RSSNews might be your answer. RSSNews offers you a central location to find all your news and gives you the ability to browse news based on category. Only want technology news? Medical news? International? Not a problem! Now you can have CNN, Slashdot, and many more from the same portal!<br>
	  Sign up now!</small>
	  </td>
	  </tr>
	  <tr>
	  <td bgcolor="#E2EAF0" valign="top" width="100%">
                 <!-- begin "recent" source additions -->
	  <table border="0" cellspacing="1" width="100%">
	  <tr><td>
	  <b>Recent Source Additions</b>
	  </td></tr>
	  ';
   my $recount = 0;
   my $recent = $mysql->prepare("SELECT * FROM rss_locations ORDER BY dateadded DESC LIMIT 0,12");
   $recent->execute();
   print '<tr>';
   while (my $resarr = $recent->fetchrow_hashref()) {
      print '<td><a href="'.$resarr->{'link'}.'">'.$resarr->{'title'}.'</a>
             </td>';
      $recount++;
      if ($recount % 3 == 0) { print "</tr><tr>"; }
   }
   print '       </tr>
	  </table>
	  <!-- end "recent" additions -->
	  </td>
	  </tr>
	  <tr>
	  <td bgcolor="#E2EAF0" valign="top" width="100%">
	  <!-- begin news listing -->
	  <table border="0" cellspacing="0" cellpadding="4" width="100%">
	  ';
   my $count = 0;
   while (my $myarr = $result->fetchrow_hashref()) {
      local $res = $mysql->prepare("SELECT title,link FROM rss_locations WHERE id=\"".$myarr->{'channel'}."\"");
      $res->execute();
      local $channel = $res->fetchrow_hashref();
      local $color;
      if ($count % 2 == 0) { $color = '#DEE6F2'; }
      else { $color = '#E3EFF8'; }
      print '<tr>';
      _printnews($myarr,$channel,$color);
      print '</tr>';
      $count++;
   }
   print '
	  </td>
	  </tr>
	  </table>
          </td></tr></table>
	  ';
}

sub _printnews {
   my ($myarr,$chan,$color) = @_;

   print '
	  <td bgcolor="'.$color.'">
	  <a href="'.$myarr->{'link'}.'"><b>'.$myarr->{'title'}.'</b></a>
	  <small>
	  [<a href="'.$chan->{'link'}.'">'.$chan->{'title'}.'</a>]
	  </small>
	  <br>
	  <small>
	  '.$myarr->{'description'}.'
	  </small>
	  </td>
	  ';

}
1;
