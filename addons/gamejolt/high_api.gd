extends Node

export(int,10,90) var autoping_time = 20
export(String) var game_id  = ""
export(String) var private_key= ""
export(bool) var auto_init = true
export(bool) var translated = false
export(int,0,4) var verbose_level = 0
#MAX traffic difference before the no_connection function is called
export(int,2,60) var max_waiting_time = 5

var low_api =preload("res://addons/gamejolt/low_api.tscn").instance()

var autoping_timer = Timer.new() 
var response_timer = Timer.new()
var error_class = preload("res://addons/gamejolt/gj_error.gd")

#Utilized to throw Connection error to Lower API
var errorResult = {
	requestPath = null,
	requestError = 404,
	responseResult = null,
	responseBody = null,
	responseHeaders = null,
	responseStatus = null,
	jsonParseError = null,
	gameJoltErrorMessage = null
}


enum gj_api_errors{
	NOCONNECTION = 0,
	NOAUTH = 1
}

var error_dict = { }

signal _error(error_code,error_message)
signal _error_no_connection()

signal _reconnected()

##STATES
var online_c : bool = false
var auth_c : bool = false
var visible_c : bool = false
var active_c : bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	######
	if verbose_level>=3:
		low_api.verbose= true
	#####
	if auto_init:
		init()
	
	pass # Replace with function body.

func init(m_game_id=null,m_private_key=null):
	if m_game_id !=null:
		game_id = m_game_id
	
	if m_private_key != null:
		private_key = m_private_key
	
	#Send initialization to low API
	low_api.init(game_id,private_key)
	
	#INIT ERRORS
	_append_error(gj_api_errors.NOCONNECTION,"_error_no_connection","No Connection","e_noconnection")
	
	
	# Connecting l-api signal request completed to h-api function
	low_api.connect("gamejolt_request_completed",self,"gamejolt_request_completed")
	add_child(low_api)
	
	# Initializing response_timer
	response_timer.wait_time = max_waiting_time
	response_timer.one_shot=true
	response_timer.connect("timeout",self,"response_timeout")
	add_child(response_timer)
	#Check connection for the first time
	check_connection()

func gamejolt_request_completed(requestResults):
	request_recieved()
	if requestResults.requestError == 404:
		no_connection()
	else:
		if !online_c :
			on_reconnect()
			
	pass
	
func on_reconnect():
	online_c=true
	emit_signal("_reconnected")
	
func no_connection():
	online_c = false
	_error(gj_api_errors.NOCONNECTION)


func emit_no_connection_response():
	low_api.emit_signal("gamejolt_request_completed",errorResult)
	pass


func _append_error(code,signal_name,output_text,tr_output):
	var error_instance = error_class.new(signal_name,output_text,tr_output)
	error_dict[code] = error_instance
	
	pass

#Error function
func _error(error):
	
	emit_signal(error_dict[error].signal_name)
	
	#If errors are translated, before sending them, translate them
	if translated:
		emit_signal("_error",error,tr(error_dict[error].tr_output))
	else:
		emit_signal("_error",error,error_dict[error].output_text)
	pass
	
	

func check_connection():
	##Just send fetch_time
	# Rest is handled in gamejolt_request_completed
	
	low_api.fetch_time()
	request_sended()
#STATES FUNCTIONS


#returns true if it is connected to internet
func is_online():
	check_connection()
	return online_c
	pass

func is_auth():
	
	pass


##REQUEST SENDED AND REQUEST RECIEVED  - 
#Functions which are used, when there is problem with response
func request_sended():
	response_timer.start()
	pass

func request_recieved():
	response_timer.stop()
	pass

func response_timeout():
	emit_no_connection_response()