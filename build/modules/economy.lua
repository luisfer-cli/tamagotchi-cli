local utils = require('modules.utils')
local persistence = require('modules.persistence')

local economy = {}

economy.work_jobs = {
    {name = "Programming", reward = {min = 15, max = 25}, energy_cost = 20},
    {name = "Teaching", reward = {min = 10, max = 20}, energy_cost = 15},
    {name = "Building", reward = {min = 20, max = 35}, energy_cost = 30},
    {name = "Cooking", reward = {min = 8, max = 15}, energy_cost = 10},
    {name = "Research", reward = {min = 12, max = 22}, energy_cost = 18}
}

economy.shop_items = {
    apple = {name = "Apple", price = 5, type = "food", effect = 15, description = "A fresh apple that reduces hunger"},
    meat = {name = "Meat", price = 12, type = "food", effect = 30, description = "Nutritious meat that satisfies a lot"},
    medicine = {name = "Medicine", price = 25, type = "medicine", effect = 40, description = "Medicine that restores health"},
    toy = {name = "Toy", price = 18, type = "toy", effect = 20, description = "A fun toy that increases happiness"},
    soap = {name = "Soap", price = 8, type = "cleaning", effect = 100, description = "Soap for complete cleaning"},
    vitamins = {name = "Vitamins", price = 35, type = "enhancement", effect = 5, description = "Vitamins that improve statistics"},
    energy_drink = {name = "Energy Drink", price = 15, type = "energy", effect = 40, description = "Drink that restores energy"}
}

function economy.work(pet)
    if not pet or not pet.is_alive then
        return false, "You need a living pet to work."
    end
    
    if pet.energy < 15 then
        return false, pet.name .. " is too tired to work."
    end
    
    local job = utils.random_choice(economy.work_jobs)
    local reward = math.random(job.reward.min, job.reward.max)
    
    pet.energy = utils.clamp(pet.energy - job.energy_cost, 0, pet.max_energy)
    pet.hunger = utils.clamp(pet.hunger + 10, 0, pet.max_hunger)
    
    local current_coins = persistence.load_wallet()
    persistence.save_wallet(current_coins + reward)
    
    return true, string.format("%s worked as %s and earned %d coins!", 
                              pet.name, job.name, reward)
end

function economy.earn_from_commands()
    -- Get commands that are new since last earn
    local new_commands_list = persistence.get_new_commands_since_last_earn()
    local new_commands = 0
    local unique_commands = {}
    
    -- Count unique new commands
    for _, command in ipairs(new_commands_list) do
        local base_command = command:match("^(%S+)")
        if base_command and not unique_commands[base_command] then
            unique_commands[base_command] = true
            new_commands = new_commands + 1
        end
    end
    
    local reward = math.min(new_commands * 2, 50)
    
    if reward > 0 then
        local current_coins = persistence.load_wallet()
        persistence.save_wallet(current_coins + reward)
        -- Record when we last earned
        local data_dir = persistence.get_data_dir()
        local last_earn_file = data_dir .. "last_earn.txt"
        utils.write_file(last_earn_file, tostring(utils.get_timestamp()))
        return true, string.format("You earned %d coins for using %d new unique system commands!", 
                                  reward, new_commands)
    else
        return false, "No new commands found since last earn."
    end
end

function economy.buy_item(item_name, quantity)
    quantity = quantity or 1
    
    if not economy.shop_items[item_name] then
        return false, "Item '" .. item_name .. "' doesn't exist in the shop."
    end
    
    local item = economy.shop_items[item_name]
    local total_cost = item.price * quantity
    local current_coins = persistence.load_wallet()
    
    if current_coins < total_cost then
        return false, string.format("Not enough coins. Need %d, have %d.", 
                                   total_cost, current_coins)
    end
    
    local inventory = persistence.load_inventory()
    
    if not inventory[item_name] then
        inventory[item_name] = {
            name = item.name,
            type = item.type,
            effect = item.effect,
            description = item.description,
            quantity = 0
        }
    end
    
    inventory[item_name].quantity = inventory[item_name].quantity + quantity
    
    persistence.save_wallet(current_coins - total_cost)
    persistence.save_inventory(inventory)
    
    return true, string.format("Bought %dx %s for %d coins.", 
                              quantity, item.name, total_cost)
end

function economy.get_wallet_status()
    local coins = persistence.load_wallet()
    return string.format("%sCoins: %s%d%s", 
                        utils.colors.yellow, utils.colors.bold, coins, utils.colors.reset)
end

function economy.show_shop()
    local lines = {
        utils.colors.bold .. "=== SHOP ===" .. utils.colors.reset,
        ""
    }
    
    for item_id, item in pairs(economy.shop_items) do
        table.insert(lines, string.format("%s%s%s - %d coins", 
                                         utils.colors.cyan, item.name, utils.colors.reset, item.price))
        table.insert(lines, "  " .. item.description)
        table.insert(lines, "  Usage: tamagotchi-cli buy " .. item_id)
        table.insert(lines, "")
    end
    
    local coins = persistence.load_wallet()
    table.insert(lines, economy.get_wallet_status())
    
    return table.concat(lines, "\n")
end

function economy.calculate_breeding_cost(parent1, parent2)
    local base_cost = 50
    local stage_multiplier = {baby = 1, child = 1.2, adult = 1.5, elder = 2}
    
    local multiplier1 = stage_multiplier[parent1.stage] or 1
    local multiplier2 = stage_multiplier[parent2.stage] or 1
    
    return math.floor(base_cost * (multiplier1 + multiplier2) / 2)
end

function economy.pay_breeding_cost(cost)
    local current_coins = persistence.load_wallet()
    
    if current_coins < cost then
        return false, string.format("Not enough coins for breeding. Need %d, have %d.", 
                                   cost, current_coins)
    end
    
    persistence.save_wallet(current_coins - cost)
    return true, string.format("Paid %d coins for breeding.", cost)
end

function economy.daily_bonus()
    local bonus_file = "data/last_bonus.txt"
    local today = os.date("%Y-%m-%d")
    
    if utils.file_exists(bonus_file) then
        local last_bonus = utils.read_file(bonus_file)
        if last_bonus and last_bonus:gsub("%s+", "") == today then
            return false, "You already received your daily bonus today."
        end
    end
    
    local bonus = math.random(10, 30)
    local current_coins = persistence.load_wallet()
    persistence.save_wallet(current_coins + bonus)
    utils.write_file(bonus_file, today)
    
    return true, string.format("Daily bonus! You received %d coins.", bonus)
end

return economy