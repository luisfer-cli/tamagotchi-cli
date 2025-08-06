#!/usr/bin/env lua

local cli = require('modules.cli')
local utils = require('modules.utils')

local VERSION = "1.0.0"

local function show_version()
    print(utils.colors.cyan .. "Tamagotchi CLI " .. utils.colors.bold .. "v" .. VERSION .. utils.colors.reset)
    print(utils.colors.dim .. "A command-line virtual pet game for learning terminal usage" .. utils.colors.reset)
    print(utils.colors.blue .. "Repository: " .. utils.colors.reset .. "https://github.com/luisfer-cli/tamagotchi-cli")
end

local function show_usage()
    local usage_text = {
        utils.colors.bold .. utils.colors.cyan .. "Usage: " .. utils.colors.reset .. "tamagotchi-cli [COMMAND] [OPTIONS]",
        "",
        utils.colors.dim .. "A command-line tutorial game where you care for virtual pets" .. utils.colors.reset,
        utils.colors.dim .. "while learning common terminal commands and concepts." .. utils.colors.reset,
        "",
        utils.colors.yellow .. "Basic Commands:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "create" .. utils.colors.reset .. "                 Create a new tamagotchi pet",
        "  " .. utils.colors.green .. "list" .. utils.colors.reset .. "                   Display all your tamagotchi pets",
        "  " .. utils.colors.green .. "select" .. utils.colors.reset .. " " .. utils.colors.blue .. "<n>" .. utils.colors.reset .. "              Switch to a different pet",
        "  " .. utils.colors.green .. "status" .. utils.colors.reset .. "                 Show status of your active pet",
        "",
        utils.colors.yellow .. "Pet Care Commands:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "feed" .. utils.colors.reset .. "                   Feed your pet",
        "  " .. utils.colors.green .. "play" .. utils.colors.reset .. "                   Play with your pet",
        "  " .. utils.colors.green .. "sleep" .. utils.colors.reset .. "                  Put pet to sleep or wake them up",
        "  " .. utils.colors.green .. "clean" .. utils.colors.reset .. "                  Clean your pet",
        "  " .. utils.colors.green .. "evolve" .. utils.colors.reset .. "                 Attempt to evolve your pet",
        "",
        utils.colors.yellow .. "Economy & Shopping:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "work" .. utils.colors.reset .. "                   Work to earn coins",
        "  " .. utils.colors.green .. "earn" .. utils.colors.reset .. "                   Earn coins from command history",
        "  " .. utils.colors.green .. "shop" .. utils.colors.reset .. "                   View available items",
        "  " .. utils.colors.green .. "buy" .. utils.colors.reset .. " " .. utils.colors.blue .. "<item>" .. utils.colors.reset .. "               Purchase items",
        "  " .. utils.colors.green .. "wallet" .. utils.colors.reset .. "                 Check coin balance",
        "",
        utils.colors.yellow .. "Inventory:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "inventory" .. utils.colors.reset .. "              View all items you own",
        "  " .. utils.colors.green .. "use" .. utils.colors.reset .. " " .. utils.colors.blue .. "<item>" .. utils.colors.reset .. "               Use a specific item",
        "  " .. utils.colors.green .. "autofeed" .. utils.colors.reset .. "               Automatically feed if hungry",
        "  " .. utils.colors.green .. "autoheal" .. utils.colors.reset .. "               Automatically heal if needed",
        "",
        utils.colors.yellow .. "Breeding:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "breed" .. utils.colors.reset .. " " .. utils.colors.blue .. "<f> <m> <child>" .. utils.colors.reset .. "     Create offspring from two pets",
        "  " .. utils.colors.green .. "family" .. utils.colors.reset .. " " .. utils.colors.blue .. "<n>" .. utils.colors.reset .. "              View family tree",
        "  " .. utils.colors.green .. "compatibility" .. utils.colors.reset .. " " .. utils.colors.blue .. "<p1> <p2>" .. utils.colors.reset .. "   Check breeding compatibility",
        "",
        utils.colors.yellow .. "Other:" .. utils.colors.reset,
        "  " .. utils.colors.green .. "bonus" .. utils.colors.reset .. "                  Claim daily coin bonus",
        "  " .. utils.colors.green .. "help" .. utils.colors.reset .. "                   Show detailed command help",
        "",
        utils.colors.yellow .. "Global Options:" .. utils.colors.reset,
        "  " .. utils.colors.magenta .. "-h, --help" .. utils.colors.reset .. "            Show this help message",
        "  " .. utils.colors.magenta .. "-v, --version" .. utils.colors.reset .. "         Show version information",
        "",
        utils.colors.yellow .. "Examples:" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "create" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "buy" .. utils.colors.reset .. " " .. utils.colors.blue .. "apple" .. utils.colors.reset,
        "  " .. utils.colors.dim .. "tamagotchi-cli " .. utils.colors.reset .. utils.colors.green .. "status" .. utils.colors.reset,
        "",
        utils.colors.blue .. "Learn more: " .. utils.colors.reset .. "Run 'tamagotchi-cli help' for complete documentation"
    }
    
    print(table.concat(usage_text, "\n"))
end

local function parse_args(args)
    if #args == 0 then
        show_usage()
        return nil, nil
    end
    
    local command = args[1]
    local params = {}
    
    -- Handle global flags
    if command == "-h" or command == "--help" then
        show_usage()
        return nil, nil
    elseif command == "-v" or command == "--version" then
        show_version()
        return nil, nil
    elseif command:sub(1,1) == "-" then
        print(utils.colors.red .. "Error: Unknown option '" .. command .. "'" .. utils.colors.reset)
        print("Try 'tamagotchi-cli --help' for available options.")
        return nil, nil
    end
    
    -- Collect parameters
    for i = 2, #args do
        table.insert(params, args[i])
    end
    
    return command, params
end

local function main(args)
    local command, params = parse_args(args)
    
    if command then
        cli.execute_command(command, params)
    end
end

main(arg)