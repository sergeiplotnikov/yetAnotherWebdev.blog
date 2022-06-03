BEGIN { SX=""; S=""; E=""; }	
$0 ~ /^[a-zA-Z0-9 \.,]*ENDHIGHLIGHT/ { SX=S; S=""; E="";}
$0 ~ /STARTINFOHIGHLIGHT[a-zA-Z0-9 \.,]*$/ { E="ENDHIGHLIGHT"; S="STARTINFOHIGHLIGHT";  I=NR+1;}
$0 ~ /STARTSOURCEHIGHLIGHT[a-zA-Z0-9 \.,]*$/ { E="ENDHIGHLIGHT"; S="STARTSOURCEHIGHLIGHT";  I=NR+1;}
$0 ~ /STARTTERMINALHIGHLIGHT[a-zA-Z0-9 \.,]*$/ { E="ENDHIGHLIGHT"; S="STARTTERMINALHIGHLIGHT";  I=NR+1;}
{ if (SX != "") {printf("%s", SX)} else if (NR >= I){printf("%s", S)}; printf("%s%s\n", $0, E); SX="";}
