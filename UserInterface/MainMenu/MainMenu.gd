extends Control

const SWITCH = preload("res://UserInterface/Menu-Selection-Change-D2-www.fesliyanstudios.com.mp3")
const SELECT = preload("res://UserInterface/Game-Menu-Selection-Z-www.fesliyanstudios.com.mp3")

@onready var item_list = $ItemList
#@onready var input_menu = $InputMenu
@onready var level_transition = $LevelTransition.get_material()
@onready var sound_menu := $SoundMenu
@onready var more_menu := $MoreMenu
@onready var sound_effect := $AudioStreamPlayer2

var index := 0

func _ready():
	load_menu()
	for i in range(0,item_list.get_item_count()):
		item_list.set_item_tooltip_enabled(i,false)
	item_list.set_focus_mode(Control.FOCUS_NONE)
	item_list.select(index)

func _input(event):
#	if input_menu.visible:
#		input_menu.input(event)
	if sound_menu.visible:
		sound_menu.input(event)
	elif not more_menu.visible:
		if Input.is_action_pressed("ui_accept"):
			select_option()
		elif Input.is_action_pressed("ui_cancel"):
			load_menu()
		elif Input.is_action_pressed("ui_up"):
			sound_effect.stream = SWITCH
			sound_effect.play()
			index = int(clamp(index - 1, 0, item_list.get_item_count()-1))
			item_list.select(index)
		elif Input.is_action_pressed("ui_down"):
			sound_effect.stream = SWITCH
			sound_effect.play()
			index = int(clamp(index + 1, 0, item_list.get_item_count()-1))
			item_list.select(index)
		elif Input.is_action_pressed("delete") && "Save" in item_list.get_item_text(item_list.get_selected_items()[0]):
			delete_save()

func select_option():
	sound_effect.stream = SELECT
	sound_effect.play()
	if item_list.get_item_text(0) == "Play":
		match item_list.get_item_text(item_list.get_selected_items()[0]):
			"Settings":
				load_settings()
			"Play":
				index = 0
				load_saves()
			"Exit":
				get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
	elif item_list.get_item_text(0) == "Sound":
		match item_list.get_item_text(item_list.get_selected_items()[0]):
			"Sound":
				sound_menu.show()
			"Controls":
				pass
#				input_menu.show()
			"More":
				more_menu.show()
			"Back":
				load_menu()
	else:
		if item_list.get_item_text(item_list.get_selected_items()[0]) == "Back":
			load_menu()
			return
		var tween = get_tree().create_tween()
		GameSaver.save_path = "user://Save%s.json"%(item_list.get_selected_items()[0]+1)
		tween.tween_property(level_transition, "shader_parameter/dissolve_state", 1, 1)
		tween.tween_callback(Callable(get_tree(), "change_scene_to_file").bind("res://Abstract/LevelSwitcher.tscn"))

func load_saves():
	item_list.clear()
	for i in 3:
		if FileAccess.file_exists("user://Save%s.json"%(i+1)):
			item_list.add_item("Save" + str(i+1))
		else:
			item_list.add_item("New Game")
	item_list.add_item("Back")
	item_list.select(index)

func load_settings():
	item_list.clear()
	item_list.add_item("Sound")
	item_list.add_item("Controls")
	item_list.add_item("More")
	item_list.add_item("Back")
	index = 0
	item_list.select(index)

func load_menu():
	item_list.clear()
	item_list.add_item("Play")
	item_list.add_item("Settings")
	item_list.add_item("Exit")
	index = 0
	item_list.select(index)

func delete_save():
	if FileAccess.file_exists("user://Save%s.json"%(item_list.get_selected_items()[0]+1)):
		DirAccess.remove_absolute("user://Save%s.json"%(item_list.get_selected_items()[0]+1))
		load_saves()

func _on_item_list_item_clicked(new_index, _at_position, _mouse_button_index):
	index = new_index
	select_option()
