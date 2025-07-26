use bevy::prelude::*;

pub mod renderer;
pub mod scene;

pub use renderer::*;
pub use scene::*;

/// Main library interface for the Map-Bevy engine
pub struct MapBevyEngine {
    app: App,
    width: u32,
    height: u32,
    #[cfg(feature = "windowed")]
    is_windowed: bool,
}

impl MapBevyEngine {
    /// Create a new headless Map-Bevy engine instance
    pub fn new_headless(width: u32, height: u32) -> Self {
        let mut app = App::new();
        
        // Use a more complete plugin set for headless rendering
        app.add_plugins((
            bevy::MinimalPlugins,
            bevy::asset::AssetPlugin::default(),
            bevy::render::RenderPlugin::default(),
            bevy::core_pipeline::CorePipelinePlugin::default(),
            bevy::sprite::SpritePlugin::default(),
            bevy::text::TextPlugin::default(),
            bevy::ui::UiPlugin::default(),
            bevy::pbr::PbrPlugin::default(),
        ));

        // Manually add the Image assets resource that tonemapping needs
        app.init_resource::<bevy::asset::Assets<Image>>();

        // Setup headless rendering
        app.add_systems(Startup, setup_headless_camera)
            .add_systems(Startup, setup_scene)
            .add_systems(Update, rotate_camera);

        Self {
            app,
            width,
            height,
            #[cfg(feature = "windowed")]
            is_windowed: false,
        }
    }

    #[cfg(feature = "windowed")]
    /// Create a new windowed Map-Bevy engine instance
    pub fn new_windowed(width: u32, height: u32, title: &str) -> Self {
        let mut app = App::new();
        
        // Add full plugins for windowed mode
        app.add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: title.into(),
                resolution: (width as f32, height as f32).into(),
                canvas: Some("#bevy".into()),
                ..default()
            }),
            ..default()
        }));

        // Setup windowed rendering
        app.add_systems(Startup, setup_windowed_camera)
            .add_systems(Startup, setup_scene)
            .add_systems(Update, (rotate_camera, keyboard_input));

        Self {
            app,
            width,
            height,
            is_windowed: true,
        }
    }

    /// Run one frame of the engine
    pub fn update(&mut self) {
        self.app.update();
    }

    /// Get the rendered frame as a pixel buffer (headless mode only)
    pub fn get_frame_buffer(&mut self) -> Option<Vec<u8>> {
        #[cfg(feature = "windowed")]
        if self.is_windowed {
            return None;
        }

        // This would need more implementation to extract pixels from the render target
        // For now, return a placeholder
        Some(vec![0; (self.width * self.height * 4) as usize])
    }

    /// Run the engine (windowed mode only)
    #[cfg(feature = "windowed")]
    pub fn run(mut self) {
        if self.is_windowed {
            self.app.run();
        }
    }

    /// Get the current frame dimensions
    pub fn dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
}

fn setup_headless_camera(mut commands: Commands) {
    // For now, use a simple camera setup
    // TODO: Implement proper render-to-texture for pixel buffer extraction
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(-2.0, 2.5, 5.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
}

#[cfg(feature = "windowed")]
fn setup_windowed_camera(mut commands: Commands) {
    // Spawn regular camera for windowed mode
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(-2.0, 2.5, 5.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
}

#[cfg(feature = "windowed")]
fn keyboard_input(keys: Res<ButtonInput<KeyCode>>, mut exit: EventWriter<AppExit>) {
    if keys.just_pressed(KeyCode::Escape) {
        exit.write(AppExit::Success);
    }
}
