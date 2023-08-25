extends Node2D
class_name Character

const Ability = preload("res://characters/abilities.gd")

var charName: String
var health: int
var max_health: int
var abilities: Array
var teamResource: TeamResource
var portrait: Texture

# Constructor
func _init(character: Resource):
	self.name = character.name
	self.max_health = character.max_health
	self.health = character.max_health
	self.abilities = character.abilities
	self.portrait = character.portrait

func add_ability(ability: Ability):
	abilities.append(ability)

func useAbility(selected_ability: Ability, target: Character):
	if teamResource.consumeResource(selected_ability.cost):
		target.take_damage(selected_ability.damage)
	else:
		print("Not enough team resource to use this ability!")


func _on_pressed():
	pass # Replace with function body.
