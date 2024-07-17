extends CharacterBody2D

var speed = 100
var accel = 7
var radius = 500

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var map = nav.get_navigation_map()
@onready var target = get_new_target()

func _physics_process(delta):	
	var direction = Vector3()
	
	nav.target_position = global_position - target
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()

func _on_navigation_agent_2d_target_reached():
	print("reached")
	get_new_target()

func get_new_target():
	target = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
	print(NavigationServer2D.get_maps())
	print(map)
	return target
	
