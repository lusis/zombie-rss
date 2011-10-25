#ScienceDaily news summary module
#$Id: sciencedaily.pl,v 1.1 2003/01/05 02:15:37 psionic Exp $

use strict;
use HTML::TreeBuilder;
#use LWP::Simple;

#sciencedaily_parse_data();

#foreach (@b) {
#   print "Link: " . $_->{'link'}."\n";
#}

sub sciencedaily_parse_data {
   my ($mysql,$myarr,$data) = @_;
   my @entries;
   my @temp;
   my $tree;
   my $base = "http://www.sciencedaily.com";

#   $data = get("http://www.sciencedaily.com/news/summaries.htm");

   $data = join("XXXXX",split("\n",$data));
   $data =~ s'.*<\!--\ BODY\ BEGIN\ -->'';	#Trim the html.
   $data =~ s'<(/?)(b|p|i|br)(.*?)>''gi; 	#Unnecessary tags
   $data =~ s'<font.*?>.*?</font>''gi;		#Remove post-dates and stuff
   $data = join("\n",split("XXXXX",$data));

   $tree = new HTML::TreeBuilder();
   $tree->implicit_tags(0); #We don't need tags that aren't there.
   $tree->parse($data);
   $tree->eof();

   #open(LOG,">dump");
   #$tree->dump(*LOG);
   #close(LOG);

   my @branches = $tree->content_list();

   #Indeces 0-2 are unneeded.
   #3 = URL, 3.0 = Title, 4 = Desc , 5 = URL... etc

   my $x = 0;
   my ($link,$title,$desc);
   foreach my $leaf (@branches) {
      $x++;
      if (ref($leaf) eq 'HTML::Element') { #It's a link..
	 if ($leaf->{class} eq 'fronthead') {
	    $link = $leaf->{'href'};
	    $title = $leaf->{_content}[0];
	 }
      } else {
	 $desc = $leaf;

	 if (length($link) > 0) {
	    $link = $base . $link;
	    #print "Link: $link\n";
	    #print "Title: $title\n";
	    #print "Desc: $desc\n";
	    push (@entries,{'link' => $link, 'title' => $title, 'desc' => $desc});
	 }

	 #reset values.
	 $link = $leaf = $desc = '';
      }
   }

   return @entries;

}
1;
