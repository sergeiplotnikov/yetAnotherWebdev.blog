BEGIN { FS="STARTLINK" };
$0 ~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print "       " "<a href=\"" $2 "\">" $2 "</a>"};
$0 !~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print; }
