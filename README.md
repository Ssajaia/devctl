# devctl — Docker Project Manager

A production-quality Bash CLI tool that simplifies and standardizes Docker Compose workflows for developers working across multiple projects.

---

## Features

- **Simple commands** — `up`, `down`, `logs`, `rebuild`, `status`
- **Smart project root detection** — walks up the directory tree to find `docker-compose.yml`
- **Colored output** — clean, readable ANSI-colored terminal output
- **Command aliases** — `start`, `stop`, `ps`, `build`, and more
- **Dry-run mode** — preview commands without executing them (`--dry-run`)
- **Verbose mode** — detailed output for debugging (`--verbose`)
- **Project config** — per-project `.devctlrc` file support
- **`.env` support** — automatically loads `.env` from project root
- **Error handling** — validates Docker installation and daemon state before running
- **Modular structure** — clean separation of commands and utilities

---

## Project Structure

```
devctl/
├── devctl.sh              # Main entry point
├── install.sh             # Installer script
├── .devctlrc.example      # Example project config
├── commands/
│   ├── up.sh
│   ├── down.sh
│   ├── logs.sh
│   ├── rebuild.sh
│   └── status.sh
├── utils/
│   ├── docker.sh          # Docker/compose helpers
│   ├── logger.sh          # Colored logging functions
│   └── validator.sh       # Pre-flight checks
├── config/
│   └── default.conf       # Default configuration values
└── README.md
```

---

## Installation

```bash
git clone https://github.com/ssajaia/devctl.git
cd devctl
sudo bash install.sh
```

This creates a symlink at `/usr/local/bin/devctl` pointing to your cloned directory.

To uninstall:

```bash
sudo rm /usr/local/bin/devctl
```

---

## Usage

```bash
devctl [OPTIONS] <command> [args]
```

### Commands

| Command              | Description                                |
|----------------------|--------------------------------------------|
| `devctl up`          | Start containers in detached mode          |
| `devctl down`        | Stop and remove containers                 |
| `devctl logs`        | Stream logs for all services               |
| `devctl logs api`    | Stream logs for a specific service         |
| `devctl rebuild`     | Rebuild images and restart containers      |
| `devctl status`      | Show running container status              |

### Options

| Flag             | Description                          |
|------------------|--------------------------------------|
| `-h, --help`     | Show help message                    |
| `-v, --verbose`  | Enable verbose/debug output          |
| `-n, --dry-run`  | Print commands without executing     |
| `--version`      | Show version number                  |

### Examples

```bash
devctl up
devctl up --build

devctl down
devctl down --volumes

devctl logs
devctl logs api
devctl logs api --tail 50 --no-follow

devctl rebuild
devctl rebuild --no-cache
devctl rebuild api --no-cache

devctl status
devctl status --json

devctl --dry-run up
devctl --verbose rebuild --no-cache
```

### Command Aliases

| Alias         | Resolves To |
|---------------|-------------|
| `start`, `u`  | `up`        |
| `stop`, `d`   | `down`      |
| `log`, `l`    | `logs`      |
| `build`, `r`  | `rebuild`   |
| `ps`, `stat`, `s` | `status` |

---

## Project Configuration

Place a `.devctlrc` file in your project root (alongside `docker-compose.yml`) to override defaults:

```bash
COMPOSE_FILE="docker-compose.prod.yml"
PROJECT_NAME="my-app"
DEFAULT_SERVICE="api"
LOG_TAIL_LINES="200"
REBUILD_NO_CACHE_DEFAULT="false"
```

Copy the example:

```bash
cp .devctlrc.example /path/to/your/project/.devctlrc
```

---

## Environment Variables

`devctl` automatically loads a `.env` file from the project root before running commands. This means `COMPOSE_PROJECT_NAME` and other Docker Compose variables are available without any manual sourcing.

---

## How Project Root Detection Works

`devctl` walks up from the current working directory until it finds a `docker-compose.yml`, `docker-compose.yaml`, or `compose.yaml` file. This means you can run `devctl` from any subdirectory of your project.

---

## Requirements

- Bash 4.0+
- Docker Engine with Compose plugin (`docker compose`)
- Linux (Ubuntu-based systems recommended)

---

## Future Improvements

- `devctl exec <service> <cmd>` — run commands in containers
- `devctl shell <service>` — open an interactive shell
- `devctl ps --watch` — live-updating status view
- `devctl init` — scaffold a new project with a compose template
- Shell completion (bash/zsh)
- `devctl pull` — pull latest images before starting
- Multi-environment support (`devctl --env staging up`)

---

## License

MIT
