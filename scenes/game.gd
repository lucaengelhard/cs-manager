class_name Game
extends Node2D

@onready var player_controller = $PlayerController as PlayerController
@onready var ui = $UI
@onready var ui_players_node = $UI/Players
@onready var ui_players_ct = $UI/Players/CT
@onready var ui_players_t = $UI/Players/T

func _ready():
	assign_players_to_labels()

func assign_players_to_labels():
	var ui_ct_children = ui_players_ct.get_children() as Array[PlayerInfoBox]
	var ui_t_children = ui_players_t.get_children() as Array[PlayerInfoBox]
	
	for player in player_controller.players:
		var infobox: PlayerInfoBox
		if player.team == PlayerController.TEAM.CT:
			infobox = ui_ct_children[0]
			ui_ct_children.erase(infobox)
		else:
			infobox = ui_t_children[0]
			ui_t_children.erase(infobox)
		infobox.load_player(player)
