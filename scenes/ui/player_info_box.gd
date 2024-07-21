class_name PlayerInfoBox
extends Node

@onready var gamertag_label = $gamertag as Label
@onready var health_label = $health as Label

var player:Player

func load_player(new_player: Player):
	player = new_player
	gamertag_label.text = player.gamertag
	player.got_damage.connect(_on_got_damage)
	player.died.connect(_on_died)

func _on_got_damage(_damage: int, health: int):
	if is_instance_valid(player):
		health_label.text = str(player.health)

func _on_died(_shooter: Player):
	health_label.text = "dead"
