extends Node

const SFX_POOL_SIZE: int = 8

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _music_tween: Tween


func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)


func play_sfx(sound: AudioStream) -> void:
	for player in _sfx_players:
		if not player.playing:
			player.stream = sound
			player.play()
			return


func play_music(music: AudioStream, crossfade: float = 1.0) -> void:
	if _music_tween:
		_music_tween.kill()
	if _music_player.playing and crossfade > 0.0:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -80.0, crossfade)
		await _music_tween.finished
	_music_player.stream = music
	_music_player.volume_db = -80.0
	_music_player.play()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", 0.0, crossfade)


func stop_music(fadeout: float = 1.0) -> void:
	if not _music_player.playing:
		return
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -80.0, fadeout)
	await _music_tween.finished
	_music_player.stop()


func set_sfx_volume(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)


func set_music_volume(volume_db: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, volume_db)
