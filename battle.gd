extends TextureRect

var teamManager: TeamManager
var teamResource: TeamResource

var characterCounter = 0
var abilityCounter = 0
var validTargets
var activeCharacter
var activeAbility

@onready var enemyCharacter1Health = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam/EnemyCharacter1/EnemyPortrait1/Healthbar

# We might be able to use this to halt execution until it is your turn
signal turn_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	teamResource = TeamResource.new(30)
	teamManager = TeamManager.new()
	teamManager.setupTeams()
	
	var playerTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/PlayerTeam
	var enemyTeamUI = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/EnemyTeam
	
	# get nodes to assign team resource
	var playerTeamResource = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/PlayerPortrait/PlayerTeamResource
	var enemyTeamResource = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/EnemyPortrait/EnemyTeamResource
	playerTeamResource.text = "Resource: " + str(teamResource.currentResource) # assigns players resource
	
	for character in teamManager.playerTeam:
		print("Player character: ", character, " with Abilities: ", character.abilities)

	for character in teamManager.opponentTeam:
		print("Opponent character: ", character, " with Abilities: ", character.abilities)
		
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

func executeAbility(character, selectedAbility, target):
	if teamResource.consumeResource(selectedAbility.cost) and !selectedAbility.is_passive:
		target.health -= selectedAbility.damage
		updateHealth(enemyCharacter1Health, target)
		print(character.name, " used ", selectedAbility.name, " on ", target.name)
		print(target.name, "'s health is now ", target.health)
		activeCharacter = null
		activeAbility = null
	else:
		print("Not enough resource to use this ability or passive is selected!")

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
	if ability.targets_friendly and !ability.targets_enemy:
		# polish: highlight friendly portraits
		return teamManager.playerTeam
	elif ability.targets_friendly and ability.targets_enemy:
		# polish: highlight friendly and enemy portraits
		return [teamManager.playerTeam, teamManager.opponentTeam]
	else: 
		# polish: highlight enemy portraits
		return teamManager.opponentTeam

func isValidTarget(target):
	if target in validTargets:
		return true
	else:
		return false
	
func _on_char_1_ability_1_pressed():
	# print(teamManager.playerTeam[0].abilities[0].description)
	displayInfo(teamManager.playerTeam[0].abilities[0])
	# highlight and return valid targets
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[0])
	# assign active Character to the character's ability we selected
	activeCharacter = teamManager.playerTeam[0]
	activeAbility = teamManager.playerTeam[0].abilities[0]
	# need to set target based on target clicked
	
	print(teamManager.playerTeam[0].abilities[0].name, " can target: ", validTargets)

func _on_char_1_ability_2_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[1])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[1])
	activeCharacter = teamManager.playerTeam[1]
	activeAbility = teamManager.playerTeam[0].abilities[1]
	print(teamManager.playerTeam[0].abilities[1].name, " can target: ", validTargets)

func _on_char_1_ability_3_pressed():
	displayInfo(teamManager.playerTeam[0].abilities[2])
	validTargets = getValidTargets(teamManager.playerTeam[0].abilities[2])
	activeCharacter = teamManager.playerTeam[2]
	activeAbility = teamManager.playerTeam[0].abilities[2]
	print(teamManager.playerTeam[0].abilities[2].name, " can target: ", validTargets)
	
# clicking a portrait should probably set a target
func _on_enemy_portrait_1_pressed():
	if activeCharacter != null and isValidTarget(teamManager.opponentTeam[0]):
		executeAbility(activeCharacter, activeAbility, teamManager.opponentTeam[0])
	else:
		print("No active character")
	pass


func _on_char_1_portrait_pressed():
	if activeCharacter != null and isValidTarget(teamManager.playerTeam[1]):
		executeAbility(activeCharacter, activeAbility, teamManager.playerTeam[1])
	else:
		print("No active character or invalid target!")
