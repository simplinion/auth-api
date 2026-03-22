#!/bin/bash
#
#       Script for packaging of generated API as artifacts
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
    defineScript "$0" "The script for packaging of the generated API as zip artifacts"
    
    addCommandLineRequiredArgument VERSION "-v|--version" "not_empty_string" "Version of the interface to package"
    addCommandLineOptionalArgument GENERATE_FILE_PATH "--generate-file-path" "existing_file" "Path to the generate.sh script" "$THIS_DIR/generate.sh"
    addCommandLineOptionalArgument MODULES_LIST_FILE_PATH "--list" "existing_file" "Path to a file with list of modules" "$THIS_DIR/generated_modules.sh"
    addCommandLineOptionalArgument CONFIG_DIR "--config" "existing_directory" "Path to a directory with swagger configurations" "$THIS_DIR/configs"
    addCommandLineOptionalArgument ARTIFACTS_DIR "--artifacts-dir" "directory" "Path to the directory where zip artifacts will be stored" "$THIS_DIR/artifacts"
    
    parseCommandLineArguments "$@"
}

#
#   Generates the new version
#
function generate()
{
    local module=$1
    local directory_name=${GENERATED_MODULES_DIRECTORIES[$module]}
    local directory_path=$GENERATED_BASE_DIR/$directory_name
    
    doCommandAsStep "Creating directory for module $module" mkdir -p "$directory_path"
    doCommandAsStep "Removing of all files from $directory_path" find "$directory_path" -type f -delete
    
    $GENERATE_FILE_PATH -m=$module -v=$VERSION -c="$CONFIG_DIR/${module}.json" -t="$directory_path"
}

#
#   Packages the generated module as a zip artifact
#
function package()
{
    local module=$1
    local directory_name=${GENERATED_MODULES_DIRECTORIES[$module]}
    local artifact_name="${module}-${VERSION}.zip"
    
    doCommandAsStep "Creating artifacts directory $ARTIFACTS_DIR" mkdir -p "$ARTIFACTS_DIR"
    cd "$GENERATED_BASE_DIR"
    doCommandAsStep "[$module] Creating artifact $artifact_name" zip -r "$ARTIFACTS_DIR/$artifact_name" "$directory_name"

    if [ -f "$THIS_DIR/RELEASE_NOTES.md" ]; then
        doCommandAsStep "[$module] Adding release notes to $artifact_name" zip -j "$ARTIFACTS_DIR/$artifact_name" "$THIS_DIR/RELEASE_NOTES.md"
    fi

    cd "$THIS_DIR"
}

#######################################################################################
#
#   MAIN
#
prepareScript "$@"

source $MODULES_LIST_FILE_PATH

for module in ${GENERATED_MODULES_NAMES[@]}
do 
    generate $module
    package $module
done
