#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Download remote assets locally and subsitute remote paths with local ones
#
#
#
pa_ynh_download_remote_assets() {
    # ============ Argument parsing =============
    local -A args_array=([u]=url_format= [f]=cmd_filepath= [k]=cmd_path_wildcard= [e]=event= [s]=source_file=)
    local url_format
    local cmd_filepath
    local cmd_path_wildcard
    local event
    local source_file
    ynh_handle_getopts_args "$@"
    # ===========================================
	grep -o $url_format $source_file | sort -u | while read -r url ; do
		filepath="src/libs/$(echo $url | $cmd_filepath)"
		# Download remote assets 
		if [ ! -f "$install_dir/$filepath" ]; then
			if [ $event = 'upgrade' ] && [[ -n $cmd_path_wildcard ]] ; then 
				# Remove asset's old version
				find "$install_dir/src/libs" -name $cmd_path_wildcard -type d -exec ynh_safe_rm {} +          
			fi
			mkdir -p "$(dirname $install_dir/$filepath)" # make sure directory exists
			curl -L -s -o "$install_dir/$filepath" $url
		fi
		# Replace remote assets' paths with local paths 
		ynh_replace --match="$url" --replace="$filepath" --file="$source_file"
	done
}
