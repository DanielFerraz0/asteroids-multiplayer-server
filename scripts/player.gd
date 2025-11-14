extends CharacterBody2D

const FRICTION = 0.995
const THRUST_POWER = 900.0;
const ROTATION_SPEED = 5.0;

var received_turn = 0.0;
var received_thrust = false;

@export var username: String = "";
@onready var sprite = $Sprite2D;

@rpc("any_peer", "unreliable")
func receive_player_input(turn: float, thrust: bool):
	received_turn = turn
	received_thrust = thrust
	
func _physics_process(delta: float) -> void:
	sprite.rotation += received_turn * ROTATION_SPEED * delta;
	
	if received_thrust:
		velocity += Vector2.UP.rotated(sprite.rotation) * THRUST_POWER * delta;
	
	move_and_slide();
	velocity *= FRICTION;
	
	rpc("update_player_state", position, sprite.rotation);
	
@rpc("any_peer", "unreliable")
func update_player_state(_pos: Vector2, _rot: float):
	pass;
