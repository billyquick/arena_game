extends Node2D
class_name Character

const Ability = preload("res://characters/abilities.gd")

var charName: String
var health: int
var max_health: int
var abilities: Array
var teamResource: TeamResource

# Constructor
func _init(name: String, max_health: int):
	self.name = name
	self.max_health = max_health
	self.health = max_health
	self.abilities = []

func add_ability(ability: Ability):
	abilities.append(ability)

func useAbility(selected_ability: Ability, target: Character):
	if teamResource.consumeResource(selected_ability.cost):
		target.take_damage(selected_ability.damage)
	else:
		print("Not enough team resource to use this ability!")


func _on_pressed():
	pass # Replace with function body.
