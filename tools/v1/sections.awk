$1 ~ /START[INFOSOURCETERMINAL]+SECTION./ {s=$0;e="ENDSECTION."};
$1 ~ /ENDSECTION./ {s="";e=""};
$1 !~ /START[INFOSOURCETERMINAL]+SECTION./ && $1 !~ /ENDSECTION./ { print s $0 e; }
