$0 ~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print "       " "<a href=\"" $1 "\">" $1 "</a>"};
$0 !~ /    STARTLINK[a-zA-Z0-9\.\/:-]*/ { print; }
