s|</a>|</a>|g
/       <ahref=/ { s///g }
s/ahref/a href/g
#$0 ~ /       <a href=/ { gsub("",""); print; }
#$0 !~ /       <a href=/ { print; }
#{ gsub("</a>","</a>"); print;}
