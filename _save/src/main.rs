use map_bevy::MapBevyEngine;

fn main() {
    let engine = MapBevyEngine::new_windowed(800, 600, "Map-Bevy");
    engine.run();
}
