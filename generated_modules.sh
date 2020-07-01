#!/bin/bash

GENERATED_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

declare -a GENERATED_MODULES_NAMES=(php-symfony php)
declare -A GENERATED_MODULES_DIRECTORIES=(
    [php-symfony]=SymfonyBundle-php
    [php]=SwaggerClient-php
)
