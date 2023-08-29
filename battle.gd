extends TextureRect

var teamManager: TeamManager
var playerResource: TeamResource
var enemyResource: TeamResource

var characterCounter = 0
var abilityCounter = 0
var validTargets
var activeCharacter
var activeAbility
var turnTracker: Array

@onready var enemyCharacter1Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter1/Enemy1Portrait/Healthbar
@onready var enemyCharacter2Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter2/Enemy2Portrait/Healthbar
@onready var enemyCharacter3Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter3/Enemy3Portrait/Healthbar
@onready var playerCharacter1Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter1/Char1Portrait/Healthbar
@onready var playerCharacter2Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter2/Char2Portrait/Healthbar
@onready var playerCharacter3Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter3/Char3Portrait/Healthbar
@onready var playerTeamResource = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/PlayerPortrait/PlayerTeamResource
@onready var enemyTeamResource = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/EnemyPortrait/EnemyTeamResource
@onready var playerTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam
@onready var enemyTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam
@onready var bothTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer

# We might be able to use this to halt execution until it is your turn
signal turn_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	playerResource = TeamResource.new(30)
	enemyResource = TeamResource.new(40)
	teamManager = TeamManager.new()
	teamManager.setupTeams()
	
	playerTeamResource.text = "Resource: " + str(playerResource.currentResource) # assigns players resource
	enemyTeamResource.text = "Resource: " + str(enemyResource.currentResource) # assigns enemy resource
	
	for character in teamManager.playerTeam:
		print("Player character: ", character, " with Abilities: ", character.abilities)

	for character in teamManager.opponentTeam:
		print("Opponent character: ", character, " with Abilities: ", character.abilities)
		
	updateTeamUI(playerTeamUI, teamManager.playerTeam)
	updateTeamUI(enemyTeamUI, teamManager.opponentTeam)
	
	# can use to count number of total turns and each players turns
	turnTracker.append("playerTurn")

func updateTeamUI(UIContainer, team):
	# all of the process functions here are only using teamManager.playerTeam - need to fix this
	processProgressBars(UIContainer, team)
	characterCounter = 0
	processPortraits(UIContainer, team)
	characterCounter = 0
	processAbilities(UIContainer, team)
	characterCounter = 0

func updateResource():
	#TODO: check whose turn it is 
	playerTeamResource.text = "Resource: " + str(playerResource.currentResource)

func executeAbility(character, selectedAbility, target, healthbar):
	# TODO: change player resource to check whose turn it is
	if playerResource.consumeResource(selectedAbility.cost):
		target.health -= selectedAbility.damage
		updateHealth(healthbar, target) # TO DO
		print(character.name, " used ", selectedAbility.name, " on ", target.name)
		print(target.name, "'s health is now ", target.health)
		activeCharacter = null
		activeAbility = null
		updateResource()
		resetAnimations(bothTeamUI)
	else:
		# Flash resource red so it should be obvious why you can't use the ability
		$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/PlayerPortrait/PlayerTeamResource/AnimationPlayer.play("low_resource")
		print("Not enough resource to use this ability")

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
	char_portrait.set_texture_normal(Character.portrait)
	
# assign UI to Ability buttons
func assignAbilities(char_ability, Character):
	char_ability.text = Character.abilities[abilityCounter].name
	if Character.abilities[abilityCounter].is_passive == true:
		char_ability.flat = true
	
	# Characters have a maximum of 3 abilities by design
	# This will break if/when a character is designed without exactly 3 abilities
	if abilityCounter < 2:
		abilityCounter += 1
	else:
		# Only start adding the next Char's abilities when we finish the previous
		characterCounter += 1
		abilityCounter = 0
	
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
	
# called when an ability is pressed. Returns team(s) that contain valid targets
func getValidTargets(ability):
	resetAnimations(bothTeamUI)
	if ability.targets_friendly and !ability.targets_enemy:
		# polish: highlight friendly portraits
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter1/Char1Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter2/Char2Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter3/Char3Portrait/AnimationPlayer.play("valid_target")
		return teamManager.playerTeam
	elif ability.targets_friendly and ability.targets_enemy:
		# polish: highlight friendly and enemy portraits
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter1/Char1Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter2/Char2Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam/PlayerCharacter3/Char3Portrait/AnimationPlayer.play("valid_target")
		
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter1/Enemy1Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter2/Enemy2Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter3/Enemy3Portrait/AnimationPlayer.play("valid_target")
		return [teamManager.playerTeam, teamManager.opponentTeam]
	else: 
		# polish: highlight enemy portraits
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter1/Enemy1Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter2/Enemy2Portrait/AnimationPlayer.play("valid_target")
		$MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter3/Enemy3Portrait/AnimationPlayer.play("valid_target")
		return teamManager.opponentTeam

func resetAnimations(node: Node):
	for child in node.get_children():
		if child is AnimationPlayer:
			var player = child as AnimationPlayer
			player.play("RESET")
		
		if child.get_child_count() > 0:
			resetAnimations(child)

func isValidTarget(target):
	if target in validTargets:
		return true
	else:
		return false
	
func _on_char_1_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[0]):
		executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[0], playerCharacter1Health)
	else:
		print("No active character or invalid target!")
		
func _on_char_1_ability_1_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[0])
	# highlight and return valid targets
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[0])
	# assign active Character to the character's ability we selected
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[0]
	
	print(teamManager.playerTeam[0].abilities[0].name, " can target: ", validTargets)

func _on_char_1_ability_2_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[1])
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[1]
	print(teamManager.playerTeam[0].abilities[1].name, " can target: ", validTargets)

func _on_char_1_ability_3_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[2])
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[2]
	print(teamManager.playerTeam[0].abilities[2].name, " can target: ", validTargets)
	
func _on_char_2_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[1]):
		executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[1], playerCharacter2Health)
	else:
		print("No active character or invalid target!")
		
func _on_char_2_ability_1_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[0])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[0])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[0]
	print(teamManager.playerTeam[1].abilities[0].name, " can target: ", validTargets)

func _on_char_2_ability_2_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[1])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[1]
	print(teamManager.playerTeam[1].abilities[1].name, " can target: ", validTargets)
	
func _on_char_2_ability_3_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[2])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[2]
	print(teamManager.playerTeam[1].abilities[2].name, " can target: ", validTargets)
		
func _on_char_3_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[2]):
		executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[2], playerCharacter3Health)
	else:
		print("No active character or invalid target!")
		
func _on_char_3_ability_1_pressed():
	displayInfo(teamManager.playerTeam[2].abilities[0])
	validTargets = getValidTargets(teamManager.playerTeam[2].abilities[0])
	activeCharacter = teamManager.playerTeam[2]
	activeAbility = teamManager.playerTeam[2].abilities[0]
	print(teamManager.playerTeam[2].abilities[0].name, " can target: ", validTargets)
	
func _on_char_3_ability_2_pressed():
	displayInfo(teamManager.playerTeam[2].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[2].abilities[1])
	activeCharacter = teamManager.playerTeam[2]
	activeAbility = teamManager.playerTeam[2].abilities[1]
	print(teamManager.playerTeam[2].abilities[1].name, " can target: ", validTargets)

func _on_char_3_ability_3_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[2])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[2]
	print(teamManager.playerTeam[1].abilities[2].name, " can target: ", validTargets)

## ENEMY
func _on_enemy_portrait_1_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[0]):
		executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[0], enemyCharacter1Health)
	else:
		print("No active character")

func _on_enemy_2_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[1]):
		executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[1], enemyCharacter2Health)
	else:
		print("No active character")

func _on_enemy_3_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[2]):
		executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[2], enemyCharacter3Health)
	else:
		print("No active character")

# What to do when the turn ends
func _on_player_portrait_pressed():
	# if it's the player's turn, make it the enemy's turn
	if turnTracker.back() == "playerTurn":
		turnTracker.append("enemyTurn")
		print(turnTracker)
	else:
		pass
