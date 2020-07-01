#!/bin/bash
#
#       Template file for scripts that are using choco-scripts framework
#

#
#   Path to the directory with this script
#
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

#
#   Path to the configuration file
#
CONFIGURATION_FILE_PATH=~/.choco-scripts.cfg

#
#   Verification of the choco scripts installation
#
if [ -f "$CONFIGURATION_FILE_PATH" ]
then 
    source $CONFIGURATION_FILE_PATH
else 
    printf "\033[31;1mChoco-Scripts are not installed for this user\033[0m\n"
    exit 1
fi

#
#   Information message
#
echo "Using choco-scripts from path $CHOCO_SCRIPTS_PATH in version $CHOCO_SCRIPTS_VERSION"

#
#   Importing of the framework main script
#
source $(getChocoScriptsPath)

#
#   The function prepares a framework script to work
#
function prepareScript()
{
    defineScript "$0" "Initialization script for the repository"    
    
    addCommandLineOptionalArgument MODULES_LIST_FILE_PATH "--list" "existing_file" "Path to a file with list of modules" "$THIS_DIR/generated_modules.sh"
    addCommandLineOptionalArgument CONFIG_DIR "--config" "existing_directory" "Path to a directory with swagger configurations" "$THIS_DIR/configs"
    
    parseCommandLineArguments "$@"
}

#
#   Generates the given module
#
function generate()
{
    local module=$1
    local genera_file_path=$THIS_DIR/generate.sh
    local directory_name=${GENERATED_MODULES_DIRECTORIES[$module]}
    local directory_path=$GENERATED_BASE_DIR/$directory_name
        
    doCommandAsStep "Removing of all not hidden files from $directory_path" find "$directory_path" -type f -name "'[^.]*'" -delete
    doCommandAsStep "Generation of module $module" $genera_file_path -m=$module -c="'$CONFIG_DIR/${module}.json'"
}

#######################################################################################
#
#   MAIN
#
prepareScript "$@"

doCommandAsStep "Repository GIT submodules initialization" git submodule init
doCommandAsStep "Update of the submodules" git submodule update --recursive

source $MODULES_LIST_FILE_PATH

for module in ${GENERATED_MODULES_NAMES[@]}
do 
    generate "$module"
done
