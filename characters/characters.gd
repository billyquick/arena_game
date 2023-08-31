extends Node2D
class_name Character

const Ability = preload("res://characters/abilities.gd")
const Modifiers = preload("res://character_modifiers.gd")

var charName: String
var health: int
var max_health: int
var abilities: Array
var teamResource: TeamResource
var portrait: Texture
var modifiers: Array

# Constructor
func _init(character: Resource):
	self.name = character.name
	self.max_health = character.max_health
	self.health = character.max_health
	self.abilities = character.abilities
	self.portrait = character.portrait
	self.modifiers = character.modifiers

func add_ability(ability: Ability):
	abilities.append(ability)

func add_modifier(modifier: Modifiers):
	modifiers.append(modifier)
