extends CharacterBody2D

enum TEAM {CT, T}
enum MOVEMODE {Mouse, Random}

# draw player
@export var team: TEAM = TEAM.CT
@export var size := 7
@onready var collider := $Collider

# init nav
@onready var nav := $NavigationAgent2D
@export var speed := 100
@export var accel := 7
@export var movemode := MOVEMODE.Mouse # Change default later
@onready var target := get_new_target()
@onready var map := $"../Map"
	
func _draw():
	var color = Color.GREEN
	if team == TEAM.CT:
		color = Color.BLUE
	elif team == TEAM.T:
		color = Color.RED
	collider.shape.radius = size
	draw_circle(Vector2(0,0), size, color)
	
func _physics_process(delta):
	nav_to_point(delta)
	
	if movemode == MOVEMODE.Mouse:
		target = get_new_target()

func nav_to_point(delta:float):
	var direction := Vector2()
	nav.target_position = target
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	rotation = velocity.angle() - deg_to_rad(90)
	
	move_and_slide()

func get_new_target() -> Vector2:
	
	if movemode == MOVEMODE.Mouse:
		return get_global_mouse_position()
	elif movemode == MOVEMODE.Random:
		return get_new_random_target()
	else:
		return Vector2(0,0)

func get_new_random_target() -> Vector2:
	if map == null:
		return Vector2(get_viewport_rect().size / 2)
	
	var currentMap = map.get_child(0)
	var mapSize:Vector2 = currentMap.texture.get_size()
	var currentMapPos:Vector2 = currentMap.global_position
	
	
	return Vector2(
		randi_range(
			currentMapPos.x - (mapSize.x - 20) / 2, currentMapPos.x + mapSize.x / 2),
		randi_range(
			currentMapPos.y - mapSize.y / 2, currentMapPos.y + mapSize.y /2)
			)


func _on_navigation_agent_2d_target_reached():
	target = get_new_target()
