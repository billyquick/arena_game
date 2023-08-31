# This script will handle the setup and management of team resource
extends Node

class_name TeamResource

var maxResource: int
var currentResource: int

func _init(maxResource: int):
	self.maxResource = maxResource
	self.currentResource = maxResource

func addResource(amount: int):
	currentResource = min(currentResource + amount, maxResource)

func consumeResource(amount: int, modifier: int) -> bool:
	if currentResource >= (amount + modifier):
		currentResource -= (amount + modifier)
		return true
	return false

func getCurrentResource() -> int:
	return currentResource

func getMaxResource() -> int:
	return maxResource
