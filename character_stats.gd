extends Resource
class_name CharacterStats

@export var name: String = "default"
@export var max_health: int = 1000
@export var health: int = 1000
@export var abilities: Array = []
@export var buffs: Array = []
@export var debuffs: Array = []

@export var is_portrait_oriented_left: bool = true #useful to orient portraits facing each other. Polish feature
@export var portrait: Texture
