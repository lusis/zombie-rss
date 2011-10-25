# Fark.com HTML parser
#$Id: fark.pl,v 1.4 2004/07/04 08:39:11 psionic Exp $

use strict;
use HTML::TreeBuilder;

sub fark_parse_data {
   my ($mysql,$myarr,$data) = @_;
   my @entries;
   my $tree;

   #my $source;

   $data =~ s/(\x0a)|(\x09)//g;
   $tree = new HTML::TreeBuilder();
   $tree->parse($data);

   my @links = $tree->look_down('_tag','link');
   my @ids = $tree->look_down('_tag','id');
   my @comments = $tree->look_down('_tag','comments');
   my @desc =  $tree->look_down('_tag','description');

   my $a = 1;
   my $b = 0;
   foreach (@desc) {
      my ($link) = $links[$a]->content_list();
      my $title = $_->{_content}[0];
      $title .= '</a> <a href="http://forums.fark.com/cgi/fark/comments.pl?IDLink='.$ids[$b]->{_content}[0] . '"><small><i>[' . $comments[$b]->{_content}[0] . " comments]</i></small></a>";

      print "Fark: $title\n";
      push(@entries, { 'link' => $link, title => $title });
      $a += 2;
      $b++;
   }

   $tree->delete();

   return @entries;
}
1;
