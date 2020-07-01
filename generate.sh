#!/bin/bash
#
#       Generates REST server or client
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
    defineScript "$0" "The script is for generation of REST server or client. Please remember to call initialize.sh script first"
    
    addCommandLineOptionalArgument MODULE "-m|--module" "options" "Name of swagger-codegen module to use" "php-symfony" "php-symfony php"
    addCommandLineOptionalArgument TARGET_PATH "-t|--target-path" "directory" "Target directory for the generated code" "$THIS_DIR"
    addCommandLineOptionalArgument GENERATE_FILE_PATH "--generate-file-path" "file" "Path to the generate.sh script from swagger-codegen repository" "/swagger/generate.sh"
    addCommandLineOptionalArgument YAML_FILE_PATH "--yaml" "existing_file" "Path to the existing Yaml file with the REST interface definition" "$THIS_DIR/swagger.yaml"
    addCommandLineOptionalArgument HOST "-h|--host" "not_empty_string" "URL to use as host for the generated clients" "oauth2.choco-technologies.com"
    addCommandLineOptionalArgument VERSION "-v|--version" "not_empty_string" "Version to use in the interface definition" "1.0.0"
    addCommandLineOptionalArgument SWAGGER_JAR_FILE "--jar" "file" "Path to the swagger JAR file" "/swagger/swagger-codegen-cli.jar"
    addCommandLineOptionalArgument DOCKER_IMAGE "--image" "not_empty_string" "Name of the image to use for code generation" "chocotechnologies/swagger-codegen"
    addCommandLineOptionalArgument CONFIG_FILE "-c|--config" "file" "Path to the file with configuration" ""
    
    addRequiredTool java "JAVA is required for the swagger-codegen, to execute the JAR file" "TRUE" "sudo apt-get install default-jdk"
    
    parseCommandLineArguments "$@"
}

#
#   Updates information in the swagger file
#
function updateYaml()
{
    YAML=$(cat $YAML_FILE_PATH | sed -r "s/[0-9]+\.[0-9]+\.[0-9]+/$VERSION/g" | sed -r "s/host:.*$/host: $HOST/g")
    echo "$YAML" > $YAML_FILE_PATH
}

#######################################################################################
#
#   MAIN
#
prepareScript "$@"
updateYaml

if fileExists "$GENERATE_FILE_PATH" && fileExists "$SWAGGER_JAR_FILE"
then 
    doCommandAsStep "Generation of module $MODULE" $GENERATE_FILE_PATH --jar="$SWAGGER_JAR_FILE"  -m=$MODULE -i=$YAML_FILE_PATH -t=$TARGET_PATH -o="'--config=$CONFIG_FILE'"
else 
    doCommandAsStep "Generation of module $MODULE by using docker image $DOCKER_IMAGE" docker run -it --rm -v $THIS_DIR:$THIS_DIR -w $THIS_DIR $DOCKER_IMAGE "$GENERATE_FILE_PATH" --jar="$SWAGGER_JAR_FILE" -m=$MODULE -i=$YAML_FILE_PATH -t=$TARGET_PATH -o="'--config=$CONFIG_FILE'"
    doCommandAsStep "Changing owner of files to $(id -u):$(id -g)" docker run --rm -it -v $THIS_DIR:$THIS_DIR -w $THIS_DIR $DOCKER_IMAGE find $THIS_DIR -exec chown $(id -u):$(id -g) {} \\\;
fi 
