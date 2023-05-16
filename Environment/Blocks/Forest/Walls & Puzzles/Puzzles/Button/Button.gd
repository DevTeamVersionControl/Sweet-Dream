@tool
extends Area2D

signal on
signal off

@export var colour:int: set = set_colour

var bodies := 0
var on := false

func _on_Area2D_body_entered(body):
	if body.is_in_group("pushbutton"):
		if bodies < 0:
			bodies = 0
		bodies += 1
		emit_signal("on")
		on = true
		$Sprite2D.frame = 1 + colour * 2
		$Sprite2D.position.y = 0

func _on_Area2D_body_exited(body):
	if body.is_in_group("pushbutton"):
		bodies -= 1
		if bodies < 1:
			emit_signal("off")
			on = false
			$Sprite2D.frame = 0 + colour * 2
			$Sprite2D.position.y = -3

func set_colour(new_colour):
	colour = new_colour
	$Sprite2D.frame = 0 + colour * 2
	$Sprite2D.position.y = -3
