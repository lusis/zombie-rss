#Module to parse RSS/RDF news sources
#$Id: RSS.pl,v 1.3 2002/08/20 23:12:09 psionic Exp $

use XML::RSS;

sub RSS_parse_data {
   my ($mysql,$myarr,$data) = @_;
   my $rss;

   $rss = new XML::RSS();
   $rss->parse($data);


   return @{$rss->{'items'}};

   #$mysql->do("UPDATE rss_locations SET lastupdate='".time()."'
	       #WHERE id='".$myarr{'id'}."'");

   #foreach my $item (@{$rss->{'items'}}) {
      #my ($title,$link,$descr,$date);
      #$title = quotemeta($item->{'title'});
      #$link = quotemeta($item->{'link'});
      #$descr = quotemeta($item->{'descr'});
      #$date = time();
#
#
      ##Lets check if this article is already posted
      #my $check = $mysql->prepare("SELECT id FROM rss_newslist WHERE
				   #title='$title' AND channel='$channel'");
      #$check->execute();
#
      ##If there are no matches, let's add it to the database.
      #if ($check->rows == 0) {
	 #$mysql->do("INSERT INTO rss_newslist
		     #(title,channel,link,description,date)
		     #VALUES ('$title', '$channel', '$link', '$descr',
		     #'$date')");
      #}
   #}
}
1;
