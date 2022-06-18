SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )
TOOLS_DIR=$(echo "$SCRIPT_DIR" | sed 's/v2//' )
TOOLSVERSION="toolsV2"
source "$TOOLS_DIR"/v1/toolsV1.sh
export TOOLSVERSION="toolsV2"

eval "$(echo "publishV1 () {"; declare -f publish | tail -n +2 )"

publish () {
# https://stackoverflow.com/questions/1203583/how-do-i-rename-a-bash-function
	local _blog_post_path=$1
	if [ -z "$_blog_post_path" ]
	then
		echo "MISSIN .blog FILE"
		return
	fi
	local _project_directory_name=$2
	if [ -z "$_project_directory_name" ]
	then
		echo "MISSING PUBLISH PROJECT"
		return
	fi
	#local _temp_blog_post_path=/tmp/$(echo $_blog_post_path | sed 's|wip/||')
	#cp $PROJECT_FOLDER/$_blog_post_path $_temp_blog_post_path
	#__v2_to_v1 $_temp_blog_post_path
	local _v1_blog_post_path="$PROJECT_FOLDER"/"$_blog_post_path".v1
	cp $PROJECT_FOLDER/$_blog_post_path $_v1_blog_post_path
	__v2_to_v1 $_v1_blog_post_path
	publishV1 $(echo $_v1_blog_post_path | awk -F'yetAnotherWebdev.blog/' '{ print $2 }') $_project_directory_name
	rm $_v1_blog_post_path
}
__persist_blog_file () {
	local _blog_post_path=$PROJECT_FOLDER/$1
	local _new_blog_post_path=$2
	mv $(echo $_blog_post_path | sed 's|\.blog\.v1|\.blog|') "$_publish_destination/$_new_file_name.blog"
}
__replace_placeholders () {
	local _blog_post_path=$1
	local _v1_blog_post_path=$(echo $_blog_post_path | sed 's|\.blog\.v1|\.blog|')
	local _project_title=$2
	if [ "$OS" = "Linux" ]; then
		sed -i "4s/.*/\&/; 4s/.*/$_project_title/" $_blog_post_path
		sed -i "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_blog_post_path
		sed -i "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_blog_post_path
		sed -i "4s/.*/\&/; 4s/.*/$_project_title/" $_v1_blog_post_path
		sed -i "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_v1_blog_post_path
		sed -i "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_v1_blog_post_path
	else
		sed -i '' "4s/.*/\&/; 4s/.*/$_project_title/" $_blog_post_path
		sed -i '' "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_blog_post_path
		sed -i '' "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_blog_post_path
		sed -i '' "4s/.*/\&/; 4s/.*/$_project_title/" $_v1_blog_post_path
		sed -i '' "s/PUBLISH_DATE/$(date +%Y-%m-%d)/" $_v1_blog_post_path
		sed -i '' "s/TOOLSVERSIONPLACEHOLDER/$TOOLSVERSION/" $_v1_blog_post_path
	fi
}
__v2_to_v1 () {
	local _blog_post_path=$1
	__replace_end_highlight $_blog_post_path
	__replace_start_terminal_highlight $_blog_post_path
	__replace_page_layout $_blog_post_path
	__replace_project_title $_blog_post_path
	__replace_post_title $_blog_post_path
	__replace_post_description $_blog_post_path
	__replace_sources $_blog_post_path
	__replace_source_title $_blog_post_path
	__replace_source_link $_blog_post_path
	__replace_header_body_separator $_blog_post_path
	__replace_header_primary $_blog_post_path
	__replace_header_secondary $_blog_post_path
	__replace_list_item_ordered $_blog_post_path
	__replace_link $_blog_post_path
}

__replace_page_layout () {
# https://stackoverflow.com/questions/1251999/how-can-i-replace-each-newline-n-with-a-space-using-sed?rq=1

	local _blog_post_path=$1
	local _line_number=$(grep -n ".PAGE_LAYOUT" $_blog_post_path| awk -F':' '{ print $1 }')
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/.PAGE_LAYOUT\n/.TH /g' $_blog_post_path
	sed -i '' -e ""$_line_number"s/^//p; "$_line_number"s/^.*/.nh /" $_blog_post_path
}

__replace_project_title () {
	local _blog_post_path=$1
	#local _line_number=$(grep -n ".PROJECT_TITLE" $_blog_post_path| awk -F':' '{ print $1 }')
	#sed -i '' -E "$((_line_number + 1))"'s/^(.*)/\"\1\"/' $_blog_post_path
	#sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/.PROJECT_TITLE\n/.SH /g' $_blog_post_path
	sed -i '' 's/.PROJECT_TITLE/.SH \"PROJECT\"/' $_blog_post_path
}
__replace_post_title () {
	local _blog_post_path=$1
	sed -i '' 's/.POST_TITLE/.SH \"POST\"/' $_blog_post_path
}
__replace_post_description () {
	local _blog_post_path=$1
	sed -i '' 's/.POST_DESCRIPTION/.SH \"DESCRIPTION\"/' $_blog_post_path
}
__replace_sources () {
	local _blog_post_path=$1
	sed -i '' 's/.SOURCES/.SH \"Sources\"/' $_blog_post_path
}
__replace_source_title () {
	local _blog_post_path=$1
	local _line_numbers_string=$(grep -n ".SOURCE_TITLE" $_blog_post_path| awk -v FS=':' -v ORS=',' '{ print $1 }' | sed 's/,$//' | tr ',' ' ')
	declare -a _line_numbers=($(echo $_line_numbers_string))
	for _current in $_line_numbers
	do
		sed -i '' -E "$(($_current + 1))"'s/^(.*)/\"\1\"/' $_blog_post_path
	done
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/.SOURCE_TITLE\n/.SS /g' $_blog_post_path
}
__replace_source_link () {
	local _blog_post_path=$1
	local _line_numbers_string=$(grep -n ".SOURCE_LINK" $_blog_post_path| awk -v FS=':' -v ORS=',' '{ print $1 }' | sed 's/,$//' | tr ',' ' ')
	declare -a _line_numbers=($(echo $_line_numbers_string))
	for _current in $_line_numbers
	do
		sed -i '' -E "$(($_current + 1))"'s|^(.*)|L_/;I_/;N_/;K_/;\1L_/;I_/;N_/;K_/;\1L_/;I_/;N_/;K_/;|' $_blog_post_path
	done
	sed -i '' 's/.SOURCE_LINK/.PP /g' $_blog_post_path
}
__replace_header_body_separator () {
	local _blog_post_path=$1
	sed -i '' 's/.HEADER_BODY_SEPARATOR/.sp 3/' $_blog_post_path
}
__replace_header_primary () {
	local _blog_post_path=$1
	sed -i '' 's/.HEADER_PRIMARY/.SH/' $_blog_post_path
}
__replace_header_secondary () {
	local _blog_post_path=$1
	sed -i '' 's/.HEADER_SECONDARY/.SS/' $_blog_post_path
	
}
__replace_list_item_ordered () {
	local _blog_post_path=$1
	#sed -i '' 's/.LIST_ITEM_ORDERED/.TP\n.B 1./' $_blog_post_path
	local _line_numbers_string=$(grep -n ".LIST_ITEM_ORDERED" $_blog_post_path| awk -v FS=':' -v ORS=',' '{ print $1 }' | sed 's/,$//' | tr ',' ' ')
	declare -a _line_numbers=($(echo $_line_numbers_string))
	local _next_index=1
	for _current in $_line_numbers
	do
		sed -i '' -E "$_current"'s|^(.*)|.TP .B '"$_next_index"'.|' $_blog_post_path
		sed "$(($_current + 2))"'!d' $_blog_post_path | grep ".LIST_ITEM_ORDERED" > /dev/null
		if [ "$?" = "0" ]; then
			_next_index=$(($_next_index + 1))
		else
			_next_index=1
		fi
	done
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's|.TP .B|.TP\n.B|g' $_blog_post_path
}
__replace_link () {
	local _blog_post_path=$1
	local _line_numbers_string=$(grep -n ".LINK" $_blog_post_path| awk -v FS=':' -v ORS=',' '{ print $1 }' | sed 's/,$//' | tr ',' ' ')
	declare -a _line_numbers=($(echo $_line_numbers_string))
	for _current in $_line_numbers
	do
		sed -i '' -E "$(($_current + 1))"'s|^(.*)|L_/;I_/;N_/;K_/;\1L_/;I_/;N_/;K_/;\1L_/;I_/;N_/;K_/;?|' $_blog_post_path
	done
	sed -i '' 's|.LINK|.PP|g' $_blog_post_path
}
__replace_end_highlight () {
	local _blog_post_path=$1
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's|\n.END_HIGHLIGHT| E_/;N_/;D_/;H_/;I_/;G_/;H_/;L_/;I_/;G_/;H_/;T_/;|g' $_blog_post_path
}
__replace_start_terminal_highlight () {
	local _blog_post_path=$1
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's|\n.START_TERMINAL_HIGHLIGHT\n| S_/;T_/;A_/;R_/;T_/;T_/;E_/;R_/;M_/;I_/;N_/;A_/;L_/;H_/;I_/;G_/;H_/;L_/;I_/;G_/;H_/;T_/;|g' $_blog_post_path
}