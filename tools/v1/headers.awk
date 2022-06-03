$0 ~ /^[a-zA-Z]/ { flag=1; print "<b>" $0 "</b>";};
$0 ~ /^   [a-zA-Z]/ { flag=1; sub("   ",""); print "   " "<b>" $0 "</b>"};
$0 ~ /^[1m[a-zA-Z]/ { flag=1; sub("\\[1m", ""); sub("\\[0m",""); print "<b>" $0 "</b>"};
$0 ~ /^   [1m[a-zA-Z]/ { flag=1; sub("   \\[1m", ""); sub("\\[0m",""); print "   " "<b>" $0 "</b>"};
$0 !~ /^[a-zA-Z]/ && $0 !~ /^   [a-zA-Z]/ { if (flag == 0) {print;} };
{flag=0;}
