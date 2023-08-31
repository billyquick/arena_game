extends Resource
class_name CharacterAbilities

@export var name: String = "Ability"
@export var description: String = ""
@export var cost: int = 0
@export var targets: int = 1
@export var cooldown: int = 0
@export var damage: int = 0
@export var attack_hits: int = 1
@export var targets_friendly: bool = false
@export var targets_enemy: bool = true
@export var is_passive: bool = false
@export var is_useable: bool = true # if ability is on cooldown, a passive, or can also use when a character is stunned
@export var applies_modifier: bool = false
@export var modifiers: Array = []
@export var icon: Texture = null
