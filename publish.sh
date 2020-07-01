#!/bin/bash
#
#       Script for publishing of generated API
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
    defineScript "$0" "The script for publishing of the generated API"
    
    addCommandLineRequiredArgument VERSION "-v|--version" "not_empty_string" "Version of the interface to publish"
    addCommandLineOptionalArgument GENERATE_FILE_PATH "--generate-file-path" "existing_file" "Path to the generate.sh script" "$THIS_DIR/generate.sh"
    addCommandLineOptionalArgument MODULES_LIST_FILE_PATH "--list" "existing_file" "Path to a file with list of modules" "$THIS_DIR/generated_modules.sh"
    addCommandLineOptionalArgument CONFIG_DIR "--config" "existing_directory" "Path to a directory with swagger configurations" "$THIS_DIR/configs"
    
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
    
    cd $directory_path
    doCommandAsStep "[$module] Reseting local changes" git reset --hard origin/master
    doCommandAsStep "[$module] Checking out master branch" git checkout .
    doCommandAsStep "[$module] Checking out master branch" git checkout master
    doCommandAsStep "Removing of all not hidden files from $directory_path" find . -type f -name "'[^.]*'" -delete
    cd $THIS_DIR
    
    $GENERATE_FILE_PATH -m=$module -v=$VERSION -c="$CONFIG_DIR/${module}.json"
}

#
#   Checks if git tag exists
#
function tagExists()
{
    local tagName=$1
    git tag -l $tagName >/dev/null 2>&1
    return $?
}

#
#   Publishes the new version
#
function publish()
{
    local module=$1
    local directory_name=${GENERATED_MODULES_DIRECTORIES[$module]}
    local directory_path=$GENERATED_BASE_DIR/$directory_name
    
    cd $directory_path
    doCommandAsStep "[$module] Adding all changes to git" git add .
    doCommandAsStep "[$module] Commit changes for version $VERSION" git commit -m "'Automatically generated changes for version $VERSION'"
    if tagExists $VERSION
    then 
        doCommandAsStep "[$module] Removing previous version tag $VERSION" git tag -d $VERSION
        doCommandAsStep "[$module] Removing of previous version tag $VERSION from origin" git push origin :refs/tags/$VERSION
    fi
    doCommandAsStep "[$module] Tagging the changes with TAG $VERSION" git tag -a $VERSION -m "'Automatically generated version $VERSION'"
    doCommandAsStep "[$module] Pushing the changes" git push
    doCommandAsStep "[$module] Pushing the tags" git push origin --tags
    cd $THIS_DIR
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
    publish $module
done
