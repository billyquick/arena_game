#This script will handle the setup and management of character teams
extends Node

class_name TeamManager

var playerTeam: Array
var opponentTeam: Array

const Goblin = preload("res://characters/goblin/goblin.tres")

func _init():
	playerTeam = []
	opponentTeam = []

func addCharacterToPlayerTeam(character: Character):
	playerTeam.append(character)

func addCharacterToOpponentTeam(character: Character):
	opponentTeam.append(character)

func setupTeams():
	var playerCharacter1 = Character.new(Goblin)
	var playerCharacter2 = Character.new(Goblin)
	var playerCharacter3 = Character.new(Goblin)
	var enemyCharacter1 = Character.new(Goblin)
	var enemyCharacter2 = Character.new(Goblin)
	var enemyCharacter3 = Character.new(Goblin)
	
	playerTeam = [playerCharacter1, playerCharacter2, playerCharacter3]
	opponentTeam = [enemyCharacter1, enemyCharacter2, enemyCharacter3]
	
	# Create characters, abilities, and add them to teams here
	# Example:
	
	
	"""var playerCharacter1 = Character.new("Burn", 900)
	var fireball = Ability.new("Fireball", 30, 10)
	var fireblast = Ability.new("Fireblast", 50, 30)
	var passive = Ability.new("Passive", 10, 0)
	playerCharacter1.add_ability(fireball)
	playerCharacter1.add_ability(fireblast)
	playerCharacter1.add_ability(passive)
	addCharacterToPlayerTeam(playerCharacter1)
	
	var playerCharacter2 = Character.new("Deez", 420)
	var fireball2 = Ability.new("Ice Strike", 30, 10)
	var fireblast2 = Ability.new("Smash", 50, 30)
	var passive2 = Ability.new("Crush", 10, 0)
	playerCharacter2.add_ability(fireball2)
	playerCharacter2.add_ability(fireblast2)
	playerCharacter2.add_ability(passive2)
	addCharacterToPlayerTeam(playerCharacter2)
	
	var playerCharacter3 = Character.new("Nuts", 69)
	var fireball3 = Ability.new("Mind", 30, 10)
	var fireblast3 = Ability.new("Goblin", 50, 30)
	var passive3 = Ability.new("Deez", 10, 0)
	playerCharacter3.add_ability(fireball3)
	playerCharacter3.add_ability(fireblast3)
	playerCharacter3.add_ability(passive3)
	addCharacterToPlayerTeam(playerCharacter3)

	var opponentCharacter = Character.new("Swarm", 1000)
	var sting = Ability.new("Sting", 10, 10)
	var returnToHive = Ability.new("Return to Hive", 0, 10)
	var hiveMind = Ability.new("Hive Mind", 0, 50)
	opponentCharacter.add_ability(sting)
	opponentCharacter.add_ability(returnToHive)
	opponentCharacter.add_ability(hiveMind)
	addCharacterToOpponentTeam(opponentCharacter)
"""
