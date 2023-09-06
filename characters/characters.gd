extends Node2D
class_name Character

var charName: String
var health: int
var max_health: int
var abilities: Array
var portrait: Texture
var modifiers: Array

# Constructor
func _init(character: Resource):
	self.charName = character.name
	self.max_health = character.max_health
	self.health = character.max_health
	for abilities in character.abilities:
		self.abilities.append(Ability.new(abilities))
	self.portrait = character.portrait
	self.modifiers = character.modifiers

func add_ability(ability: Ability):
	abilities.append(ability)

func add_modifier(modifier: Modifiers):
	modifiers.append(modifier)
