extends Area2D

@export var target_scene: String = ""
@export var target_entrance: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	
func _on_body_enter(body: Node2D) -> void:
	if body is CharacterBody2D:
		SceneTransitionManager.transition_to(
			"res://scenes/"+target_scene+".tscn",
			target_entrance
		)

#class_name SceneTransition
#extends Area2D
#
#@export var target_scene: String = ""
#@export var target_entrance: String = ""
#
#func _ready() -> void:
	#body_entered.connect(_on_body_entered)
#
#func _on_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D:
		#SceneTransitionManager.transition_to(
			#"res://scenes/" + target_scene + ".tscn",
			#target_entrance,
		#)
