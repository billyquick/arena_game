extends Node2D

class_name Ability

var abilityName: String
var damage: int
var cost: int

# Constructor
func _init(name: String, damage: int, cost: int):
	self.name = name
	self.damage = damage
	self.cost = cost
