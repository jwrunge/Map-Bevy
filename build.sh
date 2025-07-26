#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
BUILD_ALL=false
RELEASE_MODE=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            BUILD_ALL=true
            shift
            ;;
        --release)
            RELEASE_MODE=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Show help
if [ "$HELP" = true ]; then
    echo -e "${BLUE}Map-Bevy Build Script${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./build.sh [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  --all      Build all targets (native windowed, headless, and WASM)"
    echo "  --release  Build in release mode (optimized, slower compilation)"
    echo "  --help     Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./build.sh                    # Build native windowed app (dev mode)"
    echo "  ./build.sh --release          # Build native windowed app (release mode)"
    echo "  ./build.sh --all              # Build all targets (dev mode)"
    echo "  ./build.sh --all --release    # Build all targets (release mode)"
    echo ""
    echo -e "${YELLOW}Available run commands:${NC}"
    echo "  cargo run                     # Run windowed app (dev mode)"
    echo "  cargo run --release           # Run windowed app (release mode)"
    echo "  cargo run --features headless --no-default-features  # Run headless mode"
    exit 0
fi

# Determine build profile and features
if [ "$RELEASE_MODE" = true ]; then
    BUILD_PROFILE="--release"
    PROFILE_NAME="release"
    WASM_PROFILE="--release"
else
    BUILD_PROFILE=""
    PROFILE_NAME="dev"
    WASM_PROFILE="--dev"
fi

# Add dev feature for faster compilation in dev mode
if [ "$RELEASE_MODE" = false ]; then
    DEV_FEATURES="--features dev,windowed"
    HEADLESS_DEV_FEATURES="--features dev,headless"
else
    DEV_FEATURES="--features windowed"
    HEADLESS_DEV_FEATURES="--features headless"
fi

if [ "$BUILD_ALL" = true ]; then
    echo -e "${YELLOW}Building Map-Bevy for all targets (${PROFILE_NAME} mode)...${NC}"
else
    echo -e "${YELLOW}Building Map-Bevy native app (${PROFILE_NAME} mode)...${NC}"
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Always check for cargo
if ! command_exists cargo; then
    echo -e "${RED}Error: cargo is not installed${NC}"
    exit 1
fi

# Build native version (windowed) - always build this
echo -e "${YELLOW}Building native version (windowed)...${NC}"
cargo build $BUILD_PROFILE $DEV_FEATURES
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Native windowed build successful!${NC}"
else
    echo -e "${RED}Native windowed build failed!${NC}"
    exit 1
fi

# Only build additional targets if --all is specified
if [ "$BUILD_ALL" = true ]; then
    # Build native version (headless) - library and example only
    echo -e "${YELLOW}Building native version (headless)...${NC}"
    cargo build $BUILD_PROFILE --lib --features headless --no-default-features
    if [ $? -eq 0 ]; then
        # Also build the headless example
        cargo build $BUILD_PROFILE --example headless --features headless --no-default-features
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Native headless build successful!${NC}"
        else
            echo -e "${RED}Native headless example build failed!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Native headless build failed!${NC}"
        exit 1
    fi

    # Check for WASM tools only if building all targets
    if ! command_exists wasm-pack; then
        echo -e "${YELLOW}wasm-pack not found. Installing...${NC}"
        curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install wasm-pack${NC}"
            exit 1
        fi
    fi

    if ! command_exists wasm-opt; then
        echo -e "${YELLOW}wasm-opt not found. Installing Binaryen...${NC}"
        if command_exists brew; then
            brew install binaryen
        elif command_exists apt; then
            sudo apt update && sudo apt install binaryen
        elif command_exists yum; then
            sudo yum install binaryen
        else
            echo -e "${RED}Could not install Binaryen automatically. Please install it manually:${NC}"
            echo "  macOS: brew install binaryen"
            echo "  Ubuntu/Debian: sudo apt install binaryen"
            echo "  Or download from: https://github.com/WebAssembly/binaryen/releases"
            exit 1
        fi
        # Verify installation
        if ! command_exists wasm-opt; then
            echo -e "${RED}Failed to install wasm-opt${NC}"
            exit 1
        fi
    fi

    # Add WASM target if not already added
    echo "Adding WASM target..."
    rustup target add wasm32-unknown-unknown

    # Build WASM version
    echo -e "${YELLOW}Building WASM version...${NC}"
    wasm-pack build --target web --out-dir pkg $WASM_PROFILE -- --features windowed
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}WASM build successful!${NC}"
        
        # Optimize WASM with wasm-opt (only in release mode)
        if [ "$RELEASE_MODE" = true ]; then
            echo -e "${YELLOW}Optimizing WASM with wasm-opt...${NC}"
            WASM_FILE="pkg/map_bevy_bg.wasm"
            if [ -f "$WASM_FILE" ]; then
                # Get original file size
                ORIGINAL_SIZE=$(stat -f%z "$WASM_FILE" 2>/dev/null || stat -c%s "$WASM_FILE" 2>/dev/null)
                
                # Create backup
                cp "$WASM_FILE" "$WASM_FILE.backup"
                
                # Optimize with wasm-opt
                wasm-opt -Os --output "$WASM_FILE" "$WASM_FILE.backup"
                
                if [ $? -eq 0 ]; then
                    # Get optimized file size
                    OPTIMIZED_SIZE=$(stat -f%z "$WASM_FILE" 2>/dev/null || stat -c%s "$WASM_FILE" 2>/dev/null)
                    REDUCTION=$((ORIGINAL_SIZE - OPTIMIZED_SIZE))
                    PERCENT_REDUCTION=$((REDUCTION * 100 / ORIGINAL_SIZE))
                    
                    echo -e "${GREEN}WASM optimization successful!${NC}"
                    echo -e "${BLUE}Original size: ${ORIGINAL_SIZE} bytes${NC}"
                    echo -e "${BLUE}Optimized size: ${OPTIMIZED_SIZE} bytes${NC}"
                    echo -e "${BLUE}Reduction: ${REDUCTION} bytes (${PERCENT_REDUCTION}%)${NC}"
                    
                    # Remove backup
                    rm "$WASM_FILE.backup"
                else
                    echo -e "${RED}WASM optimization failed, restoring original${NC}"
                    mv "$WASM_FILE.backup" "$WASM_FILE"
                fi
            else
                echo -e "${YELLOW}WASM file not found at expected location: $WASM_FILE${NC}"
            fi
        fi
    else
        echo -e "${RED}WASM build failed!${NC}"
        exit 1
    fi
fi

if [ "$BUILD_ALL" = true ]; then
    echo -e "${GREEN}All builds completed successfully!${NC}"
else
    echo -e "${GREEN}Native build completed successfully!${NC}"
fi

echo ""
echo -e "${BLUE}Available run commands:${NC}"
echo ""
echo -e "${YELLOW}Windowed (development):${NC}"
echo "  cargo run                        # Fast dev build with dynamic linking"
echo "  cargo run --release              # Optimized release build"
echo ""
echo -e "${YELLOW}Headless (library):${NC}"
echo "  cargo run --example headless --features headless --no-default-features"
echo "  cargo run --example headless --release --features headless --no-default-features"
echo ""
if [ "$BUILD_ALL" = true ]; then
    echo -e "${YELLOW}WASM (browser):${NC}"
    echo "  python3 -m http.server 8000      # Serve from project root"
    echo "  # or"
    echo "  npx serve .                      # Alternative server"
    echo "  # then open http://localhost:8000"
    echo ""
fi
echo -e "${BLUE}Build script usage:${NC}"
echo "  ./build.sh                       # Build native app (dev mode, fast)"
echo "  ./build.sh --release             # Build native app (release mode)"
echo "  ./build.sh --all                 # Build all targets (dev mode)"
echo "  ./build.sh --all --release       # Build all targets (release mode)"
echo ""
echo -e "${BLUE}Library usage:${NC}"
echo "  Add to Cargo.toml: map-bevy = { path = \".\", features = [\"headless\"], default-features = false }"
