#!/usr/bin/perl
#$Id: search.pl,v 1.3 2003/01/03 19:10:31 psionic Exp $

sub doInit {
   my ($query,$mysql,$userdata) = @_;

   print $query->header();
}

sub printContent {
   my ($query,$mysql,$userdata) = @_;
   
   my $keywords = $query->param('keywords');

   print '
	 <!-- Begin Search Form -->
	 <form method="post" action="index.pl">
	 <table border="0" cellpadding="2" cellspacing="0">
	    <tr>
	    <td>
	       Search: 
	    </td>
	    <td>
	       <input type="text" size="20" class="large" name="keywords" value="';
   print (($keywords ne '') ? $keywords : '');

   print '">
	    </td>

	    <td>
	       <input type="submit" value="Submit" class="large">
	    </td>
	    </tr>
	    <tr>
	    <td colspan="2" align="right">
	       <input type="checkbox" name="regexp" value="1" ';
   print (($query->param('regexp') == 1) ? "CHECKED" : "");
   print '>
	       Regular Expression
	    </td>
	    </tr>
	 </table>

	 <input type="hidden" name="page" value="search.pl">
	 <input type="hidden" name="DOSEARCH" value="1">
	 </form>
	 <!-- End Search Form -->
	 ';

   if ($query->param('DOSEARCH')) {
      #Use mysql pattern matching per keyword.
      # -> SELECT ... WHERE title LIKE "%k1%" AND title LIKE "%k2%" ...
      #   -> AND description LIKE "%k1%" ...
      #Where k1 is the first keyword, etc.

      my $sql = "SELECT * FROM rss_newslist WHERE ";
     
      if ($query->param('regexp') == 1) {
	 $sql .= "title REGEXP '$keywords' OR description REGEXP '$keywords'";

      }
      else {
	 foreach (split(' ',$keywords)) {
	    $sql .= "(title LIKE '%$_%' OR description LIKE '%$_%')";
	    $sql .= " AND ";
	 }

	 #Drop the last 4 characters. ('AND ')
	 $sql = substr($sql,0,-4);
      }

      my $newslist = $mysql->prepare($sql);
      $newslist->execute();

      print $newslist->rows() . " matches found\n";
      print '<hr size="0">'."\n";
      my $x = 0;
      my $color;

      print '<table border="0" bgcolor="#B9D3E7" cellspacing="1" cellpadding="0" width="100%">';
      my $COLUMNS = 2;
      while (local $myarr = $newslist->fetchrow_hashref()) {
         if ($x % $COLUMNS == 0) {
	    $color = ($color eq '#E2EAF0') ? "#DDE3EC" : "#E2EAF0";
	    print '<tr>'
	 }

	 print '<td>';
	 #$color = (($x % $COLUMNS == 0) ? "#E2EAF0" : "#D9D1E7";
	 $x++;

	 print '
		  <table border="0" cellspacing="0">
		  <tr bgcolor="'.$color.'">
		  <td bgcolor="'.$color.'" valign="top" width="100%">
		     <a href="?page=view.pl&itemid='.$myarr->{'id'}.'">
		     '.$myarr->{'title'}.'</a>
		  </td>
		  <td bgcolor="'.$color.'" valign="top">
		  <!-- INSERT SOURCE HERE -->
		  </td>
		  </tr>
		  </table>
	       ';
      }
      for ($x; $x % $COLUMNS != 0; $x++) {
	 print '<td bgcolor="'.$color.'">&nbsp;</td>';
      }
      print '</td></tr></table>';
   }
}
1;
