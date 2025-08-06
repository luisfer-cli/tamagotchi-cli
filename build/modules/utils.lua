local utils = {}

utils.colors = {
    red = '\27[31m',
    green = '\27[32m',
    yellow = '\27[33m',
    blue = '\27[34m',
    magenta = '\27[35m',
    cyan = '\27[36m',
    white = '\27[37m',
    reset = '\27[0m',
    bold = '\27[1m'
}

function utils.file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function utils.ensure_directory(path)
    os.execute("mkdir -p " .. path)
end

function utils.read_file(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

function utils.write_file(filename, content)
    utils.ensure_directory(filename:match("(.*/)[^/]*$") or ".")
    local file = io.open(filename, "w")
    if not file then
        return false
    end
    file:write(content)
    file:close()
    return true
end

function utils.serialize_table(t, indent)
    indent = indent or 0
    local result = "{\n"
    local prefix = string.rep("  ", indent + 1)
    
    for k, v in pairs(t) do
        result = result .. prefix
        if type(k) == "string" then
            result = result .. '["' .. k .. '"] = '
        else
            result = result .. "[" .. k .. "] = "
        end
        
        if type(v) == "table" then
            result = result .. utils.serialize_table(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        result = result .. ",\n"
    end
    
    result = result .. string.rep("  ", indent) .. "}"
    return result
end

function utils.deserialize_table(str)
    local func = load(str)
    if func then
        return func()
    end
    return nil
end

function utils.get_cpu_usage()
    local file = io.open("/proc/stat", "r")
    if not file then
        return 0
    end
    
    local line = file:read("*line")
    file:close()
    
    if not line then
        return 0
    end
    
    local user, nice, system, idle = line:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    if not user then
        return 0
    end
    
    local total = user + nice + system + idle
    local usage = ((total - idle) / total) * 100
    return math.floor(usage)
end

function utils.get_memory_usage()
    local file = io.open("/proc/meminfo", "r")
    if not file then
        return 50
    end
    
    local content = file:read("*all")
    file:close()
    
    local total = content:match("MemTotal:%s*(%d+)")
    local available = content:match("MemAvailable:%s*(%d+)")
    
    if not total or not available then
        return 50
    end
    
    local used_percent = ((total - available) / total) * 100
    return math.floor(used_percent)
end

function utils.get_system_impact()
    local cpu = utils.get_cpu_usage()
    local memory = utils.get_memory_usage()
    
    local health_impact = 0
    local happiness_impact = 0
    
    if cpu > 70 then
        health_impact = health_impact - 2
        happiness_impact = happiness_impact - 1
    end
    
    if memory > 80 then
        health_impact = health_impact - 1
    end
    
    return health_impact, happiness_impact
end

function utils.colorize_stat(value, max_value)
    local percentage = (value / max_value) * 100
    local color = utils.colors.green
    
    if percentage < 30 then
        color = utils.colors.red
    elseif percentage < 60 then
        color = utils.colors.yellow
    end
    
    return color .. value .. "/" .. max_value .. utils.colors.reset
end

function utils.get_timestamp()
    return os.time()
end

function utils.random_choice(list)
    if #list == 0 then
        return nil
    end
    return list[math.random(#list)]
end

function utils.clamp(value, min_val, max_val)
    return math.max(min_val, math.min(max_val, value))
end

return utils