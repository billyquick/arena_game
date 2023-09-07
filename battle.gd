extends TextureRect

var teamManager: TeamManager
var playerResource: TeamResource
var enemyResource: TeamResource
var rng = RandomNumberGenerator.new()

var characterCounter = 0
var abilityCounter = 0
var validTargets
var activeCharacter
var activeAbility
# TODO: for each client, need to mirror the screens so I only to need code one side
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
	playerResource = TeamResource.new(100)
	enemyResource = TeamResource.new(40)
	teamManager = TeamManager.new()
	teamManager.setupTeams()
	
	playerTeamResource.text = "Resource: " + str(playerResource.currentResource) # assigns players resource
	enemyTeamResource.text = "Resource: " + str(enemyResource.currentResource) # assigns enemy resource
	
	for character in teamManager.playerTeam:
		print("Player character: ", character.charName, character, " with Abilities: ", character.abilities)

	for character in teamManager.opponentTeam:
		print("Opponent character: ", character.charName, character, " with Abilities: ", character.abilities)
		
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

func executeAbility(character, selectedAbility, target):
	# insulating passives
	var additionalCosts = 0
	if activeCharacter != null:
		additionalCosts += getCost(activeCharacter.modifiers)
	# TODO: change player resource to check whose turn it is
	if playerResource.consumeResource(selectedAbility.cost, additionalCosts):
		if target is Array:
			for enemy in target:
				enemy.health -= selectedAbility.damage
				print(character.charName, " used ", selectedAbility.abilityName, " on ", enemy.charName, ". ", enemy.charName, "'s health is now ", enemy.health)
		else:
			target.health -= selectedAbility.damage
			print(character.charName, " used ", selectedAbility.abilityName, " on ", target.charName, ". ", target.charName, "'s health is now ", target.health)
		# apply modifiers
		if selectedAbility.applies_modifier:
			# for each modifier the ability applies, create a new one and apply it to the target
			for uniqueModifier in selectedAbility.modifiers:
				var modifier = Modifiers.new(uniqueModifier)
				# increase existing modifiers duration, rather than having multiple modifiers of the same type
				if target is Array:
					for enemy in target:
						if !enemy.modifiers.is_empty():
							for modifiers in enemy.modifiers:
								if modifiers.modName == modifier.modName:
									print("Found existing modifier. Incrementing duration of ", modifier.modName)
									modifiers.duration_ability += modifier.duration_ability
									modifiers.duration_turn += modifier.duration_turn
								else: 
									enemy.add_modifier(modifier)
						else: 
							enemy.add_modifier(modifier)
						print("Applying modifier ", modifier.modName, modifier, " to target ", enemy.charName, enemy)
				else:
					if !target.modifiers.is_empty():
						for modifiers in target.modifiers:
							if modifiers.modName == modifier.modName:
								print("Found existing modifier. Incrementing duration of ", modifier.modName)
								modifiers.duration_ability += modifier.duration_ability
								modifiers.duration_turn += modifier.duration_turn
							else: 
								target.add_modifier(modifier)
					else: 
						target.add_modifier(modifier)
					print("Applying modifier ", modifier.modName, modifier, " to target ", target.charName, target)
		
		# reduce duration of modifiers that apply on ability use
		var modifierCounter = 0
		for uniqueModifiers in character.modifiers:
			if uniqueModifiers.duration_ability > 0:
				uniqueModifiers.duration_ability -= 1
				print(uniqueModifiers.name, " duration reduced to: ", uniqueModifiers.duration_ability)
				# if the duration has ended, need to remove it from the character's modifier list
				if uniqueModifiers.duration_ability  == 0 and uniqueModifiers.duration_turn  == 0:
					character.modifiers.remove_at(modifierCounter)
					print(uniqueModifiers.name, " modifier has been removed from ", character.charName, "'s modifiers")
			modifierCounter += 1
		
		# wrap up
		activeCharacter = null
		activeAbility = null
		updateResource()
		resetAnimations(bothTeamUI)
		updateTeamUI(playerTeamUI, teamManager.playerTeam)
		updateTeamUI(enemyTeamUI, teamManager.opponentTeam)
		
		# debug
		for x in teamManager.playerTeam:
			print("Player character: ", x.charName, x, " with health: ", x.health, " with Modifiers: ", x.modifiers)
		for x in teamManager.opponentTeam:
			print("Enemy character: ", x.charName, x, " with health: ", x.health, " with Modifiers: ", x.modifiers)
	else:
		# Flash resource red so it should be obvious why you can't use the ability
		$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/PlayerPortrait/PlayerTeamResource/AnimationPlayer.play("low_resource")
		print("Not enough resource to use this ability")

# checks for additional costs based on modifiers
func getCost(modifiers):
	var additionalCost = 0
	# go through each modifier applied to a character
	for x in modifiers:
		additionalCost += x.cost
	return additionalCost
	
# Determine what information to show in the Info Panel
func displayInfo(target):
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MainInfoPanel/Label.text = target.description % [target.abilityName, target.damage, target.targets, target.cost, target.cooldown]

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
	char_ability.text = Character.abilities[abilityCounter].abilityName
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
	# target passes an array of objects (one team) or an array of arrays (both teams)
	if target in validTargets:
		return true
	elif validTargets.size() == 2:
		if (target in validTargets[0]) or (target in validTargets[1]):
			return true
	else:
		return false
	
func _on_char_1_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[0]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam)
		else:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[0])
	else:
		print("No active character or invalid target!")
		
func _on_char_1_ability_1_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[0])
	# highlight and return valid targets
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[0])
	# assign active Character to the character's ability we selected
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[0]
	print(teamManager.playerTeam[0].abilities[0].abilityName, " can target: ", validTargets)

func _on_char_1_ability_2_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[1])
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[1]
	print(teamManager.playerTeam[0].abilities[1].abilityName, " can target: ", validTargets)

func _on_char_1_ability_3_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[2])
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[2]
	print(teamManager.playerTeam[0].abilities[2].abilityName, " can target: ", validTargets)
	
func _on_char_2_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[1]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam)
		else:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[1])
	else:
		print("No active character or invalid target!")
		
func _on_char_2_ability_1_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[0])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[0])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[0]
	print(teamManager.playerTeam[1].abilities[0].abilityName, " can target: ", validTargets)

func _on_char_2_ability_2_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[1])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[1]
	print(teamManager.playerTeam[1].abilities[1].abilityName, " can target: ", validTargets)
	
func _on_char_2_ability_3_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[2])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[2]
	print(teamManager.playerTeam[1].abilities[2].abilityName, " can target: ", validTargets)
		
func _on_char_3_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[2]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam)
		else:
			executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[2])
	else:
		print("No active character or invalid target!")
		
func _on_char_3_ability_1_pressed():
	displayInfo(teamManager.playerTeam[2].abilities[0])
	validTargets = getValidTargets(teamManager.playerTeam[2].abilities[0])
	activeCharacter = teamManager.playerTeam[2]
	activeAbility = teamManager.playerTeam[2].abilities[0]
	print(teamManager.playerTeam[2].abilities[0].abilityName, " can target: ", validTargets)
	
func _on_char_3_ability_2_pressed():
	displayInfo(teamManager.playerTeam[2].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[2].abilities[1])
	activeCharacter = teamManager.playerTeam[2]
	activeAbility = teamManager.playerTeam[2].abilities[1]
	print(teamManager.playerTeam[2].abilities[1].abilityName, " can target: ", validTargets)

func _on_char_3_ability_3_pressed():
	displayInfo(teamManager.playerTeam[1].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[1].abilities[2])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[1].abilities[2]
	print(teamManager.playerTeam[2].abilities[2].abilityName, " can target: ", validTargets)

## ENEMY
func _on_enemy_portrait_1_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[0]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam)
		else: 
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[0])
	else:
		print("No active character")

func _on_enemy_2_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[1]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam)
		else:
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[1])
	else:
		print("No active character")

func _on_enemy_3_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[2]):
		if activeAbility.targets == 3:
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam)
		else:
			executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[2])
	else:
		print("No active character")

func executePassive(character, ability):
	if ability.targets_random:
		var target
		var random_team = rng.randf_range(0, 1)
		var healthbar
		if random_team < 0.5:
			target = teamManager.playerTeam.pick_random()
			if target == teamManager.playerTeam[0]:
				healthbar = playerCharacter1Health
				print("picked playerTeam, member 0")
			elif target == teamManager.playerTeam[1]:
				healthbar = playerCharacter2Health
				print("picked playerTeam, member 1")
			else: 
				healthbar = playerCharacter3Health
				print("picked playerTeam, member 2")
		else: 
			target = teamManager.opponentTeam.pick_random()
			if target == teamManager.opponentTeam[0]:
				healthbar = enemyCharacter1Health
				print("picked opponentTeam, member 0")
			elif target == teamManager.opponentTeam[1]:
				healthbar = enemyCharacter2Health
				print("picked opponentTeam, member 1")
			else: 
				healthbar = enemyCharacter3Health
				print("picked opponentTeam, member 2")
		
		executeAbility(character, ability, target)
	
# What to do when the turn ends
func _on_player_portrait_pressed():
	# process passives that trigger end of turn
	if turnTracker.back() == "playerTurn":
		# clear actives if the turn is ending
		activeAbility = null
		activeCharacter = null
		for characters in teamManager.playerTeam:
			for ability in characters.abilities:
				# using -1 as a way to indicate a passive triggers EOT
				if ability.is_passive and ability.cooldown == -1:
					executePassive(characters, ability)
		# if it's the player's turn, make it the enemy's turn
		turnTracker.append("enemyTurn")
		print(turnTracker)
	else: 
		pass
	
func _on_enemy_1_ability_1_pressed():
	displayInfo(teamManager.opponentTeam[0].abilities[0])

func _on_enemy_1_ability_2_pressed():
	displayInfo(teamManager.opponentTeam[0].abilities[1])

func _on_enemy_1_ability_3_pressed():
	displayInfo(teamManager.opponentTeam[0].abilities[2])

func _on_enemy_2_ability_1_pressed():
	displayInfo(teamManager.opponentTeam[1].abilities[0])

func _on_enemy_2_ability_2_pressed():
	displayInfo(teamManager.opponentTeam[1].abilities[1])

func _on_enemy_2_ability_3_pressed():
	displayInfo(teamManager.opponentTeam[1].abilities[2])

func _on_enemy_3_ability_1_pressed():
	displayInfo(teamManager.opponentTeam[2].abilities[0])

func _on_enemy_3_ability_2_pressed():
	displayInfo(teamManager.opponentTeam[2].abilities[1])

func _on_enemy_3_ability_3_pressed():
	displayInfo(teamManager.opponentTeam[2].abilities[2])
