extends Control

#first copy gamejolt_api_v2 folder in an addons folder in your project
# Project/Settings/Plugins -> set gamejolt api active
#Add a node GameJoltAPI or use it with a composition in a singleton(better for a game project)
onready var gj=$gj
var username:String
var token:String
var score=0
var trophy=[]
func _ready():
	$container/log_text.set_text("")
	#use your private key and game id
	gj.init("yourprivatekey","yourgameid")
	gj.connect("gamejolt_request_completed",self,"_gj_completed")
	
func _gj_completed(type,message,finished):
	$container/log_text.text+="\n"+type+str(message)+"\n"
	if type=="/sessions/open/":
		if message["success"]:
			$container/auth/noauth.visible=false
			$container/auth/welcome_text.set_text("Welcome, "+gj.get_username())
			gj.fetch_global_scores(10, 405532, 0, null)
			gj.fetch_data("score", false)
			gj.fetch_trophy(null, null)
			$container/trophy/container/button_trophy.disabled=false
	elif type=="/scores/":
		if message["success"]:
			var i=0
			$container/Leaderboard/container/text_ld.set_text("")
			print(message["scores"])
			while message["scores"].size()>i:
				$container/Leaderboard/container/text_ld.text+="\n"+str(i+1)+") "+message["scores"][i]["user"]+" : "+message["scores"][i]["score"]
				i+=1
	elif type=='/scores/add/':
		if message["success"]:
			gj.set_data("score", score, false)
			$container/score/container/score_text.set_text("Your score : "+str(score))
			if score>9 and trophy.find(104281)==-1:
				gj.set_trophy_achieved(104281)
				trophy.append(104281)
			print(trophy.find(104282))
			if score>99 and trophy.find(104282)==-1:
				gj.set_trophy_achieved(104282)
				trophy.append(104282)
			if score>999 and trophy.find(104283)==-1:
				gj.set_trophy_achieved(104283)
				trophy.append(104283)
			if score>9999 and trophy.find(104284)==-1:
				gj.set_trophy_achieved(104284)
				trophy.append(104284)
			gj.fetch_global_scores(5, 405532, 0, null)
	elif type=="/data-store/":
		if message["success"]:
			score=int(message["data"])
		$container/score/container/Button.disabled=false
		$container/score/container/score_text.set_text("Your score : "+str(score))
	elif type=="/trophies/":
		if message["success"]:
			for k in message["trophies"]:
				if k["achieved"]!="false":
					trophy.append(k["id"])
		print(trophy)
	print("finished: "+str(finished))

func _on_auto_auth_pressed():
	gj.auto_auth()
	gj.open_session()


func _on_normal_auth_pressed():
	gj.auth_user(username, token)
	gj.open_session()

func _on_auth_name_text_changed(new_text):
	username=new_text


func _on_auth_token_text_changed(new_text):
	token=new_text


func _on_Button_pressed():
	score+=1
	$timer_score.start()
func _on_button_trophy_pressed():
	gj.set_trophy_achieved(104280)


func _on_timer_score_timeout():
	gj.add_score(str(score)+" times", score, 405532)
