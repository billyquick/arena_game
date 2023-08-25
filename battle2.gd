extends TextureRect

@onready var _player_character1 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter1")
@onready var _player_character2 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter2")
@onready var _player_character3 = get_node("MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter3")

var teamManager: TeamManager
var teamResource: TeamResource

var characterCounter = 0
var abilityCounter = 0

# We might be able to use this to halt execution until it is your turn
signal turn_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	teamResource = TeamResource.new(100)
	teamManager = TeamManager.new()
	teamManager.setupTeams()
	
	var playerTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam
	var enemyTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam
	
	for character in teamManager.playerTeam:
		print("Player character: ", character.name, " with Abilities: ", character.abilities)

	for character in teamManager.opponentTeam:
		print("Opponent character: ", character.name, " with Abilities: ", character.abilities)
		
	updateTeamUI(playerTeamUI, teamManager.playerTeam)
	updateTeamUI(enemyTeamUI, teamManager.opponentTeam)
		

func updateTeamUI(UIContainer, team):
	# all of the process functions here are only using teamManager.playerTeam - need to fix this
	processProgressBars(UIContainer, team)
	characterCounter = 0
	processPortraits(UIContainer, team)
	characterCounter = 0
	processAbilities(UIContainer, team)
	characterCounter = 0
		
	pass

func executeAbility(character: Character, selectedAbility: Ability, target: Character):
	if teamResource.consumeResource(selectedAbility.cost):
		character.useAbility(selectedAbility, target)
		print(character.name, " used ", selectedAbility.abilityName, " on ", target.name)
	else:
		print("Not enough team resource to use this ability!")

func _on_TargetClicked(targetCharacter: Character):
	# Determine which ability was being used (based on the ability selection process)
	# Call executeAbility with the appropriate arguments
	# executeAbility(activeCharacter, selectedAbility, targetCharacter)
	pass

# Determine what information to show in the Info Panel
func displayInfo(target):
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MainInfoPanel/Label.text = target.description % [target.name, target.damage, target.targets, target.cost, target.cooldown]
	pass

# Update health bars as the game begins
func updateHealth(health_bar, Character):
	health_bar.max_value = Character.max_health
	health_bar.value = Character.health
	health_bar.get_node("HealthTracker").text = "HP: %d/%d" % [Character.health, Character.max_health]
	
# Update Portrait for the character
func assignCharacter(char_portrait, Character):
	# wanted to make a function that would rotate the portrait 
	if Character in teamManager.playerTeam:
		if Character.is_portrait_oriented_left:
			char_portrait.set_texture_normal(Character.portrait)
			char_portrait.flip_h = true
	else:
		char_portrait.set_texture_normal(Character.portrait)
	
# assign UI to Ability buttons
func assignAbilities(char_ability, Character):
	char_ability.text = Character.abilities[abilityCounter].name
	if Character.abilities[abilityCounter].is_passive == true:
		char_ability.disabled = true
	
	# Characters have a maximum of 3 abilities by design
	# This will break if/when a character is designed without exactly 3 abilities
	if abilityCounter < 2:
		abilityCounter += 1
	else:
		# Only start adding the next Char's abilities when we finish the previous
		characterCounter += 1
		abilityCounter = 0
	pass
	
# update health bars for a character recursively
func processProgressBars(node: Node, team):
	for child in node.get_children():
		if child is ProgressBar:
			var progressBar = child as ProgressBar
			updateHealth(progressBar, team[characterCounter])  # Set the healthbar value
			characterCounter = characterCounter + 1

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processProgressBars(child, team)
			
# update portraits for a character recursively
func processPortraits(node: Node, team):
	for child in node.get_children():
		if child is TextureButton:
			var portrait = child as TextureButton
			if portrait.name.contains("Portrait") == true:
				assignCharacter(portrait, team[characterCounter])  # Set the portrait name/texture
				characterCounter = characterCounter + 1

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processPortraits(child, team)
			
# update abilities for a character recursively
func processAbilities(node: Node, team):
	for child in node.get_children():
		if child is Button:
			var ability = child as Button
			if ability.text.contains("Ability") == true:
				assignAbilities(ability, team[characterCounter])  # Set the ability name/texture

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processAbilities(child, team)


func _on_char_1_ability_1_pressed():
	# print(teamManager.playerTeam[0].abilities[0].description)
	displayInfo(teamManager.playerTeam[0].abilities[0])
	# executeAbility(teamManager.playerTeam[0].abilities[0])
	pass # Replace with function body.


func _on_char_1_ability_2_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[1])
	pass # Replace with function body.
