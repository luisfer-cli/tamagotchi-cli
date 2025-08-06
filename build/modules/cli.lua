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
        utils.colors.bold .. "=== TAMAGOTCHI CLI - HELP ===" .. utils.colors.reset,
        "",
        utils.colors.cyan .. "BASIC COMMANDS:" .. utils.colors.reset,
        "  create                     - Create new tamagotchi",
        "  list                       - View all tamagotchis",
        "  select <name>              - Select tamagotchi to play with",
        "  status                     - View active tamagotchi status",
        "",
        utils.colors.cyan .. "CARE:" .. utils.colors.reset,
        "  feed                       - Feed tamagotchi",
        "  play                       - Play with tamagotchi",
        "  sleep                      - Sleep/wake tamagotchi",
        "  clean                      - Clean tamagotchi",
        "  evolve                     - Attempt evolution",
        "",
        utils.colors.cyan .. "ECONOMY:" .. utils.colors.reset,
        "  work                       - Work to earn coins",
        "  earn                       - Earn coins from command history",
        "  buy <item>                 - Buy items",
        "  shop                       - View shop",
        "  wallet                     - View coins",
        "",
        utils.colors.cyan .. "INVENTORY:" .. utils.colors.reset,
        "  inventory                  - View inventory",
        "  use <item>                 - Use item from inventory",
        "  autofeed                   - Feed automatically",
        "  autoheal                   - Heal automatically",
        "",
        utils.colors.cyan .. "BREEDING:" .. utils.colors.reset,
        "  breed <father> <mother> <child> - Breed two tamagotchis",
        "  family <name>              - View family tree",
        "  compatibility <pet1> <pet2> - View breeding compatibility",
        "",
        utils.colors.cyan .. "OTHER:" .. utils.colors.reset,
        "  help                       - Show this help",
        "  bonus                      - Receive daily bonus",
        "",
        utils.colors.yellow .. "Example: tamagotchi-cli create" .. utils.colors.reset
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
        print("You have no pets. Create one with: tamagotchi-cli create")
        return
    end
    
    print(utils.colors.bold .. "=== YOUR TAMAGOTCHIS ===" .. utils.colors.reset)
    print()
    
    for _, pet_name in ipairs(pets) do
        local pet = persistence.load_tamagotchi(pet_name)
        if pet then
            local status_icon = pet.is_alive and "[ALIVE]" or "[DEAD]"
            local active_marker = (pet_name == active_pet) and " *" or ""
            local stage_name = tamagotchi.evolution_stages[pet.stage].name
            
            print(string.format("%s %s%s - %s %s (%s, %d hours)%s", 
                               status_icon, pet_name, active_marker,
                               tamagotchi.races[pet.race].name,
                               tamagotchi.types[pet.type].name,
                               stage_name, pet.age,
                               active_marker ~= "" and " [ACTIVE]" or ""))
        end
    end
    
    print()
    print("* = Active pet")
    print("Select a pet with: tamagotchi-cli select <name>")
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
        print("You don't have an active pet. Select one with: tamagotchi-cli select <name>")
        return nil
    end
    
    local pet = persistence.load_tamagotchi(active_name)
    if not pet then
        print("Error: active pet does not exist.")
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
    
    if command == "create" then
        cli.create_tamagotchi()
    elseif command == "list" then
        cli.list_tamagotchis()
    elseif command == "select" then
        cli.select_tamagotchi(params[1])
    elseif command == "status" then
        cli.show_status()
    elseif command == "feed" then
        cli.feed_tamagotchi()
    elseif command == "play" then
        cli.play_with_tamagotchi()
    elseif command == "sleep" then
        cli.sleep_tamagotchi()
    elseif command == "clean" then
        cli.clean_tamagotchi()
    elseif command == "evolve" then
        cli.evolve_tamagotchi()
    elseif command == "work" then
        cli.work()
    elseif command == "earn" then
        cli.earn_from_commands()
    elseif command == "buy" then
        cli.buy_item(params[1])
    elseif command == "shop" then
        cli.show_shop()
    elseif command == "wallet" then
        cli.show_wallet()
    elseif command == "inventory" then
        cli.show_inventory()
    elseif command == "use" then
        cli.use_item(params[1])
    elseif command == "breed" then
        cli.breed_tamagotchis(params[1], params[2], params[3])
    elseif command == "family" then
        cli.show_family_tree(params[1])
    elseif command == "compatibility" then
        cli.show_compatibility(params[1], params[2])
    elseif command == "bonus" then
        cli.daily_bonus()
    elseif command == "autofeed" then
        cli.auto_feed()
    elseif command == "autoheal" then
        cli.auto_heal()
    elseif command == "help" then
        cli.show_help()
    else
        print(utils.colors.red .. "Unknown command: " .. command .. utils.colors.reset)
        print("Use 'tamagotchi-cli help' to see all commands.")
    end
end

return cli