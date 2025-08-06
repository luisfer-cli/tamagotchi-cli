# Tamagotchi CLI

A command-line virtual pet game designed as an interactive tutorial for developers learning terminal usage. This project teaches common CLI patterns, command structures, and best practices through caring for digital pets.

## Overview

Tamagotchi CLI combines the nostalgia of virtual pet games with practical command-line learning. Players manage virtual pets while discovering standard CLI conventions, subcommand patterns, argument handling, and terminal workflows used in professional development tools.

## Installation

### Pre-built Binary (Recommended)

Download the statically-linked binary for immediate use:

```bash
# Download latest release
wget https://github.com/luisfer-cli/tamagotchi-cli/releases/latest/download/tamagotchi-cli

# Make executable
chmod +x tamagotchi-cli

# Run from current directory
./tamagotchi-cli --help

# Install system-wide (optional)
sudo mv tamagotchi-cli /usr/local/bin/
```

### From Source

Requirements: Lua 5.3+ and Linux system for monitoring features

```bash
# Clone repository
git clone https://github.com/luisfer-cli/tamagotchi-cli.git
cd tamagotchi-cli

# Build static binary
./build.sh

# Or run directly with Lua
lua tamagotchi.lua --help
```

## Quick Start Tutorial

### 1. Basic CLI Help Patterns

```bash
# Standard help flags (learn common conventions)
tamagotchi-cli --help     # Brief usage overview
tamagotchi-cli -h         # Short form
tamagotchi-cli help       # Detailed command reference

# Version information
tamagotchi-cli --version
tamagotchi-cli -v
```

### 2. Create Your First Pet

```bash
# Interactive creation process
tamagotchi-cli create
```

### 3. List and Selection Pattern

```bash
# View all resources (like 'ls', 'git branch')
tamagotchi-cli list

# Select active resource (like 'cd', 'git checkout')
tamagotchi-cli select MyPet

# Check current status (like 'pwd', 'git status')
tamagotchi-cli status
```

## Command Reference

### Core Commands

| Command | Purpose | CLI Pattern Demonstrated |
|---------|---------|------------------------|
| `create` | Create new pet | Resource initialization |
| `list` | Show all pets | Listing operations |
| `select <name>` | Set active pet | Context switching |
| `status` | Show pet condition | Status queries |

### Pet Care

| Command | Purpose | Example |
|---------|---------|---------|
| `feed` | Feed active pet | `tamagotchi-cli feed` |
| `play` | Play with pet | `tamagotchi-cli play` |
| `sleep` | Toggle sleep state | `tamagotchi-cli sleep` |
| `clean` | Clean pet | `tamagotchi-cli clean` |
| `evolve` | Attempt evolution | `tamagotchi-cli evolve` |

### Economy System

| Command | Purpose | Example |
|---------|---------|---------|
| `shop` | View available items | `tamagotchi-cli shop` |
| `buy <item>` | Purchase item | `tamagotchi-cli buy apple` |
| `wallet` | Show coin balance | `tamagotchi-cli wallet` |
| `work` | Earn coins | `tamagotchi-cli work` |
| `earn` | Earn from command history | `tamagotchi-cli earn` |

### Inventory Management

| Command | Purpose | Example |
|---------|---------|---------|
| `inventory` | Show owned items | `tamagotchi-cli inventory` |
| `use <item>` | Use specific item | `tamagotchi-cli use medicine` |
| `autofeed` | Auto-feed if hungry | `tamagotchi-cli autofeed` |
| `autoheal` | Auto-heal if needed | `tamagotchi-cli autoheal` |

### Advanced Features

| Command | Purpose | Example |
|---------|---------|---------|
| `breed <f> <m> <child>` | Create offspring | `tamagotchi-cli breed Dad Mom Baby` |
| `family <name>` | View family tree | `tamagotchi-cli family Baby` |
| `compatibility <p1> <p2>` | Check breeding compatibility | `tamagotchi-cli compatibility Dad Mom` |
| `bonus` | Daily coin bonus | `tamagotchi-cli bonus` |

## CLI Learning Concepts

### 1. Command Structure Patterns

```bash
# Basic command
tamagotchi-cli status

# Command with argument
tamagotchi-cli select MyPet

# Command with multiple arguments
tamagotchi-cli breed Father Mother Child

# Global flags (position independent)
tamagotchi-cli --version
tamagotchi-cli -h
```

### 2. State Management

The game demonstrates how CLI tools manage context:

- **Active Pet**: Similar to current working directory (`pwd`)
- **Persistent State**: Like Git repositories or configuration files
- **List Operations**: View available resources before selection

### 3. Error Handling

Professional error messages with helpful suggestions:

```bash
$ tamagotchi-cli invalid-command
Error: Unknown command 'invalid-command'

CLI Tutorial Tip:
• Commands must be typed exactly as shown (case-sensitive)
• Use 'tamagotchi-cli help' to see all available commands
• Use 'tamagotchi-cli --help' for quick usage overview

Did you mean one of these?
  help - Show help documentation
```

### 4. Subcommand Patterns

Learn how professional tools organize functionality:

- Resource management: `create`, `list`, `select`
- Operations: `feed`, `play`, `clean`
- Queries: `status`, `wallet`, `inventory`
- Utilities: `help`, `version`

## Game Mechanics

### Pet Attributes

- **Health**: Affected by feeding and system monitoring
- **Happiness**: Increased by playing and cleaning
- **Energy**: Consumed by activities, restored by sleeping
- **Hunger**: Increases over time, reduced by feeding
- **Cleanliness**: Decreases over time, restored by cleaning

### Evolution System

Pets progress through life stages based on age and care:

1. **Baby** (0+ hours)
2. **Child** (7+ hours, 50+ happiness)
3. **Adult** (30+ hours, 70+ happiness)
4. **Elder** (100+ hours, 60+ happiness)

### Economic System

- **Work**: Earn coins using pet energy
- **Command History**: Gain coins from terminal usage
- **Daily Bonus**: Once per 24-hour period
- **Shop**: Purchase food, medicine, toys, and utilities

### System Monitoring

Real-time system integration:
- High CPU usage affects pet health
- High memory usage impacts pet happiness
- Demonstrates CLI tools interacting with system state

## Data Persistence

### Storage Location

Follows XDG Base Directory specification:

```
~/.local/share/tamagotchi-cli/
├── wallet.lua              # Player currency
├── inventory.lua           # Owned items
├── active_pet.txt          # Current active pet
├── last_history_check.txt  # Command history tracking
├── last_bonus.txt          # Daily bonus tracking
└── tamagotchis/           # Pet data files
    ├── lista.txt          # Pet registry
    └── *.lua              # Individual pet files
```

### Backup System

- Automatic backup creation
- Human-readable Lua format
- Portable between systems
- Fallback to local directory if XDG unavailable

## Professional CLI Patterns Demonstrated

### 1. Help Systems
- `--help` / `-h` for usage overview
- `help` command for detailed documentation
- Context-sensitive error messages

### 2. Version Management
- `--version` / `-v` flags
- Semantic versioning display
- Build and repository information

### 3. State Management
- Active context concept (current pet)
- Persistent configuration
- State validation and recovery

### 4. User Experience
- Progress indicators
- Colored output for status
- Educational tips and suggestions
- Tab completion friendly commands

### 5. Error Handling
- Descriptive error messages
- Suggested corrections
- Graceful degradation
- Exit code consistency

## Development

### Building

```bash
# Create static binary with luastatic
./build.sh

# Run tests (if available)
lua test.lua

# Development mode
lua tamagotchi.lua help
```

### Project Structure

```
tamagotchi-cli/
├── tamagotchi.lua          # Main entry point
├── build.sh               # Build script
├── modules/               # Core game logic
│   ├── cli.lua           # Command interface
│   ├── tamagotchi.lua    # Pet mechanics
│   ├── persistence.lua   # Data storage
│   ├── economy.lua       # Economic system
│   ├── inventory.lua     # Item management
│   ├── breeding.lua      # Breeding system
│   └── utils.lua         # Shared utilities
└── README.md             # This documentation
```

## System Requirements

### Binary Version
- Linux x86_64 system
- Terminal with ANSI color support
- No additional dependencies

### Source Version
- Lua 5.3 or higher
- Linux system (for `/proc/` monitoring)
- Standard POSIX utilities

## Contributing

This project serves as both a learning tool and reference implementation for CLI design patterns. Contributions that enhance the educational value while maintaining professional CLI standards are welcome.

## License

Open source - check repository for specific license terms.

## Educational Resources

- [Command Line Interface Guidelines](https://clig.dev/)
- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)