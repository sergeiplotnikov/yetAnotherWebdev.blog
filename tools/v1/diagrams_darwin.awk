$1 ~ /START[INFO]+SECTION./ {x="\\\\"; print $0; };
$1 ~ /ENDSECTION./ {x="\\"; print $0; };
$1 !~ /START[INFO]+SECTION./ && $1 !~ /ENDSECTION./ { gsub("\\\\", x); print $0; }
