extends Sprite2D

@onready var animation_player = $AnimationPlayer

var player_is_in_zone := false
var in_dialog := false

func _ready():
	animation_player.play("Idle")
	get_tree().current_scene.gui.dialog.connect("talk", Callable(self, "on_talk"))
	get_tree().current_scene.gui.dialog.connect("shop", Callable(self, "on_shop"))
	get_tree().current_scene.gui.dialog.connect("increment_story_point", increment_story_point)

func _unhandled_input(_event):
	if player_is_in_zone && Input.is_action_just_pressed("interact") && not get_tree().paused:
		get_tree().current_scene.start_dialog("res://UserInterface/Dialog/Json/DeadGuy.json", get_dialog_num())
		in_dialog = true
		await get_tree().current_scene.gui.dialog.dialog_end
		in_dialog = false

func on_talk():
	if in_dialog:
		animation_player.play("Speak")

func increment_story_point(story_point : int):
	match story_point:
		0:
			GlobalVars.add_to_inventory({"Name":"Jelly Bean","Ammo":null, "Icon":"res://Pickups/Jelly Bean 720p.png", "Description":"Bouncy and destructive"})
			GlobalVars.add_to_inventory({"Name":"DeadGuy", "StoryPoint":["DeadGuy", 1]})
		2:
			GlobalVars.get_from_inventory("DeadGuy")["StoryPoint"][1] = 3
		4:
			GlobalVars.get_from_inventory("DeadGuy")["StoryPoint"][1] = 5
	GameSaver.obj_save()

# Returns the point at the conversation the dialog should be
func get_dialog_num() -> int:
	var story_point = 0
	for item in GlobalVars.inventory:
		if item.has("StoryPoint") && item.get("StoryPoint")[0] == "DeadGuy":
			if int(item.get("StoryPoint")[1]) > story_point:
				story_point = int(item.get("StoryPoint")[1])
			if item.has("Temporary"):
				item.erase("StoryPoint")
				item.erase("Temporary")
	return story_point

func _on_interaction_box_body_entered(body):
	if body is Player:
		player_is_in_zone = true

func _on_interaction_box_body_exited(body):
	if body is Player:
		player_is_in_zone = false
