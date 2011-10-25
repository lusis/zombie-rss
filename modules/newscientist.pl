# www.NewScientist.com/news module
#$Id: newscientist.pl,v 1.1 2003/01/03 17:59:16 psionic Exp $

use strict;
use HTML::TreeBuilder;

sub newscientist_parse_data {
   my ($mysql,$myarr,$data) = @_;
   my @entries;
   my @temp;
   my $tree;
   my $base = "http://www.newscientist.com";

   $data = join("XXXXX",split("\n",$data));
   $data =~ s/^.*The World\'s//;
   $data =~ s'<(/?)(tr|img|b|p)(.*?)>''gi;
   $data = join("\n",split("XXXXX",$data));

   $tree = new HTML::TreeBuilder();
   $tree->implicit_tags(0); #We don't need tags that aren't there.
   $tree->parse($data);
   $tree->eof();

   #Grab the first table tag, it's our news.
   my $branch = $tree->look_down('_tag','table'); 

   my $x = -2;
   my $type;
   my ($title, $link, $desc);
   foreach my $leaf ($branch->content_list()) {
      $x++;
      next if ($leaf->{class} =~ m/^space/);
      $type = $x % 4;
      if ($type == 0) {
	 $title = $leaf->{_content}[0]->{_content}[0];
	 $link = $leaf->{_content}[0]->{href};
      } elsif ($type == 1) {
	 $desc = $leaf->{_content}[0];
	 if (length($link) > 0) {
	    #We have a valid entry, push it into @entries
	    $link = $base . $link;
	    push(@entries, 
		 { 'link' => $link, 'title' => $title, 'desc' => $desc });
	 }
      }
   }

   return @entries;
}
1;
