extends Control

@onready var _title: Label = $Background/Panel/Margin/VBox/Title
@onready var _subtitle: Label = $Background/Panel/Margin/VBox/Subtitle
@onready var _quit_button: Button = $Background/Panel/Margin/VBox/QuitButton


func _ready() -> void:
	_quit_button.pressed.connect(_on_quit_pressed)
	_title.text = "Template Module"
	_subtitle.text = "Podmien ten ekran na wlasna gre."


func _on_quit_pressed() -> void:
	var node: Node = self
	while node:
		if node.has_method("request_exit"):
			node.request_exit()
			return
		node = node.get_parent()
	get_tree().quit()
