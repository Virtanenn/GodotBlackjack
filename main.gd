extends Node

var money: int = 100
var bet: int = 0
var game_on: bool = false
var rolled_cards = []
var rng = RandomNumberGenerator.new()
var pCard: int = 0
var dCard: int = 0
var total: int = 0
#If player has rolled an ACE
var tHigh: int = 0
var dHigh: int = 0
var dTotal: int = 0
var bool_deal: bool = false

var pAce: int = 0
var dAce: int = 0
var moneys = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$moneyLabel.text = str(money)+" $"
	
	$bet1.pressed.connect(self._bet_btn_handler.bind(1))
	$bet5.pressed.connect(self._bet_btn_handler.bind(5))
	$bet10.pressed.connect(self._bet_btn_handler.bind(10))
	$bet20.pressed.connect(self._bet_btn_handler.bind(20))
	$bet50.pressed.connect(self._bet_btn_handler.bind(50))
	
	$neg_bet1.pressed.connect(self._bet_btn_handler.bind(-1))
	$neg_bet5.pressed.connect(self._bet_btn_handler.bind(-5))
	$neg_bet10.pressed.connect(self._bet_btn_handler.bind(-10))
	$neg_bet20.pressed.connect(self._bet_btn_handler.bind(-20))
	$neg_bet50.pressed.connect(self._bet_btn_handler.bind(-50))
	
	$dealBtn.pressed.connect(self._game_start.bind())
	$hitBtn.pressed.connect(self._new_card)
	$standBtn.pressed.connect(self.dealer_draw_turn.bind())
	
	$hitBtn.visible = false
	$standBtn.visible = false
	$dealBtn.disabled = true
	bool_deal = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	

func _bet_btn_handler(number:int)->void:
	if number > money:
		bet+=money
		money = 0
		
	elif number<0:
		if bet+number >= 0:
			money -= number
			bet += number
			
	elif money-number>=0:
		money -= number
		bet += number
	
	$moneyLabel.text =str(money)+" $"
	$betLabel.text = "bet: " + str(bet)+" $"
	
	if bet > 0:
		$dealBtn.disabled = false
	else:
		$dealBtn.disabled = true
	
	
func _game_start()->void:
	game_on = true
	bool_deal = true
	
	$bet1.visible=false
	$bet5.visible=false
	$bet10.visible=false
	$bet20.visible=false
	$bet50.visible=false
	$neg_bet1.visible=false
	$neg_bet5.visible=false
	$neg_bet10.visible=false
	$neg_bet20.visible=false
	$neg_bet50.visible=false
	
	$dealBtn.visible=false

	$infoLabel.text = "DEALING."
	if bool_deal:
		_new_card()
		await(get_tree().create_timer(1).timeout)
		$infoLabel.text = "DEALING.."
		_dealer_card()
		await(get_tree().create_timer(1).timeout)
		$infoLabel.text = "DEALING..."
		_new_card()
		await(get_tree().create_timer(1).timeout)
		
	bool_deal = false
	$hitBtn.visible = true
	$standBtn.visible = true
	$infoLabel.text = ""
	if tHigh or total == 21:
		$hitBtn.disabled = true
		$standBtn.disabled = true
		await(get_tree().create_timer(1).timeout)
		_dealer_card();
		await(get_tree().create_timer(1).timeout)
		if dHigh < tHigh:
			$infoLabel.text = "Blackjack!"
			money = bet+bet/2+money
		else:
			$infoLabel.text = "Draw!"
			
		await(get_tree().create_timer(3).timeout)
		reset_board()
		game_on =false
		$hitBtn.disabled = false
		$standBtn.disabled = false
	
func draw_card()->String:
	var card : String = ""
	var unique_card: bool = false
	while unique_card == false:
		var random_number = rng.randi_range(1,312)
		if !rolled_cards.has(random_number):
			if random_number <= 78:
				card = str(random_number%13)+"pata"
				
			elif random_number >= 79 and random_number <= 156:
				card = str(random_number%13)+"hertta"
			
			elif random_number >= 157 and random_number <= 234:
				card = str(random_number%13)+"ruutu"
			
			elif random_number >= 235 and random_number <= 312:
				card = str(random_number%13)+"risti"
				
				
			rolled_cards.push_front(random_number)
			unique_card = true
	return card
	
	
func _new_card()->void:
	pCard = pCard+1
	var card:String = draw_card()
	var value:int = card_value(card)
	if value == 1:
		tHigh = value+10+total
		pAce = 1+pAce
		if pAce == 2:
			if (total+10)<22:
				total +=10
			
	elif tHigh != 0 and value != 1:
		tHigh = tHigh+value
		
	if tHigh > 21:
			tHigh = 0
			
	total = total+value	
	
	if tHigh == total:
			tHigh = 0
			
	if pCard==1:
		$pKortti1/TextureRect.texture = load("res://kortit/"+card+".png")
	elif pCard==2:
		$pKortti2/TextureRect.texture = load("res://kortit/"+card+".png")
	elif pCard==3:
		$pKortti3/TextureRect.texture = load("res://kortit/"+card+".png")
	elif pCard==4:
		$pKortti4/TextureRect.texture = load("res://kortit/"+card+".png")
	elif pCard==5:
		$pKortti5/TextureRect.texture = load("res://kortit/"+card+".png")
	$pTotalLabel.text = "Total: " + str(total)
	if tHigh > 0:
		
		$pTotalLabel.text = "Total: " + str(total) + " OR " +str(tHigh)
	if total > 21:
		$infoLabel.text = "BUST!"
		$hitBtn.disabled = true
		$standBtn.text = "new game"
		game_on = false
		

func _dealer_card()->void:
	var card:String = draw_card()
	var value:int = card_value(card)
	
	dCard = dCard +1
	if value == 1:
		dHigh = value+10+dTotal
		dAce = 1+dAce
		if dAce == 2:
			if (dTotal+10)<22:
				dTotal +=10
				
	elif dHigh != 0 and value != 1:
		dHigh = dHigh+value
	
	if dHigh > 21:
		dHigh = 0
		
	dTotal = dTotal + value

	if dHigh == dTotal:
			dHigh = 0
		
		
	if dTotal < 17 or dHigh < 17:
		if dCard==1:
			$dKortti1/TextureRect.texture = load("res://kortit/"+card+".png")
		elif dCard==2:
			$dKortti2/TextureRect.texture = load("res://kortit/"+card+".png")
		elif dCard==3:
			$dKortti3/TextureRect.texture = load("res://kortit/"+card+".png")
		elif dCard==4:
			$dKortti4/TextureRect.texture = load("res://kortit/"+card+".png")
		elif dCard==5:
			$dKortti5/TextureRect.texture = load("res://kortit/"+card+".png")
			
			
	$dTotalLabel.text = "Dealer: " + str(dTotal)
	if dHigh > 0:
		
		$dTotalLabel.text = "Total: " + str(dTotal) + " OR " +str(dHigh)

func dealer_draw_turn()->void:
	$standBtn.disabled = true
	if game_on:
		$hitBtn.disabled = true
		while dTotal < 17 and (dHigh == 0 or dHigh < 17):
			await(get_tree().create_timer(1).timeout)
			_dealer_card()
		
	await(get_tree().create_timer(1).timeout)
	if total > 21:
		lose_bet()
		$standBtn.text = "STAND"
	
	elif dTotal>21:
		$infoLabel.text = "bet won!"
		await(get_tree().create_timer(2).timeout)
		win_bet()
		
	elif tHigh == 0 and dHigh == 0:
		if total > dTotal:
			$infoLabel.text = "bet won!"
			await(get_tree().create_timer(2).timeout)
			win_bet()
		elif dTotal > total:
			$infoLabel.text = "bet lost!"
			await(get_tree().create_timer(2).timeout)
			lose_bet()
		else:
			$infoLabel.text = "Draw!"
			await(get_tree().create_timer(2).timeout)
			game_on = false
			money = bet+money
			reset_board()
			
	elif tHigh != 0 and dHigh != 0:
		if tHigh > dHigh:
			$infoLabel.text = "bet won!"
			await(get_tree().create_timer(2).timeout)
			win_bet()
		elif dHigh > tHigh:
			$infoLabel.text = "bet lost!"
			await(get_tree().create_timer(2).timeout)
			lose_bet()
		else:
			$infoLabel.text = "Draw!"
			await(get_tree().create_timer(2).timeout)
			game_on = false
			money = bet+money
			reset_board()
	else:
		if tHigh == 0:
			if total > dHigh:
				$infoLabel.text = "bet won!"
				await(get_tree().create_timer(2).timeout)
				win_bet()
			elif dHigh>total:
				$infoLabel.text = "bet lost!"
				await(get_tree().create_timer(2).timeout)
				lose_bet()
			else:
				$infoLabel.text = "Draw!"
				await(get_tree().create_timer(2).timeout)
				game_on = false
				money = bet+money
				reset_board()
		elif dHigh == 0:
			if tHigh > dTotal:
				$infoLabel.text = "bet won!"
				await(get_tree().create_timer(2).timeout)
				win_bet()
			if dTotal > tHigh:
				$infoLabel.text = "bet lost!"
				await(get_tree().create_timer(2).timeout)
				lose_bet()
			else: 
				$infoLabel.text = "Draw!"
				await(get_tree().create_timer(2).timeout)
				game_on = false
				money = bet+money
				reset_board()
	$standBtn.disabled = false
	
func card_value(card:String)->int:
	# 10, 11 ja 12
	if card[1] == "0" or card[1] == "1" or card[1] == "2" or card[0] == "0":
		return 10
		
	elif card[0] == "1":
		return 1
	
	return 1

func win_bet()->void:
	game_on = false
	money = 2*bet+money
	reset_board()
	
func lose_bet()->void:
	game_on = false
	reset_board()
	
		
	
func reset_board()->void:
	$bet1.visible=true
	$bet5.visible=true
	$bet10.visible=true
	$bet20.visible=true
	$bet50.visible=true
	$neg_bet1.visible=true
	$neg_bet5.visible=true
	$neg_bet10.visible=true
	$neg_bet20.visible=true
	$neg_bet50.visible=true
	$dealBtn.visible=true
	$dealBtn.disabled = true
	$hitBtn.visible = false
	$standBtn.visible = false
	$infoLabel.text = ""
	$pTotalLabel.text = ""
	$dTotalLabel.text = ""
	$hitBtn.disabled = false
	pAce = 0
	dAce = 0
	
	pCard = 0
	dCard = 0
	total= 0
	dTotal = 0
	bet = 0
	tHigh = 0
	dHigh = 0
	
	$betLabel.text = "bet: " + str(bet)+" $"
	$moneyLabel.text =str(money)+" $"
	
	# korttipakan sekoitus
	if rolled_cards.size() > 78:
		rolled_cards.clear()
		
	for i in range(1, 6):

		var node_path_dealer = "dKortti" + str(i) + "/TextureRect"
		var node_path_player = "pKortti"+str(i) + "/TextureRect"

		var node_dealer = get_node(node_path_dealer)
		var node_player = get_node(node_path_player)
		
		node_dealer.texture = null
		node_player.texture = null
		
