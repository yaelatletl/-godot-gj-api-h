extends HTTPRequest

# GameJolt Godot plugin by Ackens https://github.com/ackens/-godot-gj-api
# GameJolt API index page https://gamejolt.com/game-api/doc

const BASE_GAMEJOLT_API_URL = 'https://api.gamejolt.com/api/game/v1_2'

export(String) var private_key
export(String) var game_id
export(bool) var verbose:bool = false

signal gamejolt_request_completed(type,message)

var username_cache:String
var token_cache:String
var busy:bool = false
var queue:Array = []
var lasttype:Array=[]

class RequestQueue:
	var type:String
	var parameters:Dictionary
	
	func _init(new_type:String,new_parameters:Dictionary):
		type = new_type
		parameters = new_parameters

# public

func init(pk:String,gi:String):
	private_key=pk
	game_id=gi

### USERS

func get_username():
	return username_cache
	pass
	
func get_user_token():
	return token_cache
	pass

func auto_auth():
	#get username and token form url on gamejolt (only work with html5)
	#For Godot debugging, add this in your url : ?gjapi_username=<yourusername>&gjapi_token=<yourtoken>
	JavaScript.eval('var urlParams = new URLSearchParams(window.location.search);',true)
	var tmp = JavaScript.eval('urlParams.get("gjapi_username")', true)
	if tmp is String:
		username_cache = tmp
		tmp = JavaScript.eval('urlParams.get("gjapi_token")', true)
		if tmp is String:
			token_cache = tmp
			_call_gj_api('/users/auth/', {user_token = token_cache, username = username_cache})

func auth_user(username:String, token:String):
	_call_gj_api('/users/auth/', {user_token = token, username = username})
	username_cache = username
	token_cache = token
	pass

func fetch_user(username=null, id:int=0):
	_call_gj_api('/users/', {username = username, user_id = id})
	pass

func fetch_friends():
	_call_gj_api('/friends/',
		{username = username_cache, user_token = token_cache})
	pass

### SESSIONS

func open_session():
	_call_gj_api('/sessions/open/',
		{username = username_cache, user_token = token_cache})
	pass

func ping_session():
	_call_gj_api('/sessions/ping/',
		{username = username_cache, user_token = token_cache})
	pass
	
func close_session():
	_call_gj_api('/sessions/close/',
		{username = username_cache, user_token = token_cache})
	pass
	
func check_session():
	_call_gj_api('/sessions/check/',
		{username = username_cache, user_token = token_cache})
	pass
	
### SCORES

func fetch_scores(table_id=null, limit=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{username = username_cache, user_token = token_cache, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass

func fetch_guest_scores(guest, limit=null, table_id=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{guest = guest, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass
	
func fetch_global_scores(limit=null, table_id=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass

func add_score(score, sort, table_id=null):
	if username_cache!=null:
		_call_gj_api('/scores/add/',
			{score = score, sort = sort, username = username_cache, user_token = token_cache, table_id = table_id})
		pass
	
func add_guest_score(score, sort, guest, table_id=null):
	_call_gj_api('/scores/add/',
		{score = score, sort = sort, guest = guest, table_id = table_id})
	pass
	
func fetch_score_rank(sort, table_id=null):
	_call_gj_api('/scores/get_rank/', {sort = sort, table_id = table_id})
	pass
	
func fetch_tables():
	_call_gj_api('/scores/tables/',{})
	pass

### TROPHIES

func fetch_trophy(achieved=null, trophy_ids=null):
	_call_gj_api('/trophies/',
		{username = username_cache, user_token = token_cache, achieved = achieved, trophy_id = trophy_ids})
	pass
	
func set_trophy_achieved(trophy_id):
	if username_cache!=null:
		_call_gj_api('/trophies/add-achieved/',
			{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
		pass
	
func remove_trophy_achieved(trophy_id):
	_call_gj_api('/trophies/remove-achieved/',
		{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
	pass
	
### DATA STORE

	
func fetch_data(key, global=true):
	if global:
		_call_gj_api('/data-store/', {key = key})
	else:
		_call_gj_api('/data-store/', {key = key, username = username_cache, user_token = token_cache})
	pass
	
func set_data(key, data, global=true):
	if global:
		_call_gj_api('/data-store/set/', {key = key, data = data})
	else:
		_call_gj_api('/data-store/set/', {key = key, data = data, username = username_cache, user_token = token_cache})
	pass
	
func update_data(key, operation, value, global=true):
	if global:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value})
	else:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value, username = username_cache, user_token = token_cache})
	pass
	
func remove_data(key, global=true):
	if global:
		_call_gj_api('/data-store/remove/', {key = key})
	else:
		_call_gj_api('/data-store/remove/', {key = key, username = username_cache, token = token_cache})
	pass
	
func get_data_keys(pattern=null, global=true):
	if global:
		_call_gj_api('/data-store/get-keys/', {pattern = pattern})
	else:
		_call_gj_api('/data-store/get-keys/',
			{username = username_cache, user_token = token_cache, pattern = pattern})
	pass

### TIME

func fetch_time():
	_call_gj_api('/time/',{})
	pass

# private

func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')

func _call_gj_api(type:String, parameters:Dictionary):
	var request_error := OK
	if busy:
		request_error = ERR_BUSY
		queue.push_back(RequestQueue.new(type,parameters))
		return
	busy = true
	var url = _compose_url(type, parameters)
	lasttype.push_back(type)
	request_error = request(url)
	if request_error != OK:
		busy = false
	pass

func _compose_url(urlpath, parameters={}):
	var final_url = BASE_GAMEJOLT_API_URL + urlpath
	final_url += '?game_id=' + str(game_id)

	for key in parameters.keys():
		var parameter = parameters[key]
		if parameter == null:
			continue
		parameter = str(parameter)
		if parameter.empty():
			continue;
		final_url += '&' + key + '=' + parameter.percent_encode()

	var signature = final_url + private_key
	signature = signature.md5_text()
	final_url += '&signature=' + signature
	if verbose:
		_verbose(final_url)
	return final_url
	pass
	
func _on_HTTPRequest_request_completed(result, response_code, headers, response_body):
	busy = false
	
	if !queue.empty():
		var request_queued :RequestQueue = queue.pop_front()
		_call_gj_api(request_queued.type, request_queued.parameters)
		
	if result != OK:
		emit_signal('gamejolt_request_completed',lasttype,{"success":false})
		return
		
	var body:String = response_body.get_string_from_utf8()
	
	if verbose:
		_verbose(body)
		
	var json_result = JSON.parse(body)
	var response:Dictionary = {}
	if json_result.error == OK:
		response = json_result.result.get('response',{})
		response['success'] = response.get('success',false)
		if response['success'] == 'true':
			response['success']=true
		else:
			response['success']=false

	emit_signal('gamejolt_request_completed',lasttype[0],response)
	lasttype.pop_front()
	pass # replace with function body

func _verbose(message):
	if verbose:
		print('[GAMEJOLT] ' + message)
