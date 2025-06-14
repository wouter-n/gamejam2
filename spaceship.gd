# Spaceship.gd
# Attach this script to the spaceship (a RigidBody2D).
# Includes gravity, player controls, auto-orbit, and trajectory prediction.
extends RigidBody2D

# --- Player Control Variables ---
@export var thrust_force: float = 500.0
@export var rotation_velocity: float = 6.0
@export var braking_dampening: float = 2.0
@export var launch_impulse: float = 1000

# --- Animation Node ---
@onready var animated_sprite: AnimatedSprite2D = $Ship
@onready var animated_thruster: AnimatedSprite2D = $Fire
@onready var animated_ui: AnimatedSprite2D = $UI

@onready var death_sound: AudioStreamPlayer = $Death

# --- Score ---
@onready var score_label = $UI/Label
@onready var score: float = 0

# --- Fuel  ---
@onready var fuel_gauge = $UI/FuelGauge
var fuel_in_tank: bool = true
var fuel: float = 100

func _make_fuel_map() -> Dictionary:
	var fuel_map: Dictionary = {}
	var frame = 0
	for i in range(100, -10, -10):
		fuel_map[i] = frame
		frame += 1
	return fuel_map
var fuel_map: Dictionary = _make_fuel_map()

const THRUST_COST: float = 0.5
const ROTATE_COST: float = 0.1
const TAKE_OFF_COST: float = 1

# --- Private Variables ---
var planets: Array = []

enum LandingStates {CLEAN, NOSE, SIDE}
enum States {FLYING, LANDING, LANDED, TAKE_OFF, DEAD}
var state: States = States.FLYING
var landing_states: LandingStates = LandingStates.CLEAN

var warning: bool = false

var takeoff_distance = 50
var takeoff_direction: Vector2

var landed_planet: Node2D = null
var offset : Transform2D

var old_state = States.FLYING

func _update_fuel() -> void:
	var clamped_fuel = int(fuel / 10) * 10
	clamped_fuel = clamp(clamped_fuel, 0, 100)
	var frame = fuel_map[clamped_fuel]
	fuel_gauge.frame = frame
	if clamped_fuel == 0 or fuel_gauge.frame == 9:
		fuel_in_tank = false
		animated_sprite.play("idle")
		animated_thruster.hide()
	elif fuel < 30:
		warning = true
	else:
		warning = false
		fuel_in_tank = true

func _ready():
	planets = get_tree().get_nodes_in_group("planets")
	
	connect("body_entered", Callable(self, "planet_touchdown"))
	
	# Start with the idle animation
	animated_sprite.play("idle")
	animated_thruster.hide()

func _physics_process(delta: float) -> void:
	score += 1
	score_label.text = "%d" % score
	_update_fuel()
	if state == States.DEAD:
		# Do nothing
		pass
	elif state == States.TAKE_OFF and distance_to_closest_planet() > takeoff_distance:
		animated_thruster.show()
		animated_thruster.play("fire")
		
		landed_planet = null
		state = States.FLYING
	
	elif state == States.TAKE_OFF:
		animated_thruster.show()
		animated_thruster.play("fire")
		
		handle_player_input()
	
	elif state == States.FLYING:
		handle_player_input()
	
	elif state == States.LANDED:
		animated_sprite.play("land")
	
		if Input.is_action_just_pressed("Launch"):
			taking_off(delta)
			AudioManager.play_takeoff_sound()
			#animated_thruster.hide()
		else:
			if landed_planet == null:
				death_animation()
			else:
				global_transform = landed_planet.global_transform * offset
			

	# For debugging
	if state != old_state:
		print("New state:", States.keys()[state])
		old_state = state
	if warning:
		animated_ui.play("oh_fuck")
	else:
		animated_ui.play("chill")


func planet_touchdown(body):
	if state not in [States.TAKE_OFF, States.DEAD] and body.is_in_group("planets"):
		var planet = body
		state = States.LANDED
		landed_planet = planet
		fuel = 100
		
		# Set to idle animation upon landing
		animated_sprite.play("idle")
		
		# CHECK ORIENTATION
		var direction = (global_position - planet.global_position).normalized()
		var dist_to_planet = (planet.global_position - global_position).normalized()
		var ship_down = -transform.x.normalized()
	
		var dot = ship_down.dot(dist_to_planet)
		if dot <= 0.60:
			death_animation()
		else:
			# Compute angle facing away from center (so ship is "standing up")
			var angle = direction.angle()
			rotation = angle
			offset = planet.global_transform.affine_inverse() * global_transform


func death_animation() -> void:
	state = States.DEAD
	animated_sprite.play("death")
	AudioManager.play_death_sound()
	animated_ui.play("dead")
	animated_sprite.connect("animation_finished", _on_death_animation_finished)
	
	print("💥 KABOOM!")
	set_physics_process(false)
	set_process(false)


func _on_death_animation_finished() -> void:
	# Function is called after the death animation is finished
	hide()
	
	Utilities.score = score
	Utilities.switch_scene("GameOver", self)


func distance_to_closest_planet():
	var planet = find_closest_planet()
	if planet == null:
		return INF
	var distance_to_center = (planet.global_position - global_position).length()
	return distance_to_center - planet.radius


func find_closest_planet():
	var closest_planet = null
	var min_dist_sq = INF
	for planet in planets:
		if not is_instance_valid(planet):
			continue
		var dist_sq = global_position.distance_squared_to(planet.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_planet = planet
	return closest_planet


func short_angle_distance(a, b):
	return fmod((b - a + PI), TAU) - PI


func taking_off(delta):
	#if Input.is_action_just_pressed("ui_accept") and landed_planet != null:
	if landed_planet != null:
		state = States.TAKE_OFF
		
		# Play thrust animation when taking off
		animated_sprite.play("thrust")
	
		var takeoff_direction = transform.x.normalized()
		var launch_power = 500 + landed_planet.radius * landed_planet.rotation
		
		angular_velocity = 0
		apply_central_impulse(takeoff_direction * launch_power)
		fuel -= TAKE_OFF_COST


func apply_central_gravity(force: Vector2) -> void:
	apply_central_force(force)


func handle_player_input():
	var rotation_direction = 0
	if not fuel_in_tank:
		$"Fire/GPUParticles2D".emitting = false
		return
	if Input.is_action_pressed("Left"):
		rotation_direction -= 1
		fuel -= ROTATE_COST
	if Input.is_action_pressed("Right"):
		rotation_direction += 1
		fuel -= ROTATE_COST
	
	angular_velocity = rotation_direction * rotation_velocity

	if Input.is_action_pressed("Up"):
		fuel -= THRUST_COST
		if !$"Fire/GPUParticles2D".emitting:
			$"Fire/GPUParticles2D".restart()
		$"Fire/GPUParticles2D".emitting = true
		apply_central_force(transform.x.normalized() * thrust_force)
		# Play thrust animation if it's not already playing
		if animated_sprite.animation != "thrust":
			animated_sprite.play("thrust")
			animated_thruster.show()
			animated_thruster.play("fire")
		# AudioManager.play_thruster_sound()
	else:
		$"Fire/GPUParticles2D".emitting = false
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
			animated_thruster.hide()
	
