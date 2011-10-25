#!/usr/bin/perl
#$Id: signup.pl,v 1.4 2002/08/12 05:05:22 psionic Exp $

my $errmsg;

use Digest::MD5 qw(md5_base64);

sub doInit {
   my ($query,$mysql) = @_;
   if ($query->param('DOSIGNUP')) {
      #$mysql is the session id

      #Make sure the the baboon entered all the data.
      if (($query->param('user') eq "") || ($query->param('email') eq "") ||
	 ($query->param('password') eq "") || ($query->param('confirm') eq "")) {
         $errmsg = $errmsg. "<h3>You didn't fill in all the fields.</h3>";
	 return 0;
      }

      my $validate = $mysql->prepare("SELECT user FROM rss_users WHERE user=\"".$query->param('user')."\"");
      $validate->execute();
      if ($validate->rows > 0) {
         $errmsg = $errmsg. "<h3> This user already exists, pick another login </h3>";
	 return 0;
      }
      
      if ($query->param('password') eq $query->param('confirm')) {
         my $result = $mysql->prepare('INSERT INTO rss_users (user,passwd,email,numcols) VALUES ("'.$query->param('user').'","'.md5_base64($query->param('password')).'","'.$query->param('email').'",3)');
         $result->execute();
         $errmsg = $errmsg. "<h3> Signup Successful! :) </h3>";
      }
      else {
         #Passwords do not match.
         $errmsg = "<h3>Your passwords did not match</h3>Might I suggest typing lessons?";
      }
   }
   #If DOSIGNUP is not set, then we aren't signing up just yet.
   print $query->header();
}

sub printContent {
   my ($query) = @_;
   if ($query->param('DOSIGNUP')) {
      #Here we can tell you what happened (success/fail/etc). WEEEEEEEEE!
      print $errmsg;
      return 0;
   }
   print '
          <form method="post" method="index.pl">
          <table border="0">
          <tr>
          <td> Username: </td>
          <td> <input class="large" type="text" name="user"> </td>
          </tr>

          <tr>
          <td> Email Address: </td>
          <td> <input class="large" type="text" name="email"> </td>
          </tr>

          <tr>
          <td> Password: </td>
          <td> <input class="large" type="password" name="password"> </td>
          </tr>
          
          <tr>
          <td> Confirm Password: </td>
          <td> <input class="large" type="password" name="confirm"> </td>
          </tr>

          <tr>
          <td colspan="2"><b>There are more options available to you once you login. </b> </td>
          </tr>

          <tr>
          <td colspan="2" align="right">
          <input class="large" type="submit" value="Sign up!">
          </td>
          </tr>

          </table>
          <input type="hidden" name="DOSIGNUP" value="1">
          <input type="hidden" name="page" value="signup.pl">
          </form>
          ';
}
1;
