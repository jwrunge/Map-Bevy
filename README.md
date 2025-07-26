# Map-Bevy

A Bevy-based application that builds for both native and WebAssembly (WASM) targets.

## Features

-   🖥️ Native desktop support (Windows, macOS, Linux)
-   🌐 WebAssembly support for browsers
-   🎮 3D graphics with Bevy engine
-   🔄 Unified codebase for all platforms

## Prerequisites

-   [Rust](https://rustup.rs/) (latest stable)
-   [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/) (for WASM builds)

## Quick Start

### Option 1: Use the build script (recommended)

```bash
./build.sh
```

This will:

-   Build both native and WASM versions
-   Install required tools if missing
-   Provide instructions for running

### Option 2: Manual builds

#### Native Build

```bash
# Debug build
cargo run

# Release build
cargo run --release
```

#### WASM Build

```bash
# Add WASM target (one-time setup)
rustup target add wasm32-unknown-unknown

# Install wasm-pack (one-time setup)
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Build for web
wasm-pack build --target web --out-dir pkg --release
```

#### Running WASM Version

After building the WASM version, serve the files locally:

```bash
# Using Python
python3 -m http.server 8000

# Using Node.js
npx serve .

# Using any other static file server
```

Then open http://localhost:8000 in your browser.

## Project Structure

```
Map-Bevy/
├── src/
│   └── main.rs          # Main application code
├── Cargo.toml           # Rust dependencies and configuration
├── index.html           # HTML page for WASM version
├── build.sh             # Automated build script
├── pkg/                 # WASM build output (generated)
└── target/              # Native build output (generated)
```

## Configuration

The `Cargo.toml` is configured with:

-   Platform-specific dependencies
-   Optimized Bevy features for each target
-   WASM-specific optimizations

## Controls

-   **ESC**: Exit application (native only)
-   The camera automatically rotates around the scene

## Deployment

### Native

The native executable is located at `target/release/map-bevy` (or `map-bevy.exe` on Windows).

### WASM

The WASM files are generated in the `pkg/` directory. Deploy these files along with `index.html` to any static file hosting service.

## Troubleshooting

### WASM Build Issues

-   Ensure `wasm-pack` is installed and up to date
-   Check that the `wasm32-unknown-unknown` target is installed
-   Try clearing the target directory: `cargo clean`

### Native Build Issues

-   Update Rust: `rustup update`
-   Clear cargo cache: `cargo clean`

### Performance

-   Use release builds for better performance: `--release`
-   For development, consider using the `dev` feature for faster compile times

## License

[Add your license here]
