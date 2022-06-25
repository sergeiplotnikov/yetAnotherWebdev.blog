PROJECT_FOLDER="$(pwd | awk -F'yetAnotherWebdev.blog' '{ print $1 }')yetAnotherWebdev.blog"
OS=$(uname)
TOOLSVERSION="toolsV1"
if [ "$OS" = "Darwin" ]; then
	ERRORS=0
	command -v gdate > /dev/null
	if [ "$?" = "1" ]; then
		echo "!!! You dont have 'gdate' installed !!!"
		echo "run 'brew install coreutils'"
		ERRORS=$(($ERRORS + 1))
	fi
	man groff | col -xb | grep -- "-K arg" > /dev/null
	if [ "$?" = "1" ]; then
		echo "!!! You have an older version on groff that does not suppour -K flag !!!"
		echo "run 'brew install groff'"
		ERRORS=$(($ERRORS + 1))
	fi
	if [ ! $ERRORS -eq 0 ]; then
		echo "$ERRORS"
		return
	fi
fi

makePost () {
	if [ -z "$1" ]; then
		echo "ERROR: Missing filename"
		return
	fi
	if [ -f "$PROJECT_FOLDER/wip/$1.blog" ]; then
		echo "ERROR: Filename already used in 'wip' directory"
		return
	fi
	echo ".TH \"yet_another_webdev\" \"blog\" \"\" \"TOOLSVERSIONPLACEHOLDER\" \"PUBLISH_DATE\"" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo ".nh" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo ".SH \"PROJECT\"" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo "PROJECTPLACEHOLDER" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo ".SH \"POST\"" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo "POSTPLACEHOLDER" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo ".SH \"DESCRIPTION\"" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo "DESCRIPTIONPLACEHOLDER" >> "$PROJECT_FOLDER/wip/$1.blog"
	echo ".sp 3" >> "$PROJECT_FOLDER/wip/$1.blog"
}

makeProject () {
	local _project_directory="$1"
	if [ -z "$_project_directory" ]; then
		echo "ERROR: Missing project dirctory"
		return
	fi
	local _project_title="$2"
	if [ -z "$_project_title" ]; then
		echo "ERROR: Missing project title"
		return
	fi
	local _project_description="$3"
	if [ -z "$_project_description" ]; then
		echo "ERROR: Missing project description"
		return
	fi
	mkdir -p "$PROJECT_FOLDER/content/$_project_directory"
	local _new_project_index_file="$PROJECT_FOLDER/content/$_project_directory/index.blog"
	touch $_new_project_index_file
	echo ".TH \"yet_another_webdev\" \"blog\" \"\" \"$TOOLSVERSION\" \"\"" >> $_new_project_index_file
	echo ".nh" >> $_new_project_index_file
	echo ".SH \"Project title:\"" >> $_new_project_index_file
	echo "$_project_title" >> $_new_project_index_file
	echo ".SH \"Description:\"" >> $_new_project_index_file
	echo "$_project_description" >> $_new_project_index_file
	echo ".SH \"Posts:\"" >> $_new_project_index_file
	echo ".SS \"\"" >> $_new_project_index_file
	echo "" >> $_new_project_index_file
	if [ ! -f "$PROJECT_FOLDER/index.blog" ]; then
		__create_homepage
	fi
	__add_project_to_homepage $_project_directory "$_project_title" "$_project_description"
	__make_html $_new_project_index_file "$PROJECT_FOLDER/content/$_project_directory/index"
	__rebuild_homepage
}

publish () {
	local _blog_post_path=$1
	if [ -z "$_blog_post_path" ]; then
		echo "MISSIN .blog FILE"
		return
	fi
	local _project_directory_name=$2
	if [ -z "$_project_directory_name" ]; then
		echo "MISSING PUBLISH PROJECT"
		return
	fi
	local _publish_destination="$PROJECT_FOLDER/content/$_project_directory_name"
	if [ ! -f "$_publish_destination/index.blog" ]; then
		echo "PROJECT NOT FOUND"
		return
	fi
	local _postid=$(date +%y%m%d%H%M%S%N)
	if [ "$OS" = "Darwin" ]; then
		_postid=$(gdate +%y%m%d%H%M%S%N)
	fi
	local _filename=$(echo $_blog_post_path | awk -F'.blog' '{ print $1 }' | awk -F'wip/' '{ print $2 }')
	local _new_file_name="${_postid}_${_filename}"
    local _title=$(awk 'NR==6' "$_blog_post_path")
    local _project_title=$(awk 'NR==4' "$PROJECT_FOLDER/content/$_project_directory_name/index.blog")
    local _description=$(sed '8!d' "$_blog_post_path")
    __add_to_project_index $_publish_destination $_new_file_name "$_title" "$_description"
	__add_to_homepage "$_project_directory_name/$_new_file_name" "$_project_title - $_title" "$_description"
	__replace_placeholders $PROJECT_FOLDER/$_blog_post_path $_project_title
	__make_html $_blog_post_path $_publish_destination/$_new_file_name
	#__make_less $_blog_post_path $_publish_destination/$_new_file_name
	__persist_blog_file $_blog_post_path "$_publish_destination/$_new_file_name.blog"
	local _update_status_line_num=$(grep -n "./content/$_project_directory_name/index.html" $PROJECT_FOLDER/index.blog | awk -F':' '{ print $1 }')
	_update_status_line_num=$(($_update_status_line_num-2))
	local _posts_count="$(ls $PROJECT_FOLDER/content/$_project_directory_name | wc -l)"
	_posts_count=$((_posts_count-2))
	_posts_count=$((_posts_count/2))
	if [ "$OS" = "Linux" ]; then
		sed -i "$_update_status_line_num s/.*/.SS \"Last update: $(date +%Y-%m-%d) -- $_posts_count posts\"/" $PROJECT_FOLDER/index.blog
	else
		sed -i '' "$_update_status_line_num s/.*/\.SS \"Last update: $(date +%Y-%m-%d) -- $_posts_count posts\"/" $PROJECT_FOLDER/index.blog
	fi
	__rebuild_homepage
}

################################################################################
## functions below, starting with __ are 'private'
################################################################################

__replace_placeholders () {
	local _blog_post_path=$1
	local _project_title=$2
	if [ "$OS" = "Linux" ]; then
		sed -i "4s/.*/\&/; 4s/.*/$_project_title/" $_blog_post_path
		sed -i "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_blog_post_path
		sed -i "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_blog_post_path
	else
		sed -i '' "4s/.*/\&/; 4s/.*/$_project_title/" $_blog_post_path
		sed -i '' "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_blog_post_path
		sed -i '' "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_blog_post_path
	fi
}

__persist_blog_file () {
	local _blog_post_path=$1
	local _new_blog_post_path=$2
	mv $_blog_post_path "$_publish_destination/$_new_file_name.blog"
}

__set_escapes () {
	sed "s|_\/;|"`echo -e '\010'`"|g;" $1
}

__diagrams () {
	if [ "$OS" = "Linux" ]; then
		awk -f $PROJECT_FOLDER/tools/v1/diagrams_linux.awk
	else
		sed 's|\\|\\\\|g'
	fi
}

__groff () {
	groff -Kutf8 -Tutf8 -man -t -rLL=80n -rLT=80n $1
}

__sections () {
	awk -f $PROJECT_FOLDER/tools/v1/sections.awk
}

__highlights () {
	awk -f $PROJECT_FOLDER/tools/v1/highlights.awk
}

__colors () {
	sed -f $PROJECT_FOLDER/tools/v1/colors.sed
}

__less_than () {
	sed "s/</\&lt\;/g;"
}

__pre_tags () {
	sed -f $PROJECT_FOLDER/tools/v1/pre_tags.sed
}

__links () {
	awk -f $PROJECT_FOLDER/tools/v1/links3.awk
}

__links2 () {
	sed -f $PROJECT_FOLDER/tools/v1/links4.sed
}

__set_less_links () {
	awk -f $PROJECT_FOLDER/tools/v1/links5.awk $1
}

__headers () {
	awk -f $PROJECT_FOLDER/tools/v1/headers.awk
}

__lists () {
	awk -f $PROJECT_FOLDER/tools/v1/lists.awk
}

__remove_escapes () {
	col -bx
}

__complete_html () {
	awk -f $PROJECT_FOLDER/tools/v1/complete_html.awk
}

__make_less () {
	if [ -z "$2" ];
	then
		DESTINATION="$(pwd)/$1.less"
	else
		DESTINATION="$2.less"
	fi
	__set_less_links $1 | __set_escapes | __diagrams | __groff | __sections | __highlights | __colors > $DESTINATION
}

__make_html () {
	if [ -z "$2" ]; then
		DESTINATION="$(pwd)/$1.html"
	else
		DESTINATION="$2.html"
	fi
	__set_escapes $1 | __diagrams | __less_than | __links | __groff | __links2 | __pre_tags | __headers | __lists | __remove_escapes | __complete_html > $DESTINATION
}

__add_post_entry () {
	local _after_line=$1
	local _homepage_index_file="$2"
	local _project_entry="$3"
	local _project_index="$4"
	local _project_title="$5"
	local _project_description="$6"

	if [ "$OS" = "Linux" ]; then
		sed -i "$_after_line i .SS \"$_project_entry\"" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i "$_after_line i .PP" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i "$_after_line"' i L_/;I_/;N_/;K_/;./'"$_project_index.html"'L_/;I_/;N_/;K_/;'"$_project_title"'L_/;I_/;N_/;K_/;?"' $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i "$_after_line i .PP" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i "$_after_line i $_project_description" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i "$_after_line i .sp" $_homepage_index_file
	else
		sed -i '' -e ""$_after_line"s/^//p; "$_after_line"s/^.*/.SS \"$_project_entry\"/" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i '' -e ""$_after_line"s/^//p; "$_after_line"s/^.*/.PP/" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i '' -e $_after_line's/^//p; '$_after_line's/^.*/\&/g; '$_after_line's|^.*|L_\/;I_\/;N_\/;K_\/;./'$_project_index.html'L_\/;I_\/;N_\/;K_\/;'$_project_title'L_\/;I_\/;N_\/;K_\/;?|' $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i '' -e ""$_after_line"s/^//p; "$_after_line"s/^.*/.PP/" $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i '' -e $_after_line's/^//p; '$_after_line's/^.*/\&/g; '$_after_line's/^.*/'$_project_description'/' $_homepage_index_file
		_after_line=$(($_after_line+1))
		sed -i '' -e ""$_after_line"s/^//p; "$_after_line"s/^.*/.sp/" $_homepage_index_file
	fi
}

__create_homepage () {
	echo ".TH \"\" \"\" \"\" \"\" \"\"" >> "$PROJECT_FOLDER/index.blog"
	echo ".nh" >> "$PROJECT_FOLDER/index.blog"
	echo ".sp" >> "$PROJECT_FOLDER/index.blog"
	echo ".RS -20" >> "$PROJECT_FOLDER/index.blog"
	echo ".nf" >> "$PROJECT_FOLDER/index.blog"
	echo "S_/;T_/;A_/;R_/;T_/;I_/;N_/;F_/;O_/;S_/;E_/;C_/;T_/;I_/;O_/;N_/;." >> "$PROJECT_FOLDER/index.blog"
	echo "            _                         _   _               " >> "$PROJECT_FOLDER/index.blog"
	echo " _   _  ___| |_      __ _ _ __   ___ | |_| |__   ___ _ __ " >> "$PROJECT_FOLDER/index.blog"
	echo "| | | |/ _ \ __|    / _\` | '_ \ / _ \| __| '_ \ / _ \ '__|" >> "$PROJECT_FOLDER/index.blog"
	echo "| |_| |  __/ |_    | (_| | | | | (_) | |_| | | |  __/ |   " >> "$PROJECT_FOLDER/index.blog"
	echo " \__, |\___|\__|    \__,_|_| |_|\___/ \__|_| |_|\___|_|   " >> "$PROJECT_FOLDER/index.blog"
	echo " |___/                                                    " >> "$PROJECT_FOLDER/index.blog"
	echo "              _         _                 _     _             " >> "$PROJECT_FOLDER/index.blog"
	echo "__      _____| |__   __| | _____   __    | |__ | | ___   __ _ " >> "$PROJECT_FOLDER/index.blog"
	echo "\ \ /\ / / _ \ '_ \ / _\` |/ _ \ \ / /    | '_ \| |/ _ \ / _\` |" >> "$PROJECT_FOLDER/index.blog"
	echo " \ V  V /  __/ |_) | (_| |  __/\ V /     | |_) | | (_) | (_| |" >> "$PROJECT_FOLDER/index.blog"
	echo "  \_/\_/ \___|_.__/ \__,_|\___| \_/      |_.__/|_|\___/ \__, |" >> "$PROJECT_FOLDER/index.blog"
	echo "                                                        |___/ " >> "$PROJECT_FOLDER/index.blog"
	echo "E_/;N_/;D_/;S_/;E_/;C_/;T_/;I_/;O_/;N_/;." >> "$PROJECT_FOLDER/index.blog"
	echo ".SH \"Projects:\"" >> "$PROJECT_FOLDER/index.blog"
	echo ".SH \"Posts:\"" >> "$PROJECT_FOLDER/index.blog"
	echo "" >> "$PROJECT_FOLDER/index.blog"
}

__rebuild_homepage () {
	__make_html "$PROJECT_FOLDER/index.blog" "$PROJECT_FOLDER/index"
	if [ "$OS" = "Linux" ]; then
		sed -i '1s|../../|./|' "$PROJECT_FOLDER/index.html"
		sed -i '2s|.*|</pre>|' "$PROJECT_FOLDER/index.html"
		sed -i '3s|.*|<hr />|' "$PROJECT_FOLDER/index.html"
		sed -i '4s|.*|<pre>|' "$PROJECT_FOLDER/index.html"
		sed -i '5s;.*;              <a class="contact" href="https://github.com/sergeiplotnikov">Github</a> | <a class="contact" href="mailto:sergei.plotnikov128@gmail.com">sergei.plotnikov128@gmail.com</a> | <a class="contact" href="https://www.linkedin.com/in/sergei-plotnikov">LinkedIn</a>;' "$PROJECT_FOLDER/index.html"
		sed -i "6 i <hr />" "$PROJECT_FOLDER/index.html"
		sed -i "6 i </pre>" "$PROJECT_FOLDER/index.html"
		sed -i '8s|.*|</pre><a class="logo" target="_black" href="https://patorjk.com/software/taag">|' "$PROJECT_FOLDER/index.html"
		sed -i '21s|.*|</a></pre><pre>|' "$PROJECT_FOLDER/index.html"
		sed -i 's/()//' "$PROJECT_FOLDER/index.html"
	else
		sed -i '' '1s|../../|./|' "$PROJECT_FOLDER/index.html"
		sed -i '' '2s|.*|</pre>|' "$PROJECT_FOLDER/index.html"
		sed -i '' '3s|.*|<hr />|' "$PROJECT_FOLDER/index.html"
		sed -i '' '4s|.*|<pre>|' "$PROJECT_FOLDER/index.html"
		sed -i '' '5s;.*;              <a class="contact" href="https://github.com/sergeiplotnikov">Github</a> | <a class="contact" href="mailto:sergei.plotnikov128@gmail.com">sergei.plotnikov128@gmail.com</a> | <a class="contact" href="https://www.linkedin.com/in/sergei-plotnikov">LinkedIn</a>;' "$PROJECT_FOLDER/index.html"
		sed -i '' -e "5s/^//p; 5s|^.*|<hr />|" "$PROJECT_FOLDER/index.html"
		sed -i '' -e "5s/^//p; 5s|^.*|</pre>|" "$PROJECT_FOLDER/index.html"
		sed -i '' '8s|.*|</pre><a class="logo" target="_black" href="https://patorjk.com/software/taag">|' "$PROJECT_FOLDER/index.html"
		sed -i '' '21s|.*|</a></pre><pre>|' "$PROJECT_FOLDER/index.html"
		sed -i '' 's/()//' "$PROJECT_FOLDER/index.html"
	fi
}

__add_to_project_index () {
	local _project_path=$1
	local _project_index_path="$1/index.blog"
	if [ "$OS" = "Linux" ]; then
		__add_post_entry 8 $_project_index_path "$(date +%Y-%m-%d)" $2 "$3" "$4"
	else
		__add_post_entry 7 $_project_index_path "$(date +%Y-%m-%d)" $2 "$3" "$4"
	fi
	__make_html "$_project_index_path" "$_project_path/index"
}

__add_project_to_homepage () {
	local _project_directory="$1"
	local _project_title="$2"
	local _project_description="$3"
	if [ "$OS" = "Linux" ]; then
		__add_post_entry 21 "$PROJECT_FOLDER/index.blog" "Empty project -- 0 posts" "content/$_project_directory/index" "$_project_title" "$_project_description"
	else
		__add_post_entry 20 "$PROJECT_FOLDER/index.blog" "Empty project -- 0 posts" "content/$_project_directory/index" "$_project_title" "$_project_description"
	fi
}

__add_to_homepage () {
	local _new_post_path=$1
	local _post_title=$2
	local _post_description=$3
	local _line_number=$(grep -n "Posts:" "$PROJECT_FOLDER/index.blog" | awk -F':' '{ print $1 }')
	if [ "$OS" = "Linux" ]; then
		__add_post_entry $(($_line_number+1)) "$PROJECT_FOLDER/index.blog" "$(date +%Y-%m-%d)" "content/$_new_post_path" "$_post_title" "$_post_description"
	else
		__add_post_entry $_line_number "$PROJECT_FOLDER/index.blog" "$(date +%Y-%m-%d)" "content/$_new_post_path" "$_post_title" "$_post_description"
	fi
	__rebuild_homepage
}
