# auth-api

This repository stores and versions the **Simplinion Authorization API** definition (`swagger.yaml`) and provides tooling to generate server/client code for other applications using [swagger-codegen](https://github.com/swagger-api/swagger-codegen).

## What is this repository for?

The `swagger.yaml` file is the single source of truth for the Simplinion Authorization API (OAuth2 + Basic auth). From this definition, server and client stubs are automatically generated for the following targets:

| Module | Swagger-codegen generator | Output directory |
|---|---|---|
| `php-symfony` | Symfony PHP server bundle | `SymfonyBundle-php/` |
| `php` | PHP client library | `SwaggerClient-php/` |
| `qt5cpp` | Qt5/C++ client library | `qt5cpp/` |

## Repository structure

```
auth-api/
├── swagger.yaml            # API definition (edit this file to change the API)
├── configs/                # Per-module swagger-codegen configuration files
│   ├── php-symfony.json
│   ├── php.json
│   └── qt5cpp.json
├── generated_modules.sh    # List of modules and their output directory names
├── generate.sh             # Generate a single module
├── initialize.sh           # Generate all modules locally
├── publish.sh              # Generate all modules and package them as zip artifacts
├── bitbucket-pipelines.yml # CI/CD pipeline definition
├── SymfonyBundle-php/      # Generated Symfony server bundle (submodule)
├── SwaggerClient-php/      # Generated PHP client (submodule)
└── qt5cpp/                 # Generated Qt5/C++ client (submodule)
```

## Prerequisites

- **Java** – required to run the swagger-codegen JAR directly.  
  Install with: `sudo apt-get install default-jdk`
- **Docker** (alternative to Java) – the scripts can use the `chocotechnologies/swagger-codegen` Docker image instead of a local JAR.
- **choco-scripts** framework – the shell scripts depend on the internal `choco-scripts` framework.  
  The framework must be installed for the current user; its location is read from `~/.choco-scripts.cfg`.

## Modifying the API

Edit `swagger.yaml` and commit the change. The CI/CD pipeline (or the `initialize.sh` script) will regenerate the client/server code automatically.

## Generating code locally

### Generate all modules

```bash
./initialize.sh
```

Optional arguments:

| Argument | Default | Description |
|---|---|---|
| `--list <file>` | `./generated_modules.sh` | Path to the file that lists the modules |
| `--config <dir>` | `./configs` | Directory that contains per-module JSON configs |

### Generate a single module

```bash
./generate.sh -m <module> [options]
```

| Argument | Default | Description |
|---|---|---|
| `-m, --module` | `php-symfony` | Swagger-codegen module name (`php-symfony`, `php`, `qt5cpp`) |
| `-t, --target-path` | current directory | Output directory for generated code |
| `--yaml <file>` | `./swagger.yaml` | Path to the Swagger YAML file |
| `-h, --host <url>` | `oauth2.simplinion.com` | Host URL written into the generated code |
| `-v, --version <ver>` | `1.0.0` | API version written into the generated code |
| `--jar <file>` | `/swagger/swagger-codegen-cli.jar` | Path to the swagger-codegen JAR |
| `--image <name>` | `simplinion/swagger-codegen` | Docker image used when the JAR is unavailable |
| `-c, --config <file>` | *(none)* | Path to a module-specific JSON config file |

## Publishing artifacts

```bash
./publish.sh -v <version>
```

This script generates all modules for the given version and packages each one as a ZIP archive under the `artifacts/` directory:

```
artifacts/
├── php-symfony-<version>.zip
├── php-<version>.zip
└── qt5cpp-<version>.zip
```

## CI/CD (Bitbucket Pipelines)

The pipeline is defined in `bitbucket-pipelines.yml` and runs on the `chocotechnologies/swagger-codegen:1.0.46` Docker image.

| Trigger | Step | Script |
|---|---|---|
| Every push (default) | Initialization | `./initialize.sh` |
| Tag matching `V.*` | Publish new version | `./publish.sh -v "<tag without V.>"` |

Published artifacts are stored under `artifacts/**`.

## Contributing

1. Update `swagger.yaml` with the desired API changes.
2. Run `./initialize.sh` locally to verify that code generation succeeds.
3. Open a pull request with the `swagger.yaml` change.
4. After merging, create a tag in the format `V.<semver>` (e.g. `V.1.2.0`) to trigger a release build and publish the artifacts.
