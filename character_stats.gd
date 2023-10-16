extends Resource
class_name CharacterStats

@export var name: String = "default"
@export var max_health: int = 1000
@export var health: int = 1000
@export var is_dead: bool = false
@export var abilities: Array = []
@export var modifiers: Array = []
@export var portrait: Texture = null
@export var armor: int = 0
