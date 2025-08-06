#!/usr/bin/env lua

local cli = require('modules.cli')

local function main(args)
    if #args == 0 then
        cli.show_help()
        return
    end
    
    local command = args[1]
    local params = {}
    for i = 2, #args do
        table.insert(params, args[i])
    end
    
    cli.execute_command(command, params)
end

main(arg)