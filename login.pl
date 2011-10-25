#!/usr/bin/perl
#$Id: login.pl,v 1.5 2002/08/14 19:50:40 psionic Exp $

my $errmsg;

use Digest::MD5 qw(md5_base64);

sub doInit { 
   my ($query,$mysql,$userdata) = @_;
   if ($query->param('DOLOGIN')) {
      #$mysql is the mysql session 
      my $result = $mysql->prepare("SELECT * FROM rss_users WHERE user=\"".$query->param('userid')."\"");
      $result->execute();
      if ($result->rows != 1) {
         $errmsg = "Invalid username";
	 $userdata->{'user'} = "";

	 print $query->header();
	 return 0;
      }
      local $data = $result->fetchrow_hashref();
      if ($data->{'passwd'} eq md5_base64($query->param('password'))) {
	 my $session_id = md5_base64($data->{'user'}.$data->{'email'});
	 $mysql->do("DELETE FROM rss_sessions WHERE user=\"".$data->{'user'}."\"");
	 my $result = $mysql->prepare("INSERT INTO rss_sessions (user,session_id) VALUES (\"".$data->{'user'}."\",\"".$session_id."\")");
	 $result->execute();
	 $cookie = $query->cookie(-name=>'session_id',
				  -value=>$session_id,
				  -expires=>'+1y');
         print $query->header(-cookie=>$cookie);
	 $errmsg = "Logged in successfully :)";
	 $userdata->{'user'} = $data->{'user'};
      }
      else {
         $errmsg = "Invalid password - ".$data->{'passwd'}." vs ".md5_base64($query->param('password'));
	 $userdata->{'user'} = "";
	 print $query->header();
      }
   }
   else {
      $userdata->{'user'} = "";
      print $query->header();
   }
}

sub printContent {
   #HTML for the login, w00t.
   print "<h3>".$errmsg."</h3>";
   print '
	  <form method="post" action="index.pl">
	  <table border="0">
	  <tr><td>Login: </td><td><input type="text" size="10" class="large" name="userid"></td></tr>
	  <tr><td>Password</td><td><input type="password" size="10" class="large" name="password"></td></tr>
	  <tr><td colspan="2" align="right"><input type="submit" value="Login" class="large"></td></tr>
	  </table>
	  <input type="hidden" name="DOLOGIN" value="1">
	  <input type="hidden" name="page" value="login.pl">
	  </form>

	  <p>
	  Forget your password? Sucks to be you.
	  ';
}
1;
