#!/usr/bin/perl
#$Id: topmenu.pl,v 1.8 2004/07/04 08:38:59 psionic Exp $

sub topmenu_print {
   my ($query,$userdata) = @_;
   if ($userdata->{'user'}) {
      print '
	     <a href="?page=front.pl">Front</a>
	     &nbsp;|&nbsp;
	     <a href="?page=mynews.pl">My News</a> 
	     &nbsp;|&nbsp;
	     <a href="?page=markall.pl&time=>'.time().'">Mark All</a>
	     &nbsp;|&nbsp;
	     <a href="?page=config.pl">Settings</a>
	     &nbsp;|&nbsp;
	     <a href="?page=about.pl">About</a>
	     &nbsp;|&nbsp;
	     <a href="?page=search.pl">Search</a>
	     ';
      if ($userdata->{'CONFIG'}->{'portal_type'} eq 'default') {
	 print '
		&nbsp;|&nbsp;
		<a href="?page=logout.pl">Logout</a>
		&nbsp;
		';
      }
   }
   else {
      if ($userdata->{'CONFIG'}->{'portal_type'} eq 'default') {
	 print '
	        <form method="post" action="index.pl">
	        <table border="0" cellpadding="1" cellspacing="0">
	        <tr>
		<td align="right">
	        <small style="font-size=10pt">
	        Login: <input type="text" name="userid" size="8" class="small">
	        </small>
		</td>
		<td align="right">
		<small style="font-size=10pt">
		Password:
		<input type="password" name="password" size="8" class="small">
		</small>
		</td>
		<td align="right">
		<input type="submit" value="Login" class="small">
		</td>
		</tr>
		<tr>
		<td align="left" colspan="3">
		<small style="font-size=10pt">
		Not a member? <a href="?page=signup.pl">Click to Sign Up!</a>
		</small>
		</td></tr>
		</table>
		<input type="hidden" name="DOLOGIN" value="1">
		<input type="hidden" name="page" value="login.pl">
		</form>
		';
      }
      elsif ($userdata->{'CONFIG'}->{'portal_type'} eq 'htaccess') {
         print '
		You don\'t have an account. It takes a whole 3 seconds to 
		create one, so why not?
		<a href="?page=createaccount.pl">Create One!</a>
		';
      }
   }
}
1;
