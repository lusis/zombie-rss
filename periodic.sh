#!/bin/csh -f
#This should be crontabbed. It'll clean up the database and update new articles
#$Id: periodic.sh,v 1.6 2003/01/03 05:32:50 psionic Exp $

#Change this to the location of rssnews
set DIR="/u9/psionic/public_html/news"

#Don't change this :)
cd $DIR
./cleanup.pl
./upcron.pl

