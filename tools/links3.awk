BEGIN { FS="LINK" };
{ if ($2 == "" ) {print $0 } else { split($2, arr, ""); printf("<ahref=\""); for(i=1; i<=length($2); i++) { printf("%s", arr[i])}; printf("\">" $3 "</a>\n"); }}
#{ if ($2 == "" ) {print $0 } else {print "<a href=\"" $2 "\">" $3 "</a>" }}
#$0 ~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print "       " "<a href=\"" $1 "\">" $1 "</a>"};
#$0 !~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print; }
