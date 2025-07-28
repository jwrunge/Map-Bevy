use bevy::prelude::*;

/// Setup the 3D scene with objects
pub fn setup_scene(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    // Add a cube
    commands.spawn((
        Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
        MeshMaterial3d(materials.add(Color::srgb_u8(124, 144, 255))),
        Transform::from_xyz(0.0, 0.5, 0.0),
    ));

    // Add a plane
    commands.spawn((
        Mesh3d(meshes.add(Plane3d::default().mesh().size(5.0, 5.0))),
        MeshMaterial3d(materials.add(Color::srgb_u8(60, 130, 60))),
    ));

    // Add a light
    commands.spawn((
        DirectionalLight {
            shadows_enabled: true,
            ..default()
        },
        Transform {
            translation: Vec3::new(0.0, 2.0, 0.0),
            rotation: Quat::from_rotation_x(-std::f32::consts::FRAC_PI_4),
            ..default()
        },
    ));
}

/// Rotate the camera around the scene
pub fn rotate_camera(mut camera_query: Query<&mut Transform, With<Camera3d>>, time: Res<Time>) {
    for mut transform in &mut camera_query {
        transform.rotate_around(Vec3::ZERO, Quat::from_rotation_y(time.delta_secs() * 0.5));
    }
}
