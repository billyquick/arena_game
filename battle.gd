extends Node2D

const Character = preload("res://characters/characters.gd")
const Ability = preload("res://characters/abilities.gd")

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
	
	var progressBarContainer = $playerTeamContainer

	# Find and process all progress bars recursively
	processProgressBars(progressBarContainer)
	characterCounter = 0
	processPortraits(progressBarContainer)
	characterCounter = 0
	processAbilities(progressBarContainer)
	
	for character in teamManager.playerTeam:
		print("Player character: ", character.name, " with Abilities: ", character.abilities)

	for character in teamManager.opponentTeam:
		print("Opponent character: ", character.name, " with Abilities: ", character.abilities)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_char_1_ability_1_pressed():
	print("char1_ability1 button pressed")
	pass # Replace with function body.

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


func _on_player_char_2_pressed():
	print("playerChar2 pressed")
	pass # Replace with function body.

# Determine which character is the activeCharacter
func setFocus(selectedAbility: Ability):
	pass

# Determine what information to show in the Info Panel
func displayInfo(target):
	$RichTextLabel.text = target
	pass

# Update health bars as the game begins
func updateHealth(health_bar, Character):
	health_bar.max_value = Character.max_health
	health_bar.value = Character.health
	health_bar.get_node("Label").text = "HP: %d/%d" % [Character.health, Character.max_health]
	
func assignCharacter(char_portrait, Character):
	char_portrait.text = Character.name
	
func assignAbilities(char_ability, Character):
	char_ability.text = Character.abilities[abilityCounter].name
	
	# Characters have a maximum of 3 abilities by design
	if abilityCounter < 2:
		abilityCounter += 1
	else:
		# Only start adding the next Char's abilities when we finish the previous
		characterCounter += 1
		abilityCounter = 0
	pass
	
func processProgressBars(node: Node):
	for child in node.get_children():
		if child is ProgressBar:
			var progressBar = child as ProgressBar
			updateHealth(progressBar, teamManager.playerTeam[characterCounter])  # Set the healthbar value
			characterCounter = characterCounter + 1

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processProgressBars(child)
			
func processPortraits(node: Node):
	for child in node.get_children():
		if child is Button:
			var portrait = child as Button
			if portrait.text.contains("Portrait") == true:
				assignCharacter(portrait, teamManager.playerTeam[characterCounter])  # Set the portrait name/texture
				characterCounter = characterCounter + 1

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processPortraits(child)
			
func processAbilities(node: Node):
	for child in node.get_children():
		if child is Button:
			var ability = child as Button
			if ability.text.contains("Ability") == true:
				assignAbilities(ability, teamManager.playerTeam[characterCounter])  # Set the ability name/texture

		# Check if the child has children and process them recursively
		if child.get_child_count() > 0:
			processAbilities(child)
