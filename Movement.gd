extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity:Vector2
var axis:Vector2

export(int) var speed
export(int) var gravity 
export(int) var jump_strength
export(int) var feet_friction
export(int) var acceleration_strength
export(float) var midair_fractional_acceleration
export(float) var midair_fractional_speed
export(float) var dash_distance
export(float) var dash_duration
export(float) var double_jump_window_duration

var acceleration
var acceleration_modifier
var sprite_animation
var can_dash
var is_dashing
var just_dashed
var can_double_jump
var just_double_jump
var target_velocity
var velocity_modifier
var face_direction = 1

onready var dash_timer = get_node("Dash Timer")
onready var double_jump_timer = get_node("Double Jump Timer")


# Called when the node enters the scene tree for the first time.
func _ready():
	double_jump_timer.set_wait_time(double_jump_window_duration)
	dash_timer.set_wait_time(dash_duration)
	acceleration_strength *= 10
	feet_friction *= 0.1
	can_double_jump = false

#Implement dash and double jump

func _physics_process(delta):
	
	acceleration = 0
	is_dashing = false
	
	if is_on_floor():
		can_dash = false
		just_dashed = false
		acceleration_modifier = 1
		velocity_modifier = 1
		if Input.is_action_just_pressed("Jump"):
			can_double_jump = true
			double_jump_timer.start()
			velocity.y = -1*jump_strength
	else :
		if Input.is_action_just_pressed("Jump"):
			if can_double_jump:
				velocity.y = -1*jump_strength
				can_double_jump = false
		if just_dashed == false:
			can_dash = true
		acceleration_modifier = midair_fractional_acceleration
		velocity_modifier = midair_fractional_speed
	
	if Input.is_action_pressed("Right"):
		face_direction = 1
		acceleration = acceleration_modifier*acceleration_strength
		sprite_animation = "Move"
		$AnimatedSprite.flip_h = false
		
	if Input.is_action_pressed("Left"):
		face_direction = -1
		acceleration_modifier *= -1
		acceleration = acceleration_modifier*acceleration_strength
		sprite_animation = "Move"
		$AnimatedSprite.flip_h = true
	
	if is_on_floor() == false :
		sprite_animation = "Idle"
	
	if Input.is_action_just_pressed("Dash") and can_dash == true:
		can_dash = false
		is_dashing = true
		just_dashed = true
		velocity.x += (dash_distance/dash_duration)*face_direction
		dash_timer.start()
	
	target_velocity = acceleration_modifier/(abs(acceleration_modifier))*speed*velocity_modifier
	
	if (acceleration != 0) and is_dashing == false:
		velocity.x += acceleration*delta
		if (abs(velocity.x) >= abs(target_velocity)):
			velocity.x = target_velocity
			
	else :
		sprite_animation = "Idle"
		velocity.x = lerp(velocity.x, 0, feet_friction*0.1)
	
	$AnimatedSprite.animation = sprite_animation
	
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _Dash_Finished():
	is_dashing = false
	velocity.x = 0
	dash_timer.stop()


func _on_Double_Jump_Window_End_timeout():
	can_double_jump = false
	double_jump_timer.stop()
