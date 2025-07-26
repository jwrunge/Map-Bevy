#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Map-Bevy for native and WASM targets...${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "Checking required tools..."

if ! command_exists cargo; then
    echo -e "${RED}Error: cargo is not installed${NC}"
    exit 1
fi

if ! command_exists wasm-pack; then
    echo -e "${YELLOW}wasm-pack not found. Installing...${NC}"
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install wasm-pack${NC}"
        exit 1
    fi
fi

# Build native version
echo -e "${YELLOW}Building native version...${NC}"
cargo build --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Native build successful!${NC}"
else
    echo -e "${RED}Native build failed!${NC}"
    exit 1
fi

# Add WASM target if not already added
echo "Adding WASM target..."
rustup target add wasm32-unknown-unknown

# Build WASM version
echo -e "${YELLOW}Building WASM version...${NC}"
wasm-pack build --target web --out-dir pkg --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}WASM build successful!${NC}"
else
    echo -e "${RED}WASM build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}All builds completed successfully!${NC}"
echo ""
echo "To run the native version:"
echo "  cargo run --release"
echo ""
echo "To serve the WASM version locally:"
echo "  python3 -m http.server 8000"
echo "  # or"
echo "  npx serve ."
echo "  # then open http://localhost:8000"
