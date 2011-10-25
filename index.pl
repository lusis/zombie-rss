#!/usr/bin/perl
#$Id: index.pl,v 1.16 2004/07/04 08:38:58 psionic Exp $

use strict;
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);

$SIG{__WARN__} = sub { print STDOUT '<b>Perl warned:</b> ' . join(" ",@_) . "<br>\n"; };

#Read the config file and set all the pretty variables
undef $/;
my ($sql_type,$sql_server,$sql_dbname,$sql_user,$sql_pass,
    $portal_useauth,$portal_type,$portal_basedir);
open(CONFIG,"./rssnews.conf");
eval(<CONFIG>);
close(CONFIG);

#Yay for userdata!!! All your data are belong to %userdata - hash containing
# information on the person currently browsing the website.
my $userdata;

#Useful CGI object, we'll use it to get the parameters passed.
my $query = new CGI;

#$load is the page to be loaded into the content area. It also is executed
# for CHECKUP initialization stuff, such as signing up and logging in.
my $load = $query->param('page');

#DBI Object.. thing.
my $mysql;
$mysql= DBI->connect("DBI:$sql_type:database=$sql_dbname;host=$sql_server",
                      $sql_user,$sql_pass) or die "Connection Failed to server $sql_server as '$sql_user'";
my $MAINPAGE;
if ($load eq "") { 
	$load = "front.pl"; 
	$MAINPAGE = 1;
}

#Make sure the page=??? value exists, if not default to about.pl
if (-f "./$load") { require "./$load"; }
else { $load = "about.pl"; require "./$load"; }

#call the doInit() sub from the loaded file.
doInit($query,$mysql,$userdata);

#I no longer like the left menu...
#require "./leftmenu.pl";
require "./topmenu.pl";

#Handle the different authorization types (default, cms, htaccess...)
my $result;
if ($portal_type eq 'default') {
   my ($session_id);
   $session_id = $query->cookie(-name=>'session_id');
   $result = $mysql->prepare("SELECT * FROM rss_sessions WHERE session_id=\"".$session_id."\"");
   $result->execute();
   my $myarr = $result->fetchrow_hashref();
   $result->finish();
   $result = $mysql->prepare("SELECT * FROM rss_users WHERE user=\"".$myarr->{'user'}."\"");
}
else {
   #Assume htaccess for now...
   $result = $mysql->prepare("SELECT * FROM rss_users WHERE user='".$ENV{'REMOTE_USER'}."'");
}

#We now should know what user's data we want to grab.
$result->execute();
$userdata = $result->fetchrow_hashref();
$result->finish();

#Link the enviroment vars to the userdata hash for easy access.
$userdata->{'ENV'} = \%ENV;

#Throw in the config stuff to userdata just for fun.
$userdata->{'CONFIG'} = {
   sql_type => $sql_type, sql_server => $sql_server, 
   sql_dbname => $sql_dbname, sql_user => $sql_user, sql_bass => $sql_pass,
   portal_useauth => $portal_useauth, portal_type => $portal_type,
   portal_basedir => $portal_basedir
};

#Layout of the site: Hardcoded design, not content.
print '
      <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
      <html>
      <head>
      ';

#If accessing the main page for the 'first time' (No page=??? value)
#  and if this person is already logged in, go ahead and load mynews.pl instead
#  of the front page.
if ($MAINPAGE == 1) {
   if ($userdata->{'user'}) {
		undef &doInit;
		undef &printContent;
		require "./mynews.pl";
	}
}

#If it's a successful login, bounce to mynews
if ( ($load eq "login.pl") && ($query->param('DOLOGIN') == 1) ) { 
   print '<meta HTTP-EQUIV="refresh" content="0;url=index.pl?page=mynews.pl">'; 
}

#If it's a logout, bounce to front.
if ($load eq "logout.pl") { 
   print '<meta HTTP-EQUIV="refresh" content="0;url=index.pl?page=frontabout.pl">'; 
}

#If it's config.pl, and we've already submitted...
if (($load eq "config.pl") && ($query->param('DOCONFIG'))) {
   print '<meta http-equiv="refresh" content="0;url=index.pl?page=mynews.pl">';
}
#If it's a mark-all thing.
if ($load eq "markall.pl") {
   print '<meta http-equiv="refresh" content="0;url=index.pl?page=mynews.pl">';
}

#If it's a view.pl, let's go ahead and follow that link.
if ($load eq "view.pl") {
   my ($url);
   my ($res) = $mysql->prepare("SELECT * FROM rss_newslist WHERE id=\"".$query->param('itemid')."\"");
   $res->execute();
   my $href = $res->fetchrow_hashref();
   $url = $href->{'link'};
   $url =~ s";"&";
   print '<meta HTTP-EQUIV="refresh" content="0;url='.$url.'">';
}

print '
      <title> RSSNews - News from all over the web </title>
      <style type="text/css">
      input.large {
         border-color: #006699;
         border-width: 1px;
         color: #000000;
         background-color: #C4D6E4;
      }
      input.small {
         border-color: #006699;
         border-width: 1px;
         color: #000000;
         font-size: 10;
         background-color: #CDDDEB;
      }
      a {
         color: #333366;
         text-decoration: none;
      }
    a.small {
         font-size: 10;
	 text-decoration: none;
	 color: #333366;
    }
      </style>
      <script>
      function highlight(obj) {
         obj.style.backgroundColor="#C4D6E4";
         obj.style.cursor="hand";
      }
      function revert(obj,id) {
	 if (eval("document.configForm."+id+".checked")) {
            obj.style.backgroundColor="#D1F5E4";
	 }
	 else {
            obj.style.backgroundColor="#E6EFF5";
	 }
      }
      </script>
      </head>
      <body bgcolor="#E8EFF5" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">
      <table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#E8EFF5">
      <tr>
      <!-- Top Header Content -->
         <table border="0" cellspacing="0" cellpadding="0" width="100%" background="images/layer_top_noleft.gif">
         <tr>
         <td valign="top">
            <img src="images/frontlogo.gif">
         </td>
         <td valign="top" align="right" background="images/layer_top_noleft.gif">
         <!-- Begin TopMenu -->
            <table border="0" cellpadding="0" cellspacing="0" background="images/layer_top_noleft.gif"> 
            <tr>
            <td valign="top" wrap>
               <!-- TopMenu Login/Info Console -->
      ';
#Include the TopMenu login thing
topmenu_print($query,$userdata);
print '
               <!-- End Topside Login Area-->
            </td>
            </tr>
            </table>
         <!-- End TopMenu -->
         </td>
         </tr>
         </table>
      <!-- End Top Header Content -->
      </td>
      </tr>
      <tr>
      <td>
         <table border="0" cellpadding="0" cellspacing="0" width="100%">
         <tr>
         <!-- Begin Left Menu -->
	 <!-- Left menu removed, August 06, 2002
         <td valign="top" background="images/leftside_fill.gif">
			
         </td>
	 -->
         <!-- End Left Menu -->
         <td><img src="images/spacer.gif" width="15" height="1"></td>
         <td valign="top" width="100%">
         <!-- Begin Content Area -->
       ';

#Make sure the auth is ok? (htacces primarily)
if ($portal_type eq 'htaccess') {
   unless (defined $ENV{'REMOTE_USER'}) {
      print '
	     <h3>Fatal Error:</h3>
	     With htaccess auth selected, I am unable to detect a user logged
	     in via this method.
	    ';
      exit;
   }
}

#include main content
printContent($query,$mysql,$userdata);

print '
         <!-- End Content Area -->
         </td>
         <td><img src="images/spacer.gif" width="15"></td>
         </tr>
         <tr><td colspan="3"><img src="images/spacer.gif" height="15"></td></tr>
         <!--tr><td bgcolor="#006699"><img src="images/spacer.gif"></td></tr-->
         </table>
      <!-- End Main Area-->
      </td>
      </tr>
      </table>
      </body>
      </html>
      ';

$mysql->disconnect();
