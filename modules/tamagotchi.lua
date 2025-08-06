local utils = require('modules.utils')

local tamagotchi = {}

tamagotchi.races = {
    dog = { name = "Dog", health = 80, happiness = 70, energy = 60, strength = 8, intelligence = 6, speed = 7 },
    cat = { name = "Cat", health = 70, happiness = 80, energy = 70, strength = 6, intelligence = 8, speed = 9 },
    bird = { name = "Bird", health = 60, happiness = 75, energy = 80, strength = 4, intelligence = 9, speed = 10 },
    fish = { name = "Fish", health = 50, happiness = 60, energy = 50, strength = 3, intelligence = 7, speed = 8 },
    dragon = { name = "Dragon", health = 100, happiness = 50, energy = 90, strength = 10, intelligence = 10, speed = 6 }
}

tamagotchi.types = {
    normal = { name = "Normal", modifier = 1.0 },
    fire = { name = "Fire", modifier = 1.2 },
    water = { name = "Water", modifier = 1.1 },
    earth = { name = "Earth", modifier = 1.15 },
    air = { name = "Air", modifier = 1.25 }
}

tamagotchi.evolution_stages = {
    baby = { name = "Baby", age_requirement = 0, happiness_requirement = 0 },
    child = { name = "Child", age_requirement = 7, happiness_requirement = 50 },
    adult = { name = "Adult", age_requirement = 30, happiness_requirement = 70 },
    elder = { name = "Elder", age_requirement = 100, happiness_requirement = 60 }
}

function tamagotchi.new(name, race, type_name)
    if not tamagotchi.races[race] then
        race = "dog"
    end
    if not tamagotchi.types[type_name] then
        type_name = "normal"
    end
    
    local base_stats = tamagotchi.races[race]
    local type_modifier = tamagotchi.types[type_name].modifier
    
    local pet = {
        name = name,
        race = race,
        type = type_name,
        age = 0,
        stage = "baby",
        
        health = math.floor(base_stats.health * type_modifier),
        max_health = math.floor(base_stats.health * type_modifier),
        happiness = math.floor(base_stats.happiness * type_modifier),
        max_happiness = 100,
        energy = math.floor(base_stats.energy * type_modifier),
        max_energy = 100,
        hunger = 0,
        max_hunger = 100,
        cleanliness = 100,
        max_cleanliness = 100,
        
        strength = math.floor(base_stats.strength * type_modifier),
        intelligence = math.floor(base_stats.intelligence * type_modifier),
        speed = math.floor(base_stats.speed * type_modifier),
        
        birth_time = utils.get_timestamp(),
        last_update = utils.get_timestamp(),
        
        is_alive = true,
        is_sleeping = false
    }
    
    return pet
end

function tamagotchi.update_time_effects(pet)
    local current_time = utils.get_timestamp()
    local time_passed = current_time - pet.last_update
    local hours_passed = math.floor(time_passed / 3600)
    
    if hours_passed > 0 then
        pet.age = pet.age + hours_passed
        pet.hunger = utils.clamp(pet.hunger + hours_passed * 2, 0, pet.max_hunger)
        pet.cleanliness = utils.clamp(pet.cleanliness - hours_passed, 0, pet.max_cleanliness)
        
        if not pet.is_sleeping then
            pet.energy = utils.clamp(pet.energy - hours_passed, 0, pet.max_energy)
        else
            pet.energy = utils.clamp(pet.energy + hours_passed * 3, 0, pet.max_energy)
        end
        
        if pet.hunger > 80 then
            pet.health = utils.clamp(pet.health - 1, 0, pet.max_health)
            pet.happiness = utils.clamp(pet.happiness - 2, 0, pet.max_happiness)
        end
        
        if pet.cleanliness < 20 then
            pet.health = utils.clamp(pet.health - 1, 0, pet.max_health)
        end
        
        pet.last_update = current_time
    end
    
    local health_impact, happiness_impact = utils.get_system_impact()
    pet.health = utils.clamp(pet.health + health_impact, 0, pet.max_health)
    pet.happiness = utils.clamp(pet.happiness + happiness_impact, 0, pet.max_happiness)
    
    if pet.health <= 0 then
        pet.is_alive = false
    end
end

function tamagotchi.feed(pet, food_effectiveness)
    if not pet.is_alive then
        return false, "Your pet is dead!"
    end
    
    food_effectiveness = food_effectiveness or 20
    pet.hunger = utils.clamp(pet.hunger - food_effectiveness, 0, pet.max_hunger)
    pet.happiness = utils.clamp(pet.happiness + 5, 0, pet.max_happiness)
    
    tamagotchi.update_time_effects(pet)
    return true, pet.name .. " has been fed!"
end

function tamagotchi.play(pet)
    if not pet.is_alive then
        return false, "Your pet is dead!"
    end
    
    if pet.energy < 20 then
        return false, pet.name .. " is too tired to play."
    end
    
    pet.energy = utils.clamp(pet.energy - 15, 0, pet.max_energy)
    pet.happiness = utils.clamp(pet.happiness + 15, 0, pet.max_happiness)
    pet.hunger = utils.clamp(pet.hunger + 5, 0, pet.max_hunger)
    
    tamagotchi.update_time_effects(pet)
    return true, "You played with " .. pet.name .. "!"
end

function tamagotchi.sleep(pet)
    if not pet.is_alive then
        return false, "Your pet is dead!"
    end
    
    pet.is_sleeping = not pet.is_sleeping
    local message = pet.is_sleeping and pet.name .. " is sleeping..." or pet.name .. " woke up."
    
    if pet.is_sleeping then
        pet.energy = utils.clamp(pet.energy + 10, 0, pet.max_energy)
    end
    
    tamagotchi.update_time_effects(pet)
    return true, message
end

function tamagotchi.clean(pet)
    if not pet.is_alive then
        return false, "Your pet is dead!"
    end
    
    pet.cleanliness = pet.max_cleanliness
    pet.happiness = utils.clamp(pet.happiness + 8, 0, pet.max_happiness)
    
    tamagotchi.update_time_effects(pet)
    return true, pet.name .. " is now clean and shiny!"
end

function tamagotchi.get_status(pet)
    tamagotchi.update_time_effects(pet)
    
    local status = {
        utils.colors.bold .. "=== " .. pet.name .. " ===" .. utils.colors.reset,
        "Race: " .. tamagotchi.races[pet.race].name .. " (" .. tamagotchi.types[pet.type].name .. ")",
        "Age: " .. pet.age .. " hours (" .. tamagotchi.evolution_stages[pet.stage].name .. ")",
        "Status: " .. (pet.is_alive and (pet.is_sleeping and "Sleeping" or "Awake") or utils.colors.red .. "Dead" .. utils.colors.reset),
        "",
        "Health: " .. utils.colorize_stat(pet.health, pet.max_health),
        "Happiness: " .. utils.colorize_stat(pet.happiness, pet.max_happiness),
        "Energy: " .. utils.colorize_stat(pet.energy, pet.max_energy),
        "Hunger: " .. utils.colorize_stat(pet.max_hunger - pet.hunger, pet.max_hunger),
        "Cleanliness: " .. utils.colorize_stat(pet.cleanliness, pet.max_cleanliness),
        "",
        "Strength: " .. pet.strength,
        "Intelligence: " .. pet.intelligence,
        "Speed: " .. pet.speed
    }
    
    return table.concat(status, "\n")
end

function tamagotchi.can_evolve(pet)
    for stage, requirements in pairs(tamagotchi.evolution_stages) do
        if pet.age >= requirements.age_requirement and 
           pet.happiness >= requirements.happiness_requirement and
           stage ~= pet.stage then
            local stage_order = { "baby", "child", "adult", "elder" }
            local current_index = 1
            local target_index = 1
            
            for i, s in ipairs(stage_order) do
                if s == pet.stage then current_index = i end
                if s == stage then target_index = i end
            end
            
            if target_index == current_index + 1 then
                return true, stage
            end
        end
    end
    return false, nil
end

function tamagotchi.evolve(pet)
    if not pet.is_alive then
        return false, "Your pet is dead!"
    end
    
    local can_evolve, new_stage = tamagotchi.can_evolve(pet)
    if not can_evolve then
        return false, pet.name .. " cannot evolve yet."
    end
    
    pet.stage = new_stage
    pet.max_health = pet.max_health + 10
    pet.health = pet.max_health
    pet.strength = pet.strength + 2
    pet.intelligence = pet.intelligence + 2
    pet.speed = pet.speed + 1
    
    return true, pet.name .. " evolved to " .. tamagotchi.evolution_stages[new_stage].name .. "!"
end

return tamagotchi