use map_bevy::MapBevyEngine;

fn main() {
    #[cfg(feature = "windowed")]
    {
        let engine = MapBevyEngine::new_windowed(800, 600, "Map-Bevy");
        engine.run();
    }

    #[cfg(not(feature = "windowed"))]
    {
        let mut engine = MapBevyEngine::new_headless(800, 600);

        // Run a few frames for demonstration
        for frame in 0..60 {
            engine.update();

            if frame % 10 == 0 {
                if let Some(buffer) = engine.get_frame_buffer() {
                    println!(
                        "Frame {}: Generated {} bytes of pixel data",
                        frame,
                        buffer.len()
                    );
                }
            }
        }

        println!("Headless rendering complete!");
    }
}
