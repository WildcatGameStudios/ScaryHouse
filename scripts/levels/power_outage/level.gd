extends Node3D

@onready var player: player = $player
@onready var attack_timer: Timer = $bat_timer
@onready var mud_vision: ColorRect = $muddy_vision
@onready var mat: ShaderMaterial = $muddy_vision.material

@export var bat_attack_interval: float = 5.0  # seconds between attacks
@onready var bat_path: PathFollow3D = $Path3D/PathFollow3D
@onready var path_3d: Path3D = $Path3D

@export var debuffed_movement: int = 6 # less than 8

var fade_value: float = 0.0
var fade_in_speed: float = 0.15
var fade_out_speed: float = 0.3
var in_mud: bool = false
var in_danger: bool = false

func _ready() -> void:
	attack_timer.wait_time = bat_attack_interval # Set bat attack timer
	mat.set_shader_parameter("fade", fade_value) # Set fade to 0 for start of level

# Bog logic
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		player.walk_speed = debuffed_movement
		print("Player in swamp, slowing down") # Debug purposes
		in_mud = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		player.walk_speed = 8 # Default walk speed
		print("Player out of swamp, reverting") # Debug purposes
		in_mud = false

func _physics_process(delta: float) -> void:
	if in_mud == true:
		fade_value = clamp(fade_value + fade_in_speed * delta, 0.0, 1.0)
		mat.set_shader_parameter("fade", fade_value)
	elif in_mud == false:
		fade_value = clamp(fade_value - fade_out_speed * delta, 0.0, 1.0)
		mat.set_shader_parameter("fade", fade_value)

# Bat logic
func _on_danger_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_danger = true
		if not attack_timer.is_stopped():
			return
		attack_timer.start()
		print("Player entered the cave")

func _on_danger_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_danger = false
		attack_timer.stop()
		print("Player left the cave")

func update_bat_curve():
	var curve := path_3d.curve
	curve.clear_points()
	
	var start_pos = path_3d.to_local(path_3d.global_position + Vector3(player.global_position.x, 0, 0))
	var mid_pos = path_3d.to_local(player.global_position + Vector3(0, 2, 0))
	var end_pos = path_3d.to_local(path_3d.global_position + Vector3(player.global_position.x, 0, -47))
	
	curve.add_point(start_pos)
	curve.add_point(mid_pos)
	curve.add_point(end_pos)

func _on_timer_timeout() -> void:
	print("timer's done")
	if not in_danger:
		return
	update_bat_curve()
	bat_path.attack()
	attack_timer.start() # Restart timer for attack loop
