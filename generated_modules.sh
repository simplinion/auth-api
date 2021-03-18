#!/bin/bash

GENERATED_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

declare -a GENERATED_MODULES_NAMES=(php-symfony php qt5cpp)
declare -A GENERATED_MODULES_DIRECTORIES=(
    [php-symfony]=SymfonyBundle-php
    [php]=SwaggerClient-php
    [qt5cpp]=qt5cpp
)
