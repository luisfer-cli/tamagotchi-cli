# Tamagotchi CLI 🐾

An interactive Tamagotchi-style game completely in the terminal using Lua, with persistence, system monitoring, multiple pets with breeding, types, and an economy system where players can earn coins even by using normal system commands.

## 🚀 Quick Start

```bash
# Make the file executable
chmod +x tamagotchi.lua

# View help
lua tamagotchi.lua help

# Create your first pet
lua tamagotchi.lua create

# View all your pets
lua tamagotchi.lua list

# View active pet status
lua tamagotchi.lua status
```

## 📁 Project Structure

```
tamagotchi-cli/
├── tamagotchi.lua          # Main executable file
├── modules/                # Game modules
│   ├── cli.lua            # Command line interface
│   ├── tamagotchi.lua     # Pet logic
│   ├── persistence.lua    # Save system
│   ├── economy.lua        # Economic system
│   ├── inventory.lua      # Inventory management
│   ├── breeding.lua       # Breeding system
│   └── utils.lua          # General utilities
├── data/                  # Player data
│   ├── wallet.lua         # Player coins
│   └── inventory.lua      # Player inventory
├── tamagotchis/           # Pet files
│   ├── lista.txt          # Pet list
│   └── *.lua              # Individual pet files
└── logs/                  # Log files
```

## 🎮 Main Commands

### Basic
- `create` - Create new tamagotchi
- `list` - View all tamagotchis
- `select <name>` - Select tamagotchi to play with
- `status` - View active tamagotchi status

### Care
- `feed` - Feed tamagotchi (automatically uses food from inventory)
- `play` - Play with tamagotchi (increases happiness, uses energy)
- `sleep` - Sleep/wake tamagotchi (recovers energy)
- `clean` - Clean tamagotchi (increases cleanliness and happiness)
- `evolve` - Attempt evolution (requires age and happiness)

### Economy
- `work` - Work to earn coins (requires energy)
- `earn` - Earn coins from system command history
- `buy <item>` - Buy items from shop
- `shop` - View shop with prices
- `wallet` - View coin amount

### Inventory
- `inventory` - View items in inventory
- `use <item>` - Use specific item from inventory
- `autofeed` - Feed automatically if hungry
- `autoheal` - Heal automatically if low health

### Breeding
- `breed <father> <mother> <child>` - Breed two tamagotchis
- `family <name>` - View family tree
- `compatibility <pet1> <pet2>` - View breeding compatibility

### Other
- `help` - Show complete help
- `bonus` - Receive daily bonus (once per day)

## 🐾 Available Races

- **Dog** - Balanced, good strength and resistance
- **Cat** - High happiness and intelligence, very fast
- **Bird** - Lots of energy and speed, very intelligent
- **Fish** - Basic for beginners
- **Dragon** - Superior stats, very powerful

## 🔮 Elemental Types

- **Normal** (x1.0) - No modifiers
- **Fire** (x1.2) - 20% more stats
- **Water** (x1.1) - 10% more stats
- **Earth** (x1.15) - 15% more stats
- **Air** (x1.25) - 25% more stats

## 📈 Evolution

Pets evolve through 4 stages:
1. **Baby** (0+ hours)
2. **Child** (7+ hours, 50+ happiness)
3. **Adult** (30+ hours, 70+ happiness)
4. **Elder** (100+ hours, 60+ happiness)

## 🛒 Shop System

| Item | Price | Effect |
|------|-------|--------|
| Apple | 5 coins | Reduces hunger (15) |
| Meat | 12 coins | Reduces lots of hunger (30) |
| Medicine | 25 coins | Restores health (40) |
| Toy | 18 coins | Increases happiness (20) |
| Soap | 8 coins | Complete cleaning |
| Vitamins | 35 coins | Improves stats (+5) |
| Energy Drink | 15 coins | Restores energy (40) |

## 🔧 System Monitoring

The game automatically monitors your system:
- **CPU > 70%** → Reduces health and happiness
- **RAM > 80%** → Reduces health

## 💰 Earning Coins

1. **Work** - `work` command (requires pet energy)
2. **Command History** - `earn` command (reads bash/zsh history)
3. **Daily Bonus** - `bonus` command (once per day)

## 👨‍👩‍👧‍👦 Breeding System

- Breed two adult or elder pets
- Requires minimum happiness and health
- Costs coins based on parent stages
- Children inherit stats with possible mutations
- Small chance of race/type mutation

## 🎯 Tips

1. **Keep your pet happy** - Necessary for evolution
2. **Buy food regularly** - Pets are always hungry
3. **Use `autofeed` and `autoheal`** - For automatic care
4. **Work to earn coins** - But watch energy levels
5. **Monitor system** - High CPU/RAM affects pets
6. **Breed pets** - To get better stats

## 🔄 Persistence

- All pets are automatically saved
- Inventory and coins persist between sessions
- Files stored in readable Lua format
- Automatic backups in `data/backups/`

## ⚠️ Requirements

- Lua 5.3 or higher
- Linux system (for `/proc/` monitoring)
- Terminal with ANSI color support

Enjoy caring for your virtual pets! 🎮✨