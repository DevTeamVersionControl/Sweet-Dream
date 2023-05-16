@tool
extends StaticBody2D

@export var trigger : NodePath
@export var colour : int: set = set_colour

@onready var trigger_obj = get_node(trigger)

func _ready():
	if trigger_obj:
		trigger_obj.connect("on", Callable(self, "on_trigger_on"))
		if trigger_obj.has_signal("off"):
			trigger_obj.connect("off", Callable(self, "on_trigger_off"))

func on_trigger_on():
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false

func on_trigger_off():
	$CollisionShape2D.set_deferred("disabled", false)
	$Sprite2D.visible = true

func set_colour(new_colour):
	colour = new_colour
	$Sprite2D.frame = colour
