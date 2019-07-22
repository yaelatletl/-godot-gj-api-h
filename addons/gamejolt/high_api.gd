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
	NOAUTH = 1,
	INCORRECTAUTH = 2,
	
}

var error_dict = { }

signal _error(error_code,error_message)
signal _error_no_connection()
signal _error_no_auth()
signal _error_incorrect_auth()

signal _reconnected()
signal _authentificated()
signal _deauthentificated()
##STATES
var online_c : bool = false
var auth_c : bool = false
var visible_c : bool = false
var active_c : bool = false

#cache
var username_c :String = ""
var token_c:String = ""
var session_c = false



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
	_append_error(gj_api_errors.NOCONNECTION, "_error_no_connection", "No Connection","e_noconnection")
	_append_error(gj_api_errors.NOAUTH, "_error_no_auth","Not Authentificated", "e_noauth")
	_append_error(gj_api_errors.INCORRECTAUTH, "_error_incorrect_auth", "Incorrect Authentification","e_incorrectauth")
	
	# Connecting l-api signal request completed to h-api function
	low_api.connect("gamejolt_request_completed",self,"gamejolt_request_completed")
	add_child(low_api)
	
	# Initializing response_timer
	response_timer.wait_time = max_waiting_time
	response_timer.one_shot=true
	response_timer.connect("timeout",self,"response_timeout")
	add_child(response_timer)
	
	#Initializing autopinger
	autoping_timer.wait_time = autoping_time
	autoping_timer.one_shot = false
	autoping_timer.connect("timeout",self,"autopinger_ping")
	add_child(autoping_timer)
	
	
	#Check connection for the first time
	check_connection()

func gamejolt_request_completed(requestResults):
	request_recieved()
	if requestResults.requestError == 404:
		no_connection()
	else:
		# On reconneting
		if !online_c :
			on_reconnect()
		
		if requestResults.requestPath == "/users/auth/" :
			auth_response(requestResults)
		if "/sessions" in requestResults.requestPath:
			session_response(requestResults)
	
	pass
	
func on_reconnect():
	online_c=true
	emit_signal("_reconnected")
	change_autoping()
	
func no_connection():
	online_c = false
	_throw_error(gj_api_errors.NOCONNECTION)
	change_autoping()


func emit_no_connection_response():
	low_api.emit_signal("gamejolt_request_completed",errorResult)
	pass


func _append_error(code,signal_name,output_text,tr_output):
	error_dict[code] = error_class.new(signal_name,output_text,tr_output)
	pass

#Error function
func _throw_error(error):
	
	emit_signal(error_dict[error].signal_name)
	
	#If errors are translated, before sending them, translate them
	if translated:
		emit_signal("_error",error,tr(error_dict[error].tr_output))
	else:
		emit_signal("_error",error,error_dict[error].output_text)
	pass
	if verbose_level>0:
		print("ERROR ",int(error),": ",error_dict[error].signal_name)
	

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

# returns true if the user is authentificated
func is_auth():
	if !auth_c:
		_throw_error(gj_api_errors.NOAUTH)
	return auth_c
	pass

#sett cache for auth data without proving 
func set_auth_data(username,token):
	username_c = username
	token_c = token
	
	pass
	#Authentificate, 
	#you can set username and token but you doesnt have to 
	#Also sending auth request
func auth(username = "",token = "",active = true):
	if username != "":
		set_username(username)
	if token != "":
		set_token(token)
		
	# set visibility
	set_visible(active)
	#Firstly chech username and token
	if username_c == "" or token_c == "" :
		_throw_error(gj_api_errors.INCORRECTAUTH)
		return
	#Then check if is online
	if !is_online() :
		_throw_error(gj_api_errors.INCORRECTAUTH)
		return
	low_api.auth_user(username_c,token_c)
	pass

func deauth():
	auth_c = false
	set_username("")
	set_token("")
	
func auth_response(responseBody):
	if responseBody.responseBody["success"] == "true" :
		auth_c = true
		if visible_c:
			print("Open Session")
			print(auth_c)
			open_session()
			change_autoping()
		
		emit_signal("_authentificated")
	else:
		_throw_error(gj_api_errors.INCORRECTAUTH)
	pass



#Visibility

func is_visible():
	return visible_c

#AUTOPINGER
func autopinger_ping():
	print("ping")
	if is_online() and is_auth() and is_visible():
		low_api.ping_session()
	pass

func open_session():
	if is_online() and is_auth() and is_visible():
		low_api.open_session()

func close_session():
	if is_online() and is_auth() and is_visible():
		low_api.close_session()

func check_session():
	low_api.check_session()
	
func session_response(requestResults):
	if "ping" in requestResults.requestPath:
		pass
	pass

func ping_session():
	low_api.ping_session()
	
func set_visible(visible):
	visible_c = visible
	change_autoping()

func change_autoping():
	if is_online() and is_auth() and is_visible():
		autoping_timer.start()
	else:
		autoping_timer.stop()

func set_active(active):
	active_c = active
	
	if active:
		low_api.status_cache = "active"
	else:
		low_api.status_cache = "idle"

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


# set basic functions	
func set_username(username):
	username_c = username
	low_api.username_cache = username_c
	pass

func set_token(token):
	token_c = token
	low_api.token_cache = token_c
	
	
	# close connection when quiting
func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        low_api.close_session()