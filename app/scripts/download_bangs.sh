#!/bin/bash

# Change to parent directory
cd "$(dirname "$0")/.."

# Create directory structure if it doesn't exist
mkdir -p assets/bangs

# Array of remote URLs and their corresponding local paths
declare -A downloads=(
    ["https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json"]="assets/bangs/bangs.json"
    ["https://raw.githubusercontent.com/FaFre/bangs/main/data/assistant_bangs.json"]="assets/bangs/assistant_bangs.json"
    ["https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json"]="assets/bangs/kagi_bangs.json"
    ["https://raw.githubusercontent.com/FaFre/bangs/refs/heads/custom/data/custom.json"]="assets/bangs/custom.json"
)

# Download each file
for remote_url in "${!downloads[@]}"; do
    local_path="${downloads[$remote_url]}"
    echo "Downloading $remote_url to $local_path"

    if curl -fsSL "$remote_url" -o "$local_path"; then
        echo "✓ Successfully downloaded $local_path"
    else
        echo "✗ Failed to download $local_path"
        exit 1
    fi
done

# Write current timestamp to sync file
echo "$(date -u --iso-8601=seconds)" > assets/bangs/last_sync.txt
echo "✓ Sync completed at $(cat assets/bangs/last_sync.txt)"
