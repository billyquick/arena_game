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
	
