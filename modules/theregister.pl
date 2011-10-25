#theregister.co.uk module
#$Id: theregister.pl,v 1.2 2003/01/05 02:15:37 psionic Exp $

use strict;
use HTML::TreeBuilder;
#use LWP::Simple;

#theregister_parse_data();

#foreach (@b) {
#   print "Link: " . $_->{'link'}."\n";
#}

sub theregister_parse_data {
   my ($mysql,$myarr,$data) = @_;
   my @entries;
   my @temp;
   my $tree;
   my $base = "http://www.theregister.co.uk";

   #$data = get("http://www.theregister.co.uk/");

   $data = join("XXXXX",split("\n",$data));
   $data =~ s'^.*<hr>''i;				#Trim the html.
   $data =~ s'<(/?)(strong|td|tr|br|u|b)(.*?)>''gi; 	#Unnecessary tags
   $data = join("\n",split("XXXXX",$data));

   $tree = new HTML::TreeBuilder();
   $tree->implicit_tags(0); #We don't need tags that aren't there.
   $tree->parse($data);
   $tree->eof();

   #open(LOG,">dump");
   #$tree->dump(*LOG);
   #close(LOG);

   my @branches = $tree->look_down('class','indexheadlink');

   my ($link,$title);
   foreach my $leaf (@branches) {
      $link = $leaf->{_content}[0]->{'href'};
      $title = $leaf->{_content}[0]->{_content}[0];
      if (ref($title) eq 'HTML::Element') {
	 warn "ERROR - title is HTML::Element. \n\t".$title->as_HTML()."\n";
      } else {
	 $link = $base . $link;
	 push(@entries, { 'link' => $link, 'title' => $title });
      }
   }

   return @entries;

}
1;
