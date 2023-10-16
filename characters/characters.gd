extends Node2D
class_name Character

var charName: String
var health: int
var max_health: int
var is_dead: bool
var abilities: Array
var portrait: Texture
var modifiers: Array

# Constructor
func _init(character: Resource):
	self.charName = character.name
	self.max_health = character.max_health
	self.health = character.max_health
	self.is_dead = character.is_dead
	# create ability objects if we want to edit individual character abilities with modifiers
	for abilities in character.abilities:
		self.abilities.append(Ability.new(abilities))
	self.portrait = character.portrait
	# characters are a resource, so we need to duplicate modifiers so the reference is new per character
	self.modifiers = character.modifiers.duplicate()

func add_ability(ability: Ability):
	abilities.append(ability)

func add_modifier(modifier: Modifiers):
	modifiers.append(modifier)
