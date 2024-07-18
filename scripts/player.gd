class_name Player

extends CharacterBody2D

enum TEAM {CT, T}
enum MOVEMODE {Mouse, Random}

# draw player
@export_group("Player")
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

@export_group("Vision")
@export_range(0, 360) var Angle := 90
@export var Distance := 500
@export var RayNumber := 100
@export var RayNode : RayCast2D
@onready var rays: Array[RayCast2D] = []

func _ready():
	create_cone()

func _process(_delta):
	return
	for ray in rays:
		if ray.is_colliding():
			print("colliding")

func _draw():
	var color = Color.GREEN
	if team == TEAM.CT:
		color = Color.BLUE
	elif team == TEAM.T:
		color = Color.RED
	collider.shape.radius = size
	draw_circle(Vector2(0,0), size, color)

#navigation
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

#viewcones
func create_cone():
	for i in range(RayNumber):
		add_child(RayCast2D.new())
	
	var children := get_children()
	
	var newRays: Array[RayCast2D] = []
	
	for child in children:	
		if child is RayCast2D:
			newRays.append(child)
	
	for i in newRays.size():
		var ray := newRays[i]
		var rayAngle := (float(Angle) / float(RayNumber)) * float(i)
		ray.exclude_parent = true
		ray.target_position = Vector2(0, Distance)
		ray.rotation = deg_to_rad(rayAngle)
			
	rays = newRays
