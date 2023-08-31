extends Node2D

class_name Ability

var abilityName: String
var damage: int
var cost: int
var description: String
var targets: int
var cooldown: int
var attack_hits: int
var targets_friendly: bool
var targets_enemy: bool
var is_passive: bool 
var is_useable: bool 
var applies_modifier: bool
var icon: Texture

# Constructor
func _init(ability: Resource):
	self.name = ability.name
	self.damage = ability.damage
	self.cost = ability.cost
	self.description = ability.description
	self.targets = ability.targets
	self.cooldown = ability.cooldown
	self.attack_hits = ability.attack_hits
	self.targets_friendly = ability.targets_friendly
	self.targets_enemy = ability.targets_enemy
	self.is_passive = ability.is_passive
	self.is_useable = ability.is_useable
	self.applies_modifier = ability.applies_modifier
	self.icon = ability.icon
