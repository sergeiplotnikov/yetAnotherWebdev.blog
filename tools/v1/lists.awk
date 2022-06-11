$0 ~ /^       [1m[1-9]/ { flag=1; sub("\\[1m",""); sub("\\[22m",""); print $0 }
$0 !~ /^       [1m[1-9]/ { if ( flag == 0) { print } }
flag=0;
