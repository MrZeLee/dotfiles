#!/usr/bin/env bash

mkdir -p hicolor

# Function to generate icon
generate_icon() {
    local text="$1"
    local output="$2"
    local size="$3"
    
    # Calculate font size (3/4 of image size)
    local font_size=$((size))
    
    # Use convert to create PNG directly
    magick convert -size "${size}x${size}" \
            -background none \
            -gravity center \
            -font "/nix/store/m6ifnadridih1kfbwklzlzqccy9j5s84-nerdfonts-3.2.1/share/fonts/truetype/NerdFonts/HackNerdFontMono-Regular.ttf" \
            -pointsize ${font_size} \
            label:"$text" \
            -trim \
            -extent "${size}x${size}" \
            "hicolor/${size}x${size}/apps/$output"
}

# Define sizes array
# sizes=(16 24 32 48 64 128 256)
sizes=(64)

# Generate icons for each size
for size in "${sizes[@]}"; do
    mkdir -p "hicolor/${size}x${size}"
    mkdir -p "hicolor/${size}x${size}/apps"

    # Generate shutdown icon (󰐥)
    generate_icon "󰐥" "shutdown.png" "$size"
    
    # Generate restart icon (󰜉)
    generate_icon "󰜉" "restart.png" "$size"
    
    # Generate lock icon (󰍁)
    generate_icon "󰍁" "lock.png" "$size"
done

