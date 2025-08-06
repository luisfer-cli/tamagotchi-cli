local utils = require('modules.utils')
local tamagotchi = require('modules.tamagotchi')
local persistence = require('modules.persistence')
local economy = require('modules.economy')

local breeding = {}

function breeding.can_breed(parent1, parent2)
    if not parent1 or not parent2 then
        return false, "Both parents must exist."
    end
    
    if not parent1.is_alive or not parent2.is_alive then
        return false, "Both parents must be alive."
    end
    
    if parent1.name == parent2.name then
        return false, "A pet cannot breed with itself."
    end
    
    if parent1.stage == "baby" or parent2.stage == "baby" then
        return false, "Baby pets cannot breed."
    end
    
    if parent1.happiness < 60 or parent2.happiness < 60 then
        return false, "Both parents must have at least 60 happiness."
    end
    
    if parent1.health < 50 or parent2.health < 50 then
        return false, "Both parents must have at least 50 health."
    end
    
    return true, "Parents can breed."
end

function breeding.get_inherited_race(parent1, parent2)
    local races = {parent1.race, parent2.race}
    
    local mutation_chance = 0.05
    if math.random() < mutation_chance then
        local all_races = {}
        for race, _ in pairs(tamagotchi.races) do
            table.insert(all_races, race)
        end
        return utils.random_choice(all_races)
    end
    
    if parent1.race == parent2.race then
        return parent1.race
    end
    
    return utils.random_choice(races)
end

function breeding.get_inherited_type(parent1, parent2)
    local types = {parent1.type, parent2.type}
    
    local mutation_chance = 0.1
    if math.random() < mutation_chance then
        local all_types = {}
        for type_name, _ in pairs(tamagotchi.types) do
            table.insert(all_types, type_name)
        end
        return utils.random_choice(all_types)
    end
    
    if parent1.type == parent2.type then
        return parent1.type
    end
    
    return utils.random_choice(types)
end

function breeding.calculate_inherited_stats(parent1, parent2, race, type_name)
    local base_stats = tamagotchi.races[race]
    local type_modifier = tamagotchi.types[type_name].modifier
    
    local inherited_stats = {}
    
    inherited_stats.strength = math.floor((parent1.strength + parent2.strength) / 2)
    inherited_stats.intelligence = math.floor((parent1.intelligence + parent2.intelligence) / 2)
    inherited_stats.speed = math.floor((parent1.speed + parent2.speed) / 2)
    
    local mutation_chance = 0.15
    for stat, value in pairs(inherited_stats) do
        if math.random() < mutation_chance then
            local variation = math.random(-2, 3)
            inherited_stats[stat] = math.max(1, value + variation)
        end
    end
    
    local health_bonus = math.floor((parent1.max_health + parent2.max_health) / 4)
    inherited_stats.max_health = math.floor(base_stats.health * type_modifier) + health_bonus
    
    return inherited_stats
end

function breeding.breed(parent1_name, parent2_name, child_name)
    local parent1 = persistence.load_tamagotchi(parent1_name)
    local parent2 = persistence.load_tamagotchi(parent2_name)
    
    if not parent1 then
        return false, "Pet '" .. parent1_name .. "' not found."
    end
    
    if not parent2 then
        return false, "Pet '" .. parent2_name .. "' not found."
    end
    
    local can_breed, reason = breeding.can_breed(parent1, parent2)
    if not can_breed then
        return false, reason
    end
    
    if persistence.load_tamagotchi(child_name) then
        return false, "A pet with the name '" .. child_name .. "' already exists."
    end
    
    local breeding_cost = economy.calculate_breeding_cost(parent1, parent2)
    local payment_success, payment_message = economy.pay_breeding_cost(breeding_cost)
    if not payment_success then
        return false, payment_message
    end
    
    local child_race = breeding.get_inherited_race(parent1, parent2)
    local child_type = breeding.get_inherited_type(parent1, parent2)
    
    local child = tamagotchi.new(child_name, child_race, child_type)
    
    local inherited_stats = breeding.calculate_inherited_stats(parent1, parent2, child_race, child_type)
    
    child.strength = inherited_stats.strength
    child.intelligence = inherited_stats.intelligence
    child.speed = inherited_stats.speed
    child.max_health = inherited_stats.max_health
    child.health = child.max_health
    
    child.parents = {
        father = parent1_name,
        mother = parent2_name
    }
    
    parent1.energy = utils.clamp(parent1.energy - 30, 0, parent1.max_energy)
    parent2.energy = utils.clamp(parent2.energy - 30, 0, parent2.max_energy)
    parent1.happiness = utils.clamp(parent1.happiness + 20, 0, parent1.max_happiness)
    parent2.happiness = utils.clamp(parent2.happiness + 20, 0, parent2.max_happiness)
    
    persistence.save_tamagotchi(parent1)
    persistence.save_tamagotchi(parent2)
    persistence.save_tamagotchi(child)
    
    local result_lines = {
        string.format("%s and %s had a baby!", parent1_name, parent2_name),
        string.format("%s was born (%s %s)", child_name, 
                     tamagotchi.races[child_race].name, 
                     tamagotchi.types[child_type].name),
        string.format("Inherited stats:"),
        string.format("  Strength: %d", child.strength),
        string.format("  Intelligence: %d", child.intelligence),
        string.format("  Speed: %d", child.speed),
        string.format("  Max Health: %d", child.max_health),
        payment_message
    }
    
    return true, table.concat(result_lines, "\n")
end

function breeding.get_family_tree(pet_name)
    local pet = persistence.load_tamagotchi(pet_name)
    if not pet then
        return nil, "Pet not found."
    end
    
    local tree_lines = {
        utils.colors.bold .. "=== " .. pet.name:upper() .. "'S FAMILY TREE ===" .. utils.colors.reset,
        ""
    }
    
    if pet.parents then
        table.insert(tree_lines, string.format("Father: %s", pet.parents.father))
        table.insert(tree_lines, string.format("Mother: %s", pet.parents.mother))
        
        local father = persistence.load_tamagotchi(pet.parents.father)
        local mother = persistence.load_tamagotchi(pet.parents.mother)
        
        if father and father.parents then
            table.insert(tree_lines, "")
            table.insert(tree_lines, "Paternal grandparents:")
            table.insert(tree_lines, string.format("  Grandfather: %s", father.parents.father))
            table.insert(tree_lines, string.format("  Grandmother: %s", father.parents.mother))
        end
        
        if mother and mother.parents then
            table.insert(tree_lines, "")
            table.insert(tree_lines, "Maternal grandparents:")
            table.insert(tree_lines, string.format("  Grandfather: %s", mother.parents.father))
            table.insert(tree_lines, string.format("  Grandmother: %s", mother.parents.mother))
        end
    else
        table.insert(tree_lines, pet.name .. " is first generation (no known parents)")
    end
    
    local children = breeding.get_children(pet_name)
    if #children > 0 then
        table.insert(tree_lines, "")
        table.insert(tree_lines, "Children:")
        for _, child in ipairs(children) do
            table.insert(tree_lines, string.format("  %s", child))
        end
    end
    
    return table.concat(tree_lines, "\n")
end

function breeding.get_children(parent_name)
    local pet_list = persistence.get_pet_list()
    local children = {}
    
    for _, pet_name in ipairs(pet_list) do
        local pet = persistence.load_tamagotchi(pet_name)
        if pet and pet.parents then
            if pet.parents.father == parent_name or pet.parents.mother == parent_name then
                table.insert(children, pet_name)
            end
        end
    end
    
    return children
end

function breeding.get_breeding_compatibility(pet1_name, pet2_name)
    local pet1 = persistence.load_tamagotchi(pet1_name)
    local pet2 = persistence.load_tamagotchi(pet2_name)
    
    if not pet1 or not pet2 then
        return "One or both pets do not exist."
    end
    
    local can_breed, reason = breeding.can_breed(pet1, pet2)
    if not can_breed then
        return "Incompatible: " .. reason
    end
    
    local race_compatibility = "Different"
    if pet1.race == pet2.race then
        race_compatibility = "Same race"
    end
    
    local type_compatibility = "Different"
    if pet1.type == pet2.type then
        type_compatibility = "Same type"
    end
    
    local cost = economy.calculate_breeding_cost(pet1, pet2)
    
    local compatibility_lines = {
        string.format("Compatibility between %s and %s:", pet1_name, pet2_name),
        string.format("  Status: Compatible"),
        string.format("  Race: %s", race_compatibility),
        string.format("  Type: %s", type_compatibility),
        string.format("  Breeding cost: %d coins", cost),
        "",
        "Possible results:",
        string.format("  Possible races: %s, %s", pet1.race, pet2.race),
        string.format("  Possible types: %s, %s", pet1.type, pet2.type),
        "  Small chance of mutation"
    }
    
    return table.concat(compatibility_lines, "\n")
end

return breeding