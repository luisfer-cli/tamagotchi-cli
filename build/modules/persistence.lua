local utils = require('modules.utils')

local persistence = {}

-- Get the appropriate data directory
local function get_data_dir()
    local home = os.getenv("HOME")
    if not home then
        return "data/"  -- Fallback to current directory
    end
    
    -- Try XDG_DATA_HOME first, then fallback to ~/.local/share
    local xdg_data = os.getenv("XDG_DATA_HOME")
    local base_dir
    
    if xdg_data then
        base_dir = xdg_data .. "/tamagotchi-cli/"
    else
        base_dir = home .. "/.local/share/tamagotchi-cli/"
    end
    
    -- Test if we can create the directory
    local test_file = base_dir .. ".test"
    utils.ensure_directory(base_dir)
    
    -- Test write permissions
    local test_handle = io.open(test_file, "w")
    if test_handle then
        test_handle:close()
        os.remove(test_file)
        return base_dir
    else
        -- Fallback to current directory if XDG fails
        print("⚠️  Cannot write to " .. base_dir .. ", using current directory")
        return "data/"
    end
end

local DATA_DIR = get_data_dir()
local TAMAGOTCHI_DIR = DATA_DIR .. "tamagotchis/"
local WALLET_FILE = DATA_DIR .. "wallet.lua"
local INVENTORY_FILE = DATA_DIR .. "inventory.lua"
local ACTIVE_PET_FILE = DATA_DIR .. "active_pet.txt"
local PET_LIST_FILE = TAMAGOTCHI_DIR .. "lista.txt"

function persistence.init()
    utils.ensure_directory(DATA_DIR)
    utils.ensure_directory(TAMAGOTCHI_DIR)
    
    if not utils.file_exists(WALLET_FILE) then
        persistence.save_wallet(100)
    end
    
    if not utils.file_exists(INVENTORY_FILE) then
        persistence.save_inventory({})
    end
    
    if not utils.file_exists(PET_LIST_FILE) then
        utils.write_file(PET_LIST_FILE, "")
    end
end

function persistence.save_tamagotchi(pet)
    local filename = TAMAGOTCHI_DIR .. pet.name .. ".lua"
    local content = "return " .. utils.serialize_table(pet)
    local success = utils.write_file(filename, content)
    
    if success then
        persistence.update_pet_list(pet.name)
    end
    
    return success
end

function persistence.load_tamagotchi(name)
    local filename = TAMAGOTCHI_DIR .. name .. ".lua"
    if not utils.file_exists(filename) then
        return nil
    end
    
    local content = utils.read_file(filename)
    if not content then
        return nil
    end
    
    return utils.deserialize_table(content)
end

function persistence.delete_tamagotchi(name)
    local filename = TAMAGOTCHI_DIR .. name .. ".lua"
    os.remove(filename)
    persistence.remove_from_pet_list(name)
end

function persistence.get_pet_list()
    local content = utils.read_file(PET_LIST_FILE)
    if not content or content == "" then
        return {}
    end
    
    local pets = {}
    for line in content:gmatch("[^\r\n]+") do
        local trimmed_line = line:gsub("^%s*(.-)%s*$", "%1")
        if trimmed_line ~= "" then
            table.insert(pets, trimmed_line)
        end
    end
    
    return pets
end

function persistence.update_pet_list(name)
    local pets = persistence.get_pet_list()
    local exists = false
    
    for _, pet_name in ipairs(pets) do
        if pet_name == name then
            exists = true
            break
        end
    end
    
    if not exists then
        table.insert(pets, name)
        local content = table.concat(pets, "\n")
        utils.write_file(PET_LIST_FILE, content)
    end
end

function persistence.remove_from_pet_list(name)
    local pets = persistence.get_pet_list()
    local new_pets = {}
    
    for _, pet_name in ipairs(pets) do
        if pet_name ~= name then
            table.insert(new_pets, pet_name)
        end
    end
    
    local content = table.concat(new_pets, "\n")
    utils.write_file(PET_LIST_FILE, content)
end

function persistence.save_wallet(coins)
    local content = "return " .. tostring(coins)
    return utils.write_file(WALLET_FILE, content)
end

function persistence.load_wallet()
    if not utils.file_exists(WALLET_FILE) then
        return 100
    end
    
    local content = utils.read_file(WALLET_FILE)
    if not content then
        return 100
    end
    
    local coins = utils.deserialize_table(content)
    return coins or 100
end

function persistence.save_inventory(inventory)
    local content = "return " .. utils.serialize_table(inventory)
    return utils.write_file(INVENTORY_FILE, content)
end

function persistence.load_inventory()
    if not utils.file_exists(INVENTORY_FILE) then
        return {}
    end
    
    local content = utils.read_file(INVENTORY_FILE)
    if not content then
        return {}
    end
    
    return utils.deserialize_table(content) or {}
end

function persistence.set_active_pet(name)
    return utils.write_file(ACTIVE_PET_FILE, name)
end

function persistence.get_active_pet()
    if not utils.file_exists(ACTIVE_PET_FILE) then
        return nil
    end
    
    local content = utils.read_file(ACTIVE_PET_FILE)
    if content then
        return content:gsub("%s+", "")
    end
    return nil
end

function persistence.get_command_history()
    local history_files = {
        os.getenv("HOME") .. "/.bash_history",
        os.getenv("HOME") .. "/.zsh_history"
    }
    
    local commands = {}
    local last_check_file = DATA_DIR .. "last_history_check.txt"
    local last_check = 0
    
    if utils.file_exists(last_check_file) then
        local content = utils.read_file(last_check_file)
        last_check = tonumber(content) or 0
    end
    
    for _, history_file in ipairs(history_files) do
        if utils.file_exists(history_file) then
            local content = utils.read_file(history_file)
            if content then
                local current_time = utils.get_timestamp()
                for line in content:gmatch("[^\r\n]+") do
                    if line and line ~= "" and not line:match("^%s*$") then
                        table.insert(commands, line)
                    end
                end
                
                utils.write_file(last_check_file, tostring(current_time))
            end
        end
    end
    
    return commands, last_check
end

function persistence.backup_save(pet)
    local backup_dir = DATA_DIR .. "backups/"
    utils.ensure_directory(backup_dir)
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backup_file = backup_dir .. pet.name .. "_" .. timestamp .. ".lua"
    
    local content = "return " .. utils.serialize_table(pet)
    return utils.write_file(backup_file, content)
end

-- Function to get current data directory (useful for debugging)
function persistence.get_data_dir()
    return DATA_DIR
end

return persistence