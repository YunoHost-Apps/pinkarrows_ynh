#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Download remote assets locally and subsitute remote paths with local ones
#   url_format:         (string) regex that matches URL to look at in the $source_file
#   cmd_filepath:       (string) bash command that removes "https://domain.tld/" from the the URL to form the filepath   
#   cmd_path_wildcard:  (string) bash command that replaces the end of the filepath with a wildcard to match recursively the library's directory 
#   event:              (string) 'update' or 'install' to get the execution's context 
#   source_file:        (string) path to the file to read & modify
####
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
    echo "url: $url_format"
    echo "fp: $cmd_filepath"
    echo "pw: $cmd_path_wildcard"
    echo "ev: $event"
    echo "source_file: $source_file"
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
