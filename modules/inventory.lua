local utils = require('modules.utils')
local persistence = require('modules.persistence')

local inventory = {}

function inventory.get_inventory()
    return persistence.load_inventory()
end

function inventory.has_item(item_name, quantity)
    quantity = quantity or 1
    local inv = inventory.get_inventory()
    
    if not inv[item_name] then
        return false
    end
    
    return inv[item_name].quantity >= quantity
end

function inventory.use_item(pet, item_name, quantity)
    quantity = quantity or 1
    
    if not pet or not pet.is_alive then
        return false, "You need a living pet to use items."
    end
    
    local inv = inventory.get_inventory()
    
    if not inv[item_name] then
        return false, "You don't have '" .. item_name .. "' in your inventory."
    end
    
    if inv[item_name].quantity < quantity then
        return false, string.format("Not enough %s. You have %d, need %d.", 
                                   inv[item_name].name, inv[item_name].quantity, quantity)
    end
    
    local item = inv[item_name]
    local result_message = ""
    
    if item.type == "food" then
        pet.hunger = utils.clamp(pet.hunger - item.effect * quantity, 0, pet.max_hunger)
        pet.happiness = utils.clamp(pet.happiness + 3 * quantity, 0, pet.max_happiness)
        result_message = string.format("%s ate %dx %s and feels better!", 
                                     pet.name, quantity, item.name)
    
    elseif item.type == "medicine" then
        pet.health = utils.clamp(pet.health + item.effect * quantity, 0, pet.max_health)
        result_message = string.format("%s used %dx %s and recovered health!", 
                                     pet.name, quantity, item.name)
    
    elseif item.type == "toy" then
        if pet.energy < 10 then
            return false, pet.name .. " is too tired to play."
        end
        pet.happiness = utils.clamp(pet.happiness + item.effect * quantity, 0, pet.max_happiness)
        pet.energy = utils.clamp(pet.energy - 5 * quantity, 0, pet.max_energy)
        result_message = string.format("%s played with %dx %s and is happier!", 
                                     pet.name, quantity, item.name)
    
    elseif item.type == "cleaning" then
        pet.cleanliness = pet.max_cleanliness
        pet.happiness = utils.clamp(pet.happiness + 5 * quantity, 0, pet.max_happiness)
        result_message = string.format("%s was cleaned with %dx %s!", 
                                     pet.name, quantity, item.name)
    
    elseif item.type == "energy" then
        pet.energy = utils.clamp(pet.energy + item.effect * quantity, 0, pet.max_energy)
        result_message = string.format("%s used %dx %s and recovered energy!", 
                                     pet.name, quantity, item.name)
    
    elseif item.type == "enhancement" then
        pet.strength = pet.strength + item.effect * quantity
        pet.intelligence = pet.intelligence + item.effect * quantity
        pet.speed = pet.speed + item.effect * quantity
        result_message = string.format("%s used %dx %s and improved stats!", 
                                     pet.name, quantity, item.name)
    
    else
        return false, "Unknown item type: " .. item.type
    end
    
    item.quantity = item.quantity - quantity
    
    if item.quantity <= 0 then
        inv[item_name] = nil
    end
    
    persistence.save_inventory(inv)
    return true, result_message
end

function inventory.show_inventory()
    local inv = inventory.get_inventory()
    local lines = {
        utils.colors.bold .. "=== INVENTORY ===" .. utils.colors.reset,
        ""
    }
    
    local has_items = false
    for item_name, item in pairs(inv) do
        if item.quantity > 0 then
            has_items = true
            table.insert(lines, string.format("%s%s%s x%d", 
                                             utils.colors.green, item.name, utils.colors.reset, item.quantity))
            table.insert(lines, "  " .. item.description)
            table.insert(lines, "  Type: " .. item.type)
            table.insert(lines, "  Usage: lua tamagotchi.lua use " .. item_name)
            table.insert(lines, "")
        end
    end
    
    if not has_items then
        table.insert(lines, "Your inventory is empty.")
        table.insert(lines, "Buy items with: lua tamagotchi.lua buy <item>")
    end
    
    return table.concat(lines, "\n")
end

function inventory.add_item(item_name, item_data, quantity)
    quantity = quantity or 1
    local inv = inventory.get_inventory()
    
    if not inv[item_name] then
        inv[item_name] = {
            name = item_data.name,
            type = item_data.type,
            effect = item_data.effect,
            description = item_data.description,
            quantity = 0
        }
    end
    
    inv[item_name].quantity = inv[item_name].quantity + quantity
    return persistence.save_inventory(inv)
end

function inventory.remove_item(item_name, quantity)
    quantity = quantity or 1
    local inv = inventory.get_inventory()
    
    if not inv[item_name] then
        return false
    end
    
    inv[item_name].quantity = inv[item_name].quantity - quantity
    
    if inv[item_name].quantity <= 0 then
        inv[item_name] = nil
    end
    
    return persistence.save_inventory(inv)
end

function inventory.get_item_count(item_name)
    local inv = inventory.get_inventory()
    if inv[item_name] then
        return inv[item_name].quantity
    end
    return 0
end

function inventory.get_items_by_type(item_type)
    local inv = inventory.get_inventory()
    local items = {}
    
    for item_name, item in pairs(inv) do
        if item.type == item_type and item.quantity > 0 then
            items[item_name] = item
        end
    end
    
    return items
end

function inventory.auto_feed(pet)
    if not pet or not pet.is_alive then
        return false, "You need a living pet."
    end
    
    if pet.hunger < 50 then
        return false, pet.name .. " is not very hungry."
    end
    
    local food_items = inventory.get_items_by_type("food")
    local best_food = nil
    local best_efficiency = 0
    
    for item_name, item in pairs(food_items) do
        local efficiency = item.effect / (item.effect * 0.1 + 1)
        if efficiency > best_efficiency then
            best_food = item_name
            best_efficiency = efficiency
        end
    end
    
    if best_food then
        return inventory.use_item(pet, best_food, 1)
    else
        return false, "You don't have food in your inventory."
    end
end

function inventory.auto_heal(pet)
    if not pet or not pet.is_alive then
        return false, "You need a living pet."
    end
    
    if pet.health >= pet.max_health * 0.8 then
        return false, pet.name .. " is quite healthy."
    end
    
    local medicine_items = inventory.get_items_by_type("medicine")
    local best_medicine = nil
    
    for item_name, item in pairs(medicine_items) do
        if not best_medicine or item.effect > medicine_items[best_medicine].effect then
            best_medicine = item_name
        end
    end
    
    if best_medicine then
        return inventory.use_item(pet, best_medicine, 1)
    else
        return false, "You don't have medicine in your inventory."
    end
end

return inventory