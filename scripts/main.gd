extends Node

var players = {};

func _ready():
	var port_env = OS.get_environment("PORT")
	var port = port_env.to_int()

	var peer := WebSocketMultiplayerPeer.new()
	var error = peer.create_server(port)

	if error != OK:
		push_error("Erro ao iniciar servidor: %s" % error)
	else:
		print("Servidor iniciado na porta %d" % port)

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id):
	print("Novo jogador conectado:", peer_id)

func _on_peer_disconnected(peer_id):
	print("Jogador desconectou:", peer_id)
	if players.has(peer_id):
		players[peer_id].queue_free();
		players.erase(peer_id);
	rpc("despawn_player", peer_id);
		
@rpc("authority", "reliable")
func despawn_player(_peer_id: int):
	pass;

@rpc("any_peer", "reliable")
func check_other_players(received_players: Dictionary):
	var peer_id = multiplayer.get_remote_sender_id();

	var not_spawned_players = [];
	for player_id in players.keys():
		if not received_players.has(player_id):
			not_spawned_players.append({ "peer_id": player_id, "username": players[player_id].username });
			
	if len(not_spawned_players) > 0:
		rpc_id(peer_id, "spawn_other_players", not_spawned_players);
	
@rpc("authority", "reliable")
func spawn_other_players(_peer_ids: Array):
	pass;

@rpc("any_peer", "reliable")
func spawn_request(username: String):
	if username.length() < 3 or username.length() > 15:
		print("Username must have between 3 and 15 characters.");
		return;
		
	var regex = RegEx.new()
	regex.compile("^[A-Za-z0-9_]+$")

	if not regex.search(username):
		print("Invalid name (use letters, numbers and underscore).")
		return;
		
	for player_data in players.values():
		if player_data.username == username:
			print("Username already in use.");
			return;

	var peer_id = multiplayer.get_remote_sender_id();
	if not players.has(peer_id):
		var player = preload("res://scenes/player.tscn").instantiate()
		player.set_multiplayer_authority(peer_id);
		player.name = str(peer_id);
		player.username = username;
		get_tree().current_scene.add_child(player);
		players[peer_id] = player;
		rpc("spawn_player", peer_id, username);
	
@rpc("authority", "reliable")
func spawn_player(_peer_id: int, _username: String):
	pass;
	
@rpc("any_peer", "reliable")
func despawn_request():
	var peer_id = multiplayer.get_remote_sender_id();
	if players.has(peer_id):
		players[peer_id].queue_free();
		players.erase(peer_id);
	rpc("despawn_player", peer_id);
	
