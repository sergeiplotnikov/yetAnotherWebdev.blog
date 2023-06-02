$1 ~ /START[INFO]+SECTION./ {x="\\\\\\\\";flag=1;};
$1 ~ /ENDSECTION./ {x="\\\\\\";flag=0;};
{if (flag == 1 && $1 !~ /\\\[/) { gsub("\\\\", x);}}	
#$1 !~ /START[INFO]+SECTION./ && $1 !~ /ENDSECTION./ { gsub("\\\\", x);}
{ print $0 }
