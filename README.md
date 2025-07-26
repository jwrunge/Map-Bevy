# Map-Bevy

A Bevy-based 3D rendering engine that supports multiple deployment modes: windowed applications, headless rendering with pixel buffer output, and WebAssembly for browsers.

## Features

- 🖥️ **Windowed Mode**: Native desktop applications (Windows, macOS, Linux)
- 🔧 **Headless Mode**: Library usage with pixel buffer output for integration
- 🌐 **WebAssembly**: Browser support with WebGL2 rendering
- 📦 **Dual Library/Binary**: Use as a library or standalone application
- 🎮 **3D Graphics**: Full Bevy engine capabilities
- 🔄 **Unified Codebase**: Single source for all deployment modes

## Use Cases

- **Development**: Windowed mode for interactive development and debugging
- **Integration**: Headless mode for embedding in other applications
- **Web Deployment**: WASM mode for browser-based experiences
- **Server Rendering**: Headless mode for server-side image generation

## Prerequisites

- [Rust](https://rustup.rs/) (latest stable)
- [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/) (for WASM builds)

## Quick Start

### Option 1: Use the build script (recommended)

```bash
./build.sh
```

This will build all modes and provide usage instructions.

### Option 2: Manual builds

#### Windowed Mode (Development)

```bash
# Debug build
cargo run --features windowed

# Release build
cargo run --release --features windowed
```

#### Headless Mode (Library)

```bash
# Run as binary
cargo run --release --features headless --no-default-features

# Run example
cargo run --example headless --features headless --no-default-features
```

#### WebAssembly Build

```bash
# Add WASM target (one-time setup)
rustup target add wasm32-unknown-unknown

# Install wasm-pack (one-time setup)
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Build for web
wasm-pack build --target web --out-dir pkg --release -- --features windowed
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

## Library Usage

Map-Bevy can be used as a library in your Rust projects for headless 3D rendering.

### Add to your Cargo.toml

```toml
[dependencies]
map-bevy = { path = "path/to/map-bevy", features = ["headless"], default-features = false }
```

### Basic Usage Example

```rust
use map_bevy::MapBevyEngine;

fn main() {
    // Create a headless engine instance
    let mut engine = MapBevyEngine::new_headless(800, 600);
    
    // Run the simulation
    for frame in 0..60 {
        engine.update();
        
        // Get the rendered frame as pixel data
        if let Some(pixel_buffer) = engine.get_frame_buffer() {
            // pixel_buffer contains RGBA data: width * height * 4 bytes
            // Process or save the frame data...
            println!("Frame {}: {} bytes", frame, pixel_buffer.len());
        }
    }
}
```

### API Reference

#### `MapBevyEngine::new_headless(width: u32, height: u32)`
Creates a new headless engine instance for pixel buffer output.
*Note: Currently requires additional Bevy plugin configuration to run fully.*

#### `MapBevyEngine::new_windowed(width: u32, height: u32, title: &str)` *(windowed feature)*
Creates a windowed application for development and debugging. ✅ **Fully Working**

#### `engine.update()`
Advances the simulation by one frame.

#### `engine.get_frame_buffer() -> Option<Vec<u8>>`
Returns the current frame as RGBA pixel data (headless mode only).

#### `engine.dimensions() -> (u32, u32)`
Returns the render target dimensions.

## Current Status

- ✅ **Windowed Mode**: Fully functional for development and debugging
- ✅ **WASM Mode**: Browser deployment with WebGL2 rendering  
- ⚠️ **Headless Mode**: Framework implemented, requires additional Bevy plugin setup
- ✅ **Dual Library/Binary**: Clean API structure for both use cases
- ✅ **Multi-target Build**: Native and WASM compilation working

## Project Structure

```
Map-Bevy/
├── src/
│   ├── lib.rs           # Library interface
│   ├── main.rs          # Binary application
│   ├── scene.rs         # 3D scene setup
│   └── renderer.rs      # Rendering utilities
├── examples/
│   └── headless.rs      # Headless usage example
├── Cargo.toml           # Rust dependencies and configuration
├── index.html           # HTML page for WASM version
├── build.sh             # Automated build script
├── pkg/                 # WASM build output (generated)
└── target/              # Native build output (generated)
```

## Configuration

The `Cargo.toml` is configured with:
- **Feature flags**: `windowed` and `headless` modes
- **Target-specific dependencies**: Platform optimizations
- **Dual crate types**: Both library (`rlib`) and WASM (`cdylib`)

## Controls

- **ESC**: Exit application (windowed mode only)
- The camera automatically rotates around the scene

## Deployment

### Native Binary
The native executable is located at `target/release/map-bevy` (or `map-bevy.exe` on Windows).

### Library
Use as a dependency with the `headless` feature for pixel buffer access.

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
