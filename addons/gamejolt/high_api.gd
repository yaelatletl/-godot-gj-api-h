extends Node

export(int,10,90) var autoping_time = 20
export(String) var game_id = ""
export(String) var private_key= ""


var low_api = preload("res://addons/gamejolt/low_api.gd").new()
var autoping_timer = Timer.new() 


signal _error(error_message)




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(m_game_id,m_private_key):
	game_id = m_game_id
	private_key = m_private_key
	#Send initialization to low API
	low_api.init(game_id,private_key)
