extends Node2D
class_name Modifiers

var modName: String
var max_health: int
var health: int
var armor: int
var cost: int
var targets: int
var cooldown: int
var damage: int
var attack_hits: int
var duration_ability: int
var duration_turn: int
var icon: Texture

# Constructor
func _init(modifier: Resource):
	self.modName = modifier.name
	self.max_health = modifier.max_health
	self.health = modifier.health
	self.armor = modifier.armor
	self.cost = modifier.cost
	self.targets = modifier.targets
	self.cooldown = modifier.cooldown
	self.damage = modifier.damage
	self.attack_hits = modifier.attack_hits
	self.duration_ability = modifier.duration_ability
	self.duration_turn = modifier.duration_turn
	self.icon = modifier.icon
