#This script will handle the setup and management of character teams
extends Node

class_name TeamManager

var playerTeam: Array
var opponentTeam: Array

const Goblin = preload("res://characters/goblin/goblin.tres")
const FrostMage = preload("res://characters/frost_mage/frost_mage.tres")
const Swarm = preload("res://characters/swarm/swarm.tres")

func _init():
	playerTeam = []
	opponentTeam = []

func addCharacterToPlayerTeam(character: Character):
	playerTeam.append(character)

func addCharacterToOpponentTeam(character: Character):
	opponentTeam.append(character)

func setupTeams():
	var playerCharacter1 = Character.new(Goblin)
	var playerCharacter2 = Character.new(FrostMage)
	var playerCharacter3 = Character.new(Swarm)
	var enemyCharacter1 = Character.new(FrostMage)
	var enemyCharacter2 = Character.new(Goblin)
	var enemyCharacter3 = Character.new(Goblin)
	
	playerTeam = [playerCharacter1, playerCharacter2, playerCharacter3]
	opponentTeam = [enemyCharacter1, enemyCharacter2, enemyCharacter3]
	
func getTeam(character: Character):
	# return the team array for the team the character is on
	for characters in opponentTeam:
		if character == characters:
			return opponentTeam
		else:
			return playerTeam
