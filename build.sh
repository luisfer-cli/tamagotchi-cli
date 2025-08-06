#!/bin/bash

# Tamagotchi CLI Binary Builder
# This script creates a standalone binary for easy distribution

set -e

echo "Building Tamagotchi CLI Binary..."

# Check if luastatic is available
if ! command -v luastatic &>/dev/null; then
    echo "Installing luastatic..."

    # Try to install luastatic via luarocks
    if command -v luarocks &>/dev/null; then
        luarocks install luastatic
    else
        echo "luarocks not found. Installing luastatic manually..."

        # Download luastatic
        if [ ! -f luastatic.lua ]; then
            curl -o luastatic.lua https://raw.githubusercontent.com/ers35/luastatic/master/luastatic.lua
            chmod +x luastatic.lua
        fi

        LUASTATIC="lua luastatic.lua"
    fi
else
    LUASTATIC="luastatic"
fi

# Create build directory
mkdir -p build
cd build

# Copy all source files to build directory
cp -r ../modules .
cp -r ../tamagotchis .
cp -r ../data .
cp ../tamagotchi.lua .

echo "Creating standalone binary..."

# Build the binary using luastatic with /usr/local paths
$LUASTATIC tamagotchi.lua \
    modules/cli.lua \
    modules/tamagotchi.lua \
    modules/persistence.lua \
    modules/economy.lua \
    modules/inventory.lua \
    modules/breeding.lua \
    modules/utils.lua \
    /usr/local/lib/liblua.a \
    -I/usr/local/include \
    -o tamagotchi-cli

# If build failed, try simpler build approach
if [ ! -f tamagotchi-cli ]; then
    echo "Trying simpler build approach..."
    $LUASTATIC tamagotchi.lua \
        modules/*.lua \
        -o tamagotchi-cli
fi

if [ -f tamagotchi-cli ]; then
    echo "Binary created successfully!"
    echo "Location: build/tamagotchi-cli"
    echo "Size: $(du -h tamagotchi-cli | cut -f1)"

    # Make it executable
    chmod +x tamagotchi-cli

    # Test the binary
    echo "Testing binary..."
    ./tamagotchi-cli help >/dev/null && echo "Binary works correctly!"

    # Move to parent directory
    cp tamagotchi-cli ../
    echo "Binary copied to project root"

else
    echo "Failed to create binary"
    echo "You can still distribute the project as Lua files"
    echo "Users will need: lua + chmod +x tamagotchi.lua"
fi

cd ..
echo "Build process complete!"
