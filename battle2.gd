extends TextureRect

@onready var _player_character1 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter1")
@onready var _player_character2 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter2")
@onready var _player_character3 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter3")


# We might be able to use this to halt execution until it is your turn
signal turn_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	update_player_team()
	pass
	
# update UI elements to match player team
func update_player_team():
	var player_character1 = _player_character1.get_children()
	print(player_character1)
	var player_character2 = _player_character2.get_children()
	var player_character3 = _player_character3.get_children()
	var player_team_ui = [player_character1, player_character2, player_character3]
	
	pass
