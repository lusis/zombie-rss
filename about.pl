#!/usr/bin/perl
#$Id: about.pl,v 1.3 2003/01/02 08:04:57 psionic Exp $

my $d;

sub doInit {
  my ($query,$mysql,$userdata) = @_;

  print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;

   print '
	 <table border="0" width="60%" cellpadding="3" cellspacing="1" bgcolor="#B6D0E4">
	 <tr><td align="left" bgcolor="#CDDDEA" colspan="2" width="100%">
	   <big>News from all over the world in one location.</big>
	   </td></tr>
	   <tr>
	   <td bgcolor="#E2EAF0" valign="top" width="100%">
	      <table border="0">
	      <tr><td>
	      <small>
	      Are you tired of having to float from website to website reading news stor ies? RSSNews might be your answer. RSSNews offers you a central location to find all your news and gives you the ability to browse news based on category. Only want technology news? Medical news? International? Not a problem! Now you can have CNN, Slashdot, and many more from the same portal!<br>
	      Sign up now!</small>
	      </td></tr>
	      </table>
           </td>
	   <td bgcolor="#E2EAF0" valign="top" align="left" nowrap>
	      <small><b>Statistics</b></small>
	      <br>
	      <small>
	      Sources: ';
   local $result = $mysql->prepare("SELECT id FROM rss_locations");
   $result->execute();
   print $result->rows;
   print '
	      <br>
	      Articles: ';
   $result = $mysql->prepare("SELECT id FROM rss_newslist");
   $result->execute();
   print $result->rows;
   print '
	      </small>
	    </td></tr>
	    </table>
	    </td>
	 ';
}
1;
