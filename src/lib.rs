use bevy::prelude::*;

#[derive(Component)]
struct Person;

#[derive(Component)]
struct Name(String);

#[derive(Resource)]
struct GreetTimer(Timer);

pub fn run() {
    App::new().add_plugins((DefaultPlugins, HelloPlugin)).run();
}

pub struct HelloPlugin;

impl Plugin for HelloPlugin {
    fn build(&self, app: &mut App) {
        app.insert_resource(GreetTimer(Timer::from_seconds(2.0, TimerMode::Repeating)));
        app.add_systems(Startup, add_people);
        app.add_systems(Update, (hello_world, (update_people, greet_people).chain()));
    }
}

fn hello_world() {
    println!("Hello, world!");
}

fn add_people(mut commands: Commands) {
    commands.spawn((Person, Name("Alice".to_string())));
    commands.spawn((Person, Name("Bob".to_string())));
    commands.spawn((Person, Name("Charlie".to_string())));
}

fn greet_people(time: Res<Time>, mut timer: ResMut<GreetTimer>, query: Query<&Name, With<Person>>) {
    if timer.0.tick(time.delta()).just_finished() {
        for name in &query {
            println!("Hello, {}!", name.0);
        }
    }
}

fn update_people(mut query: Query<&mut Name, With<Person>>) {
    println!("Updating people...");
    for mut name in &mut query {
        if name.0 == "Alice" {
            name.0 = "Alex".to_string();
            break;
        }
    }
}
