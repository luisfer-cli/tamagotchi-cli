local utils = require('modules.utils')
local tamagotchi = require('modules.tamagotchi')
local persistence = require('modules.persistence')
local economy = require('modules.economy')
local inventory = require('modules.inventory')
local breeding = require('modules.breeding')

local cli = {}

function cli.init()
    persistence.init()
    math.randomseed(os.time())
end

function cli.show_help()
    local help_text = {
        utils.colors.bold .. utils.colors.cyan .. "TAMAGOTCHI CLI" .. utils.colors.reset .. utils.colors.bold .. " - Command Reference" .. utils.colors.reset,
        "",
        utils.colors.dim .. "A tutorial-based virtual pet game for learning command-line interface usage." .. utils.colors.reset,
        utils.colors.dim .. "This game teaches common CLI patterns while you care for digital pets." .. utils.colors.reset,
        "",
        utils.colors.yellow .. "GETTING STARTED:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "create" .. utils.colors.reset .. "                     Create your first tamagotchi pet",
        "  " .. utils.colors.green .. "list" .. utils.colors.reset .. "                       View all your pets (shows which is active)",
        "  " .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "<name>" .. utils.colors.reset .. "              Switch to a different pet",
        "  " .. utils.colors.green .. "status" .. utils.colors.reset .. "                     Check your active pet's current condition",
        "",
        utils.colors.yellow .. "PET CARE COMMANDS:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "feed" .. utils.colors.reset .. "                       Feed your pet (uses items from inventory)",
        "  " .. utils.colors.green .. "play" .. utils.colors.reset .. "                       Play with your pet (increases happiness)",
        "  " .. utils.colors.green .. "sleep" .. utils.colors.reset .. "                      Put pet to sleep or wake them up",
        "  " .. utils.colors.green .. "clean" .. utils.colors.reset .. "                      Clean your pet (improves mood)",
        "  " .. utils.colors.green .. "evolve" .. utils.colors.reset .. "                     Attempt to evolve your pet to next stage",
        "",
        utils.colors.yellow .. "ECONOMY & SHOPPING:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "work" .. utils.colors.reset .. "                       Work to earn coins (requires pet energy)",
        "  " .. utils.colors.green .. "earn" .. utils.colors.reset .. "                       Earn coins from your command history",
        "  " .. utils.colors.green .. "shop" .. utils.colors.reset .. "                       View available items and prices",
        "  " .. utils.colors.green .. "buy" .. utils.colors.reset .. " " .. utils.colors.blue .. "<item>" .. utils.colors.reset .. "                 Purchase items (e.g., 'buy apple')",
        "  " .. utils.colors.green .. "wallet" .. utils.colors.reset .. "                     Check your current coin balance",
        "",
        utils.colors.yellow .. "INVENTORY MANAGEMENT:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "inventory" .. utils.colors.reset .. "                  View all items you own",
        "  " .. utils.colors.green .. "use" .. utils.colors.reset .. " " .. utils.colors.blue .. "<item>" .. utils.colors.reset .. "                 Use a specific item (e.g., 'use medicine')",
        "  " .. utils.colors.green .. "autofeed" .. utils.colors.reset .. "                   Automatically feed if pet is hungry",
        "  " .. utils.colors.green .. "autoheal" .. utils.colors.reset .. "                   Automatically heal if pet needs health",
        "",
        utils.colors.yellow .. "BREEDING SYSTEM:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "breed" .. utils.colors.reset .. " " .. utils.colors.blue .. "<father> <mother> <child>" .. utils.colors.reset .. "  Create offspring from two pets",
        "  " .. utils.colors.green .. "family" .. utils.colors.reset .. " " .. utils.colors.blue .. "<name>" .. utils.colors.reset .. "              View family tree for a pet",
        "  " .. utils.colors.green .. "compatibility" .. utils.colors.reset .. " " .. utils.colors.blue .. "<pet1> <pet2>" .. utils.colors.reset .. "      Check breeding compatibility",
        "",
        utils.colors.yellow .. "DAILY ACTIVITIES:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "bonus" .. utils.colors.reset .. "                      Claim daily coin bonus (once per 24 hours)",
        "  " .. utils.colors.green .. "help" .. utils.colors.reset .. "                       Show this help documentation",
        "",
        utils.colors.magenta .. "COMMAND LINE TUTORIAL TIPS:" .. utils.colors.reset,
        "",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Commands are case-sensitive - use lowercase",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Use Tab completion: type 'tamag' + Tab to auto-complete",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Arguments go after commands: 'tamagotchi-cli buy apple'",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Use quotes for names with spaces: 'select \"My Pet\"'",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Check exit codes: echo $? shows if last command succeeded",
        "",
        utils.colors.magenta .. "COMMON CLI PATTERNS DEMONSTRATED:" .. utils.colors.reset,
        "",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Subcommands: '" .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.green .. "buy" .. utils.colors.blue .. " apple" .. utils.colors.reset .. "' (command + subcommand + arg)",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " List operations: '" .. utils.colors.green .. "list" .. utils.colors.reset .. "' shows data, '" .. utils.colors.green .. "select" .. utils.colors.reset .. "' chooses from list",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " State management: One 'active' pet, like current directory in shell",
        utils.colors.cyan .. "•" .. utils.colors.reset .. " Help systems: '" .. utils.colors.green .. "help" .. utils.colors.reset .. "' and '" .. utils.colors.magenta .. "--help" .. utils.colors.reset .. "' are standard in CLI tools",
        "",
        utils.colors.bold .. "Examples:" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "create" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "buy" .. utils.colors.reset .. " " .. utils.colors.blue .. "apple" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "Buddy" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "status" .. utils.colors.reset,
        "",
        utils.colors.blue .. "Learn more about CLI concepts: " .. utils.colors.reset .. utils.colors.cyan .. "https://cli.github.io/" .. utils.colors.reset
    }
    
    print(table.concat(help_text, "\n"))
end

function cli.create_tamagotchi()
    print(utils.colors.bold .. "=== CREATE NEW TAMAGOTCHI ===" .. utils.colors.reset)
    print()
    
    io.write("Your pet's name: ")
    local name = io.read()
    if not name then
        print(utils.colors.red .. "Error reading input." .. utils.colors.reset)
        return
    end
    name = name:gsub("%s+", "")
    
    if name == "" then
        print(utils.colors.red .. "Name cannot be empty." .. utils.colors.reset)
        return
    end
    
    if persistence.load_tamagotchi(name) then
        print(utils.colors.red .. "A pet with that name already exists." .. utils.colors.reset)
        return
    end
    
    print("\nAvailable races:")
    local race_options = {}
    for race, data in pairs(tamagotchi.races) do
        table.insert(race_options, race)
        print(string.format("  %s - %s", race, data.name))
    end
    
    io.write("\nSelect a race: ")
    local race = io.read()
    if not race then
        race = "dog"
        print("No input provided, using 'dog' by default.")
    else
        race = race:gsub("%s+", "")
    end
    
    if not tamagotchi.races[race] then
        race = "dog"
        print("Invalid race, using 'dog' by default.")
    end
    
    print("\nAvailable types:")
    local type_options = {}
    for type_name, data in pairs(tamagotchi.types) do
        table.insert(type_options, type_name)
        print(string.format("  %s - %s (x%.1f)", type_name, data.name, data.modifier))
    end
    
    io.write("\nSelect a type: ")
    local pet_type = io.read()
    if not pet_type then
        pet_type = "normal"
        print("No input provided, using 'normal' by default.")
    else
        pet_type = pet_type:gsub("%s+", "")
    end
    
    if not tamagotchi.types[pet_type] then
        pet_type = "normal"
        print("Invalid type, using 'normal' by default.")
    end
    
    local pet = tamagotchi.new(name, race, pet_type)
    
    if persistence.save_tamagotchi(pet) then
        persistence.set_active_pet(name)
        print(utils.colors.green .. "\n" .. name .. " has been born! It's now your active pet." .. utils.colors.reset)
        print(tamagotchi.get_status(pet))
    else
        print(utils.colors.red .. "Error saving the pet." .. utils.colors.reset)
    end
end

function cli.list_tamagotchis()
    local pets = persistence.get_pet_list()
    local active_pet = persistence.get_active_pet()
    
    if #pets == 0 then
        print(utils.colors.yellow .. "No pets found. Let's create your first one!" .. utils.colors.reset)
        print()
        print(utils.colors.magenta .. "CLI Tutorial: " .. utils.colors.reset .. utils.colors.bold .. "Creating resources" .. utils.colors.reset)
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Many CLI tools start empty and need initialization")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Use '" .. utils.colors.green .. "create" .. utils.colors.reset .. "' commands to add new resources")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Try: " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "create" .. utils.colors.reset)
        return
    end
    
    print(utils.colors.bold .. utils.colors.cyan .. "YOUR TAMAGOTCHI COLLECTION" .. utils.colors.reset)
    print(utils.colors.dim .. "Active pet marked with " .. utils.colors.reset .. utils.colors.yellow .. "[ACTIVE]" .. utils.colors.reset)
    print()
    
    for _, pet_name in ipairs(pets) do
        local pet = persistence.load_tamagotchi(pet_name)
        if pet then
            local status_icon = pet.is_alive and utils.colors.green .. "[ALIVE]" .. utils.colors.reset or utils.colors.red .. "[DEAD]" .. utils.colors.reset
            local active_marker = (pet_name == active_pet) and " " .. utils.colors.yellow .. "[ACTIVE]" .. utils.colors.reset or ""
            local stage_name = tamagotchi.evolution_stages[pet.stage].name
            
            print(string.format("%s %s%s - %s %s (%s%s%s, %s%d hours%s)", 
                               status_icon, 
                               utils.colors.bold .. pet_name .. utils.colors.reset, 
                               active_marker,
                               utils.colors.blue .. tamagotchi.races[pet.race].name .. utils.colors.reset,
                               utils.colors.magenta .. tamagotchi.types[pet.type].name .. utils.colors.reset,
                               utils.colors.cyan .. stage_name .. utils.colors.reset,
                               utils.colors.reset,
                               utils.colors.reset,
                               utils.colors.dim,
                               pet.age,
                               utils.colors.reset))
        end
    end
    
    print()
    print(utils.colors.magenta .. "CLI Tutorial: " .. utils.colors.reset .. utils.colors.bold .. "Working with lists" .. utils.colors.reset)
    print(utils.colors.cyan .. "•" .. utils.colors.reset .. " '" .. utils.colors.green .. "list" .. utils.colors.reset .. "' commands show available resources")
    print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Use '" .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "<name>" .. utils.colors.reset .. "' to choose which pet to work with")
    print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Similar to '" .. utils.colors.green .. "ls" .. utils.colors.reset .. "' in file systems or '" .. utils.colors.green .. "git branch" .. utils.colors.reset .. "' in Git")
    print()
    print(utils.colors.yellow .. "Next steps:" .. utils.colors.reset)
    print("  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "<name>" .. utils.colors.reset .. "  " .. utils.colors.dim .. "# Choose active pet" .. utils.colors.reset)
    print("  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "status" .. utils.colors.reset .. "         " .. utils.colors.dim .. "# Check pet condition" .. utils.colors.reset)
end

function cli.select_tamagotchi(name)
    if not name then
        print("Usage: tamagotchi-cli select <name>")
        return
    end
    
    local pet = persistence.load_tamagotchi(name)
    if not pet then
        print(utils.colors.red .. "Pet '" .. name .. "' not found." .. utils.colors.reset)
        return
    end
    
    persistence.set_active_pet(name)
    print(utils.colors.green .. name .. " is now your active pet." .. utils.colors.reset)
    print()
    print(tamagotchi.get_status(pet))
end

function cli.get_active_pet()
    local active_name = persistence.get_active_pet()
    if not active_name then
        print(utils.colors.yellow .. "No active pet selected" .. utils.colors.reset)
        print()
        print(utils.colors.magenta .. "CLI Tutorial: " .. utils.colors.reset .. utils.colors.bold .. "Working directory concept" .. utils.colors.reset)
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Many CLI tools have a 'current' or 'active' context")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Like '" .. utils.colors.green .. "pwd" .. utils.colors.reset .. "' shows current directory, you need an active pet")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Use '" .. utils.colors.green .. "list" .. utils.colors.reset .. "' to see available pets, then '" .. utils.colors.green .. "select" .. utils.colors.reset .. "' one")
        print()
        print(utils.colors.yellow .. "Try these commands:" .. utils.colors.reset)
        print("  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "list" .. utils.colors.reset .. "           " .. utils.colors.dim .. "# Show all pets" .. utils.colors.reset)
        print("  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "<name>" .. utils.colors.reset .. "  " .. utils.colors.dim .. "# Set active pet" .. utils.colors.reset)
        return nil
    end
    
    local pet = persistence.load_tamagotchi(active_name)
    if not pet then
        print(utils.colors.red .. "Error: Active pet data corrupted" .. utils.colors.reset)
        print(utils.colors.dim .. "Resetting active pet selection..." .. utils.colors.reset)
        persistence.set_active_pet("")
        return nil
    end
    
    return pet
end

function cli.show_status()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    print(tamagotchi.get_status(pet))
    
    if pet.is_alive then
        local can_evolve, next_stage = tamagotchi.can_evolve(pet)
        if can_evolve then
            print()
            print(utils.colors.yellow .. pet.name .. " can evolve to " .. 
                  tamagotchi.evolution_stages[next_stage].name .. "!" .. utils.colors.reset)
        end
    end
end

function cli.feed_tamagotchi()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = inventory.auto_feed(pet)
    if success then
        persistence.save_tamagotchi(pet)
        print(utils.colors.green .. message .. utils.colors.reset)
    else
        print(utils.colors.red .. message .. utils.colors.reset)
        print("Buy food with: tamagotchi-cli buy apple")
    end
end

function cli.play_with_tamagotchi()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = tamagotchi.play(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.sleep_tamagotchi()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = tamagotchi.sleep(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.clean_tamagotchi()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = tamagotchi.clean(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.evolve_tamagotchi()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = tamagotchi.evolve(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.work()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = economy.work(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.earn_from_commands()
    local success, message = economy.earn_from_commands()
    local color = success and utils.colors.green or utils.colors.yellow
    print(color .. message .. utils.colors.reset)
end

function cli.buy_item(item_name)
    if not item_name then
        print("Usage: tamagotchi-cli buy <item>")
        print("\nAvailable items:")
        print(economy.show_shop())
        return
    end
    
    local success, message = economy.buy_item(item_name)
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.use_item(item_name)
    if not item_name then
        print("Usage: tamagotchi-cli use <item>")
        return
    end
    
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = inventory.use_item(pet, item_name)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.breed_tamagotchis(father, mother, child)
    if not father or not mother or not child then
        print("Usage: tamagotchi-cli breed <father> <mother> <child>")
        return
    end
    
    local success, message = breeding.breed(father, mother, child)
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.show_family_tree(pet_name)
    if not pet_name then
        local pet = cli.get_active_pet()
        if pet then
            pet_name = pet.name
        else
            print("Usage: tamagotchi-cli family <name>")
            return
        end
    end
    
    local tree = breeding.get_family_tree(pet_name)
    print(tree)
end

function cli.show_compatibility(pet1, pet2)
    if not pet1 or not pet2 then
        print("Usage: tamagotchi-cli compatibility <pet1> <pet2>")
        return
    end
    
    local compatibility = breeding.get_breeding_compatibility(pet1, pet2)
    print(compatibility)
end

function cli.daily_bonus()
    local success, message = economy.daily_bonus()
    local color = success and utils.colors.green or utils.colors.yellow
    print(color .. message .. utils.colors.reset)
end

function cli.show_shop()
    print(economy.show_shop())
end

function cli.show_wallet()
    print(economy.get_wallet_status())
end

function cli.show_inventory()
    print(inventory.show_inventory())
end

function cli.auto_feed()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = inventory.auto_feed(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.auto_heal()
    local pet = cli.get_active_pet()
    if not pet then return end
    
    local success, message = inventory.auto_heal(pet)
    if success then
        persistence.save_tamagotchi(pet)
    end
    
    local color = success and utils.colors.green or utils.colors.red
    print(color .. message .. utils.colors.reset)
end

function cli.execute_command(command, params)
    cli.init()
    
    -- Educational command mapping
    local commands = {
        create = {func = cli.create_tamagotchi, desc = "Create a new virtual pet"},
        list = {func = cli.list_tamagotchis, desc = "Display all your pets"},
        select = {func = function() cli.select_tamagotchi(params[1]) end, desc = "Choose active pet"},
        status = {func = cli.show_status, desc = "Show active pet's condition"},
        feed = {func = cli.feed_tamagotchi, desc = "Give food to your pet"},
        play = {func = cli.play_with_tamagotchi, desc = "Play with your pet"},
        sleep = {func = cli.sleep_tamagotchi, desc = "Sleep/wake your pet"},
        clean = {func = cli.clean_tamagotchi, desc = "Clean your pet"},
        evolve = {func = cli.evolve_tamagotchi, desc = "Attempt pet evolution"},
        work = {func = cli.work, desc = "Work to earn coins"},
        earn = {func = cli.earn_from_commands, desc = "Earn from command history"},
        buy = {func = function() cli.buy_item(params[1]) end, desc = "Purchase shop items"},
        shop = {func = cli.show_shop, desc = "View shop inventory"},
        wallet = {func = cli.show_wallet, desc = "Check coin balance"},
        inventory = {func = cli.show_inventory, desc = "View your items"},
        use = {func = function() cli.use_item(params[1]) end, desc = "Use inventory item"},
        breed = {func = function() cli.breed_tamagotchis(params[1], params[2], params[3]) end, desc = "Breed two pets"},
        family = {func = function() cli.show_family_tree(params[1]) end, desc = "View family tree"},
        compatibility = {func = function() cli.show_compatibility(params[1], params[2]) end, desc = "Check breeding compatibility"},
        bonus = {func = cli.daily_bonus, desc = "Claim daily bonus"},
        autofeed = {func = cli.auto_feed, desc = "Automatically feed pet"},
        autoheal = {func = cli.auto_heal, desc = "Automatically heal pet"},
        help = {func = cli.show_help, desc = "Show help documentation"}
    }
    
    local cmd_info = commands[command]
    if cmd_info then
        print(utils.colors.blue .. "▶ " .. utils.colors.reset .. utils.colors.dim .. cmd_info.desc .. utils.colors.reset)
        cmd_info.func()
    else
        print(utils.colors.red .. "✗ Error: " .. utils.colors.reset .. "Unknown command '" .. utils.colors.bold .. command .. utils.colors.reset .. "'")
        print()
        print(utils.colors.magenta .. "CLI Tutorial Tip:" .. utils.colors.reset)
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Commands must be typed exactly as shown (case-sensitive)")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Use '" .. utils.colors.green .. "tamagotchi-cli help" .. utils.colors.reset .. "' to see all available commands")
        print(utils.colors.cyan .. "•" .. utils.colors.reset .. " Use '" .. utils.colors.magenta .. "tamagotchi-cli --help" .. utils.colors.reset .. "' for quick usage overview")
        print()
        print(utils.colors.yellow .. "Did you mean one of these?" .. utils.colors.reset)
        
        -- Suggest similar commands
        local suggestions = {}
        for cmd_name, _ in pairs(commands) do
            if cmd_name:find(command:sub(1,3)) or command:find(cmd_name:sub(1,3)) then
                table.insert(suggestions, cmd_name)
            end
        end
        
        if #suggestions > 0 then
            for _, suggestion in ipairs(suggestions) do
                print("  " .. utils.colors.green .. suggestion .. utils.colors.reset .. " - " .. utils.colors.dim .. commands[suggestion].desc .. utils.colors.reset)
            end
        else
            print("  " .. utils.colors.green .. "help" .. utils.colors.reset .. " - " .. utils.colors.dim .. commands.help.desc .. utils.colors.reset)
        end
    end
end

return cli