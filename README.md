# GameJolt high level API plugin for Godot Engine.
## About
**Features**
* Utilizing lower API written by rojekabc/
* Use GameJolt API in version 1.2
* Godot Engine plugin
* Auto authentificate in HTML5(contained in lower API)
* Saving of token and username in Desktop 
* Autopinging sessions
* Possibility to disable pinging
* Added states

**Planned**
* encrypted saving of token
* messaging system


**Installing**
1. Download the repository
2. Move the _addons_ folder, with _gamejolt_ folder together, to you root folder (res://) of Godot project
3. In the project settings, head to the "Plugins" tab and activate the plugin by changing its state from "Inactive" to "Active"
4. Yay, you've installed the plugin!
5. To allow Godot to use HTTPS communication append gamejolt.pem file in "Project Settings/Network/SSL/Certificates".

**How to use it(First way)**
1. Put the plugin as a Node in your project.
2. Call the function from the plugin. It'll initiate the request.
3. When response is received plugin will send the signal gamejolt_request_completed with the results collected in Godot Directory structure.
4. You may connect to this signal or yield. Now, you can also write all your request directly, there is a queue to process all the requests.
5. Get the response from the plugin - it's the parsed JSON to godot directory, which is the "response" part from GameJoltAPI.

**How to use it(Second way)**
1. You can create singleton of the higher.gd script
2. This way you must connect all signals in script



## Functions

**Authentification**

* Initializate AutoAuth
```
init_auto_auth()
```
-Must be Online
-Automatic authentification will try to auth automaticaly from file or from cache if the game is exported as HTML5 

* Authentificate
```
auth(name,token)
auth(name,token,save)
auth(name,token,save,autologin) - MAYBE DELETED
```
-Must be online
-Basic authentification, the save option is boolean and if it is true, the auth will be saved to file
-If autologin is true, next time the user will be authentificated automaticaly
* Logout
```
logout()
logout(remove_autoauth)
```
-logout from session , if true is passed, autoauth file will be removed, otherwise it wont 

* Check Connection
```
check_connection()
```
-Returns true if connection to GameJolt API exist, return false if not
**User Info Package**

* Contains
-id
-name
-avatar_path
-last_active

* Get Basic User Info
```
get_user_info(user_name)
get_user_info(id)
get_user_info()
```
-Must be Authentificated
-If no username is passed, returns your info
-ID is passed in form of integer, username in form of string

* Get Friends Info
```
get_friends_info()
```
-Must be authentificated
return array of user_info of your friends



**States**
* Offline/Online
```
is_online()
```
-depend on connection to Internet

* Authentificated/ Not Authentificated 
```
is_auth()
```
-returns true if the user is authentificated

* Visible/Invisible
```
is_visible()
```
-returns true if autopinging is on

```
set_visible(bool)
set_visible()
set_invisible()

toogle_visible()
```
-Must be authentificated
-functions which change or toogle visible state(visible means api is pinging to gj_api about session)

* Active/Idle
```
is_active()
```

-returns true if the player is in active state()

```
set_active(bool)
set_active()
set_idle()

toogle_active()
```
-Must be visible
-functions which change or toogle active and idle state


**reaching low level API **
```
get_lower_api()
```

# GameJolt low level API plugin for Godot Engine. (rojekabc/ README.md)
## About
**Features**
* Use GameJolt API in version 1.2
* Godot Engine plugin
* Parameters to the api calls can be passed both as strings and numbers
* Allow to verbose mode to see direct communication
* URLs are percent encoded
* Use HTTPS communication with GameJolt API
* Tested on Godot 3.0.6 and Godot 3.1 alpha
* One common singal on end of request
* Many point of checking response
* Sample Godot usage project

**Installing**
1. Download the repository
2. Move the _addons_ folder, with _gamejolt_ folder together, to you root folder (res://) of Godot project
3. In the project settings, head to the "Plugins" tab and activate the plugin by changing its state from "Inactive" to "Active"
4. Yay, you've installed the plugin!
5. To allow Godot to use HTTPS communication append gamejolt.pem file in "Project Settings/Network/SSL/Certificates".

**How to use it**
1. Put the plugin as a Node in your project.
2. Call the function from the plugin. It'll initiate the request.
3. When response is received plugin will send the signal gamejolt_request_completed with the results collected in Godot Directory structure.
4. You may connect to this signal or yield. Now, you can also write all your request directly, there is a queue to process all the requests.
5. Get the response from the plugin - it's the parsed JSON to godot directory, which is the "response" part from GameJoltAPI.

# Sample usage

This project is the prepared Godot sample of how to use this GameJolt plugin. Just open it in Godot and test calls to GameJolt.

Create godot project.
Create folder addons/gamejolt and put plugin files there.
Configure project will use this plugin.
Configure SSL certificates to use gamejolt SSL certificates.

Create main scene node, save scene and set it as the main godot project scene.
Add to main scene child node of GameJoltAPI.
Add to main scene script as below (replace user-name and user-private-key with yours).

```
func test_gamejolt():
	$GameJoltAPI.auth_user('user-name', 'user-private-key')
	var result = yield($GameJoltAPI, 'gamejolt_request_completed')
	if $GameJoltAPI.is_ok(result):
		print(result.requestPath + ' ... Success: ' + result.responseBody.success)
	else:
		$GameJoltAPI.print_error(result)
	
	$GameJoltAPI.fetch_time()
	result = yield($GameJoltAPI, 'gamejolt_request_completed')
	if $GameJoltAPI.is_ok(result):
		print(str(result))
		print(result.requestPath + ' ... Success: ' + result.responseBody.success)
		print('    Timestamp: ' + str(result.responseBody.timestamp))
	else:
		$GameJoltAPI.print_error(result)
```

# Methods description

## Emited signal and interpretation results
### Emited signal
`signal gamejolt_request_completed(type, requestResults)`

Signal emited by plugin, when request is completed with positive or negative status.
* type - the url path of the request.
* requestResults - the Dictionary containing results of the request. Contains such properties
  * requestPath - the path of call
  * requestError - the error status of request
  * responseResult - the response result (enumerated in HttpRequest)
  * responseHeaders - the headers of the response
  * responseStatus - the HTTP status code of the response
  * responseBody - the parsed JSON body of GameJolt response
  * jsonParserError - the status of parsing response
  * gameJoltErrorMessage - the error message from Game Jolt

### Check results
`is_ok(requestResults)`

Checks all results of requestResults from signal and return true if response is fully success.

### Print out error results
`print_error(requestResults)`

Print out information about reason of fail from requestResults.

## Authentication and users
### Authenticate user

`auto_auth()`

Authenticates the gamejolt user who plays the game. It works only with html5 games on Gamejolt for logged user.
After call this function username and token will be automatically set up.

`auth_user(token, username)`

Authenticates the user with the given credentials
Before doing calls that deal with users in one way or another, you must authenticate a user to ensure that the username-token pair is valid.

* token - your gamejolt token (not your password)
* username - your gamejolt username

### Fetch user's information

`fetch_user(username=null, ids=null):` 

Fetch the user's information

* username - name of the user, whose information you'd like to fetch
* id - id of the user, whose information you'd like to fetch

You don't need to pass both arguments, but at least one argument must be passed! When using ids, multiple ids can be passed, like this: '1,2,3,4'

## Sessions
### Open the session

`open_session()`

Opens the session.
_Uses authenticated user credentials_
Piece of cake! If there's an active session, it will close it and open a new one.

### Ping the session

`ping_session()`

Ping the session to keep it alive.
_Uses authenticated user credentials_
A session is closed after 120 seconds if not pinged. You have to ping the session to prevent it from closing.
Usually a timer that pings the session every 60 seconds will do the trick.

### Close the session
`close_session()`

Closes the active session.
_Uses authenticated user credentials_
When the player quits the game, the session should be closed.
If the game is closed, the session will be closed automatically anyway since it's not being pinged, but it's better to close it manually with this method, just in case.

## Trophies a.k.a achievements
### Fetch user trophies

`fetch_trophy(achieved=null, trophy_ids=null)` 

Fetches user trophies.
* achieved - leave blank to extarct all trophies, "true" to extract only trophies that the user has already achieved and "false" to get only unachieved trophies
* trophy_ids - pass a trophy id to extract the specific trophy or a set of trophy ids to get a list of trophies, like this: '1,2,3,4'
_Uses authenticated user credentials_
Trophies are basically achievements, nothing unusual. Fetching a list of trophies, just one trophy, only achieved trophies or only the unachieved trophies is done through this supermethod.
If the second parameter is passed, the first one is ignored!

### Achieve the trophy
`set_trophy_achieved(trophy_id)` 

Sets the trophy as achieved.
* trophy_id - id of the trophy to set as achieved
_Uses authenticated user credentials_
To set a trophy as achieved.

### Remove achieved trophy
`remove_trophy_achieved(trophy_id)`

Remove the achieved trophy.
* trophy_id - id of the trophy to set as achieved
_Uses authenticated user credentials_

## Scores
### Fetch user scores
`fetch_scores(limit=null, table_id=null, better_than=null, worse_than=null)`

Fetches scores for the user.
* limit - how many scores to return. The default value is 10, the max is 100
* table_id - what table to extract scores from. Leaving it blank will extract scores from the main table
* better_than - take scores better than
* worse_than - take scores worse than
_Uses authenticated user credentials_

### Fetch guest scores
`fetch_guest_scores(guest, table_id=null, limit=null, better_than=null, worse_than=null)`

Fetches scores for the guest.
* guest - the guest name
* table_id - what table to extract scores from. Leaving it blank will extract scores from the main table
* limit - how many scores to return. The default value is 10, the max is 100
* better_than - take scores better than
* worse_than - take scores worse than

### Fetch global scores
`fetch_global_scores(table_id=null, limit=null, better_than=null, worse_than=null)`

Fetches global scores.
* table_id - what table to extract scores from. Leaving it blank will extract scores from the main table
* limit - how many scores to return. The default value is 10, the max is 100
* better_than - take scores better than
* worse_than - take scores worse than

### Add scores for user
`add_score(score, sort, table_id=null)`

Adds a score to a table
* score - string assotiated with the score. For instance: "124 Jumps"
* sort - the actual score value. For example: 124
* table_id - what table to submit scores to. If left blank, the score will be submitted to the main table
_Uses authenticated user credentials_

### Add scores for guest
`add_guest_score(score, sort, guest, table_id=null)`

Adds a score to a table
* score - string assotiated with the score. For instance: "124 Jumps"
* sort - the actual score value. For example: 124
* guest - the guest name
* table_id - what table to submit scores to. If left blank, the score will be submitted to the main table
_Uses authenticated user credentials_

### List scoreboards
`fetch_tables()` 

Returns a list of all scoreboards

## Data storage
### Set Data
`set_data(key, data, global=true)`

Stores data in the cloud
* key - a piece of data is stored in a *key*, this is the name of the key
* data - what you want to store in the key
* global - true, then use global data; false use authenticated user specific data
Data can be strings, integers, floats...anything

### Fetch data
`fetch_data(key, global=true)`

Fetches data from the key
* key - key to fetch data from
* global - true, then use global data; false use authenticated user specific data

### Update data
`update_data(key, operation, value, global=true)`

Updates data in the key
* key - key, whose data will be updated
* operation - what kind of operation to perform on the data. String can be prepended and appended to. Numbers can be divided, multiplied, added to and subtracted from. Use one of these: "append", "prepend", "divide", "multiply", "add", "subtract"
* value = value that will be used in the operation
* global - true, then use global data; false use authenticated user specific data

### Remove data
`remove_data(key, global=true)`

Removes a key
* key - what key to remove
* global - true, then use global data; false use authenticated user specific data

### List of data keys
`get_data_keys(pattern=null, global=true)`

Return a list of keys
* pattern - the pattern for filter data keys
* global - true, then use global data; false use authenticated user specific data

## Time
### Get server time
`fetch_time()`

Get a time from the server.

## Additional methods

* get_username() - returns the current authenticated username.
* get_user_token() - returns the current authenticated user's token.
* clear_call_queue() - allow to clear a queue of calls. Useable in situation, that one of the call finish with failure.

# Hints

1. Don't use thread for html5 games. HTTPrequest doesn't work.
2. Remember - yield does out from current function and executes caller code (!). Action in that function (and only that function) will be resumed on the signal.

# Plugin Versions

## 2.0
* Rojekabc (https://github.com/rojekabc) create fork.
* Plugin refactoring.
* Append PEM for SSL comunication.

## 2.1
* Take changes from deakcor (https://github.com/deakcor) fork.
* Queue calls.
* GameJolt signal with collected results.
* Update GameJolt certificates.

## 2.2
* Sample project, which uses plugin.

# Licenses

| Usage | HomePage | License |
|-|-|-|
| Font _grundschrift_ for GameJolt sample Godot project | https://fontlibrary.org/pl/font/grundschrift | [CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/) |
