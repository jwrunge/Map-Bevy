#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Build native version (windowed)
echo -e "${YELLOW}Building native version (windowed)...${NC}"
cargo build --release --features windowed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Native windowed build successful!${NC}"
else
    echo -e "${RED}Native windowed build failed!${NC}"
    exit 1
fi

# Build native version (headless)
echo -e "${YELLOW}Building native version (headless)...${NC}"
cargo build --release --features headless --no-default-features
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Native headless build successful!${NC}"
else
    echo -e "${RED}Native headless build failed!${NC}"
    exit 1
fi

# Add WASM target if not already added
echo "Adding WASM target..."
rustup target add wasm32-unknown-unknown

# Build WASM version
echo -e "${YELLOW}Building WASM version...${NC}"
wasm-pack build --target web --out-dir pkg --release -- --features windowed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}WASM build successful!${NC}"
else
    echo -e "${RED}WASM build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}All builds completed successfully!${NC}"
echo ""
echo -e "${BLUE}Available modes:${NC}"
echo ""
echo -e "${YELLOW}Windowed (development):${NC}"
echo "  cargo run --release --features windowed"
echo ""
echo -e "${YELLOW}Headless (library):${NC}"
echo "  cargo run --release --features headless --no-default-features"
echo "  cargo run --example headless --features headless --no-default-features"
echo ""
echo -e "${YELLOW}WASM (browser):${NC}"
echo "  python3 -m http.server 8000"
echo "  # or"
echo "  npx serve ."
echo "  # then open http://localhost:8000"
echo ""
echo -e "${BLUE}Library usage:${NC}"
echo "  Add to Cargo.toml: map-bevy = { path = \".\", features = [\"headless\"], default-features = false }"
