/*
	RingVaders - Audio Module
	Sound effects and music handling
*/

func initSounds
	# Generate WAV files and load them
	generateWavFile("assets/audio/snd_shoot.wav", 640, 0.05)
	sndShoot = al_load_sample("assets/audio/snd_shoot.wav")
	
	generateWavFile("assets/audio/snd_enemy.wav", 480, 0.06)
	sndEnemyHit = al_load_sample("assets/audio/snd_enemy.wav")
	
	generateWavFile("assets/audio/snd_ufo_hit.wav", 760, 0.1)
	sndUfoHit = al_load_sample("assets/audio/snd_ufo_hit.wav")
	
	generateWavFile("assets/audio/snd_player.wav", 280, 0.2)
	sndPlayerHit = al_load_sample("assets/audio/snd_player.wav")
	
	generateWavFile("assets/audio/snd_powerup.wav", 820, 0.08)
	sndPowerup = al_load_sample("assets/audio/snd_powerup.wav")
	
	generateWavFile("assets/audio/snd_wave.wav", 520, 0.12)
	sndWaveClear = al_load_sample("assets/audio/snd_wave.wav")
	
	generateWavFile("assets/audio/snd_1up.wav", 980, 0.12)
	snd1Up = al_load_sample("assets/audio/snd_1up.wav")
	
	generateWavFile("assets/audio/snd_ufo.wav", 300, 0.15)
	sndUfoSpawn = al_load_sample("assets/audio/snd_ufo.wav")
	
	sampleId = al_new_allegro_sample_id()
	
	# Load music as samples
	musicMenu = al_load_sample("assets/audio/menu.ogg")
	musicMain = al_load_sample("assets/audio/main.ogg")
	musicBoss = al_load_sample("assets/audio/boss.ogg")
	musicSampleId = al_new_allegro_sample_id()
	
	if musicMenu = NULL ? "Warning: Could not load menu music" ok
	if musicMain = NULL ? "Warning: Could not load main music" ok
	if musicBoss = NULL ? "Warning: Could not load boss music" ok
	
	# Load powerup images
	imgPowerupShield = al_load_bitmap("assets/textures/powerup_shield.png")
	imgPowerupRapid = al_load_bitmap("assets/textures/powerup_rapid.png")
	imgPowerupMulti = al_load_bitmap("assets/textures/powerup_multi.png")
	imgPowerupSpread = al_load_bitmap("assets/textures/powerup_spread.png")
	imgPowerupLife = al_load_bitmap("assets/textures/powerup_life.png")

	if imgPowerupShield = NULL ? "Warning: Could not load powerup_shield.png" ok
	if imgPowerupRapid = NULL ? "Warning: Could not load powerup_rapid.png" ok
	if imgPowerupMulti = NULL ? "Warning: Could not load powerup_multi.png" ok
	if imgPowerupSpread = NULL ? "Warning: Could not load powerup_spread.png" ok
	if imgPowerupLife = NULL ? "Warning: Could not load powerup_life.png" ok

func generateWavFile filename, freq, duration
	# Skip generation if file already exists
	if fexists(filename)
		return
	ok
	
	sampleCount = floor(SAMPLE_RATE * duration)
	dataSize = sampleCount * 2
	
	wavHeader = ""
	wavHeader += "RIFF"
	wavHeader += int32ToBytes(36 + dataSize)
	wavHeader += "WAVE"
	wavHeader += "fmt "
	wavHeader += int32ToBytes(16)
	wavHeader += int16ToBytes(1)
	wavHeader += int16ToBytes(1)
	wavHeader += int32ToBytes(SAMPLE_RATE)
	wavHeader += int32ToBytes(SAMPLE_RATE * 2)
	wavHeader += int16ToBytes(2)
	wavHeader += int16ToBytes(16)
	wavHeader += "data"
	wavHeader += int32ToBytes(dataSize)
	
	samples = ""
	PI2 = 2 * PI
	amplitude = 10000
	
	for i = 0 to sampleCount - 1
		t = i / SAMPLE_RATE
		sample = floor(amplitude * sin(PI2 * freq * t))
		
		fadeLen = floor(sampleCount * 0.1)
		if fadeLen < 1 fadeLen = 1 ok
		if i < fadeLen
			sample = floor(sample * i / fadeLen)
		ok
		if i > sampleCount - fadeLen
			sample = floor(sample * (sampleCount - i) / fadeLen)
		ok
		
		samples += int16ToBytes(sample)
	next
	
	write(filename, wavHeader + samples)

func int16ToBytes value
	if value < 0
		value = value + 65536
	ok
	return char(value & 255) + char((value >> 8) & 255)

func int32ToBytes value
	return char(value & 255) + char((value >> 8) & 255) + char((value >> 16) & 255) + char((value >> 24) & 255)

func playSnd soundType
	if !soundEnabled return ok
	
	switch soundType
		on SOUND_SHOOT
			if sndShoot != NULL al_play_sample(sndShoot, 0.3, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_ENEMY_HIT
			if sndEnemyHit != NULL al_play_sample(sndEnemyHit, 0.3, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_HIT
			if sndUfoHit != NULL al_play_sample(sndUfoHit, 0.4, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_PLAYER_HIT
			if sndPlayerHit != NULL al_play_sample(sndPlayerHit, 1.0, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_POWERUP
			if sndPowerup != NULL al_play_sample(sndPowerup, 0.4, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_WAVE_CLEAR
			if sndWaveClear != NULL al_play_sample(sndWaveClear, 0.4, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_1UP
			if snd1Up != NULL al_play_sample(snd1Up, 0.5, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_SPAWN
			if sndUfoSpawn != NULL al_play_sample(sndUfoSpawn, 0.3, 0.0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
	off

func playSndAtPosition soundType, xPos
	# Pan ranges from -1.0 (left) to 1.0 (right)
	if !soundEnabled return ok
	
	# Calculate pan: center of screen = 0, edges = -1 or 1
	pan = (xPos - (BASE_W / 2)) / (BASE_W / 2)
	
	# Clamp pan to valid range
	if pan < -1.0 pan = -1.0 ok
	if pan > 1.0 pan = 1.0 ok
	
	switch soundType
		on SOUND_SHOOT
			if sndShoot != NULL al_play_sample(sndShoot, 0.3, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_ENEMY_HIT
			if sndEnemyHit != NULL al_play_sample(sndEnemyHit, 0.3, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_HIT
			if sndUfoHit != NULL al_play_sample(sndUfoHit, 0.4, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_PLAYER_HIT
			if sndPlayerHit != NULL al_play_sample(sndPlayerHit, 1.0, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_POWERUP
			if sndPowerup != NULL al_play_sample(sndPowerup, 0.4, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_WAVE_CLEAR
			if sndWaveClear != NULL al_play_sample(sndWaveClear, 0.4, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_1UP
			if snd1Up != NULL al_play_sample(snd1Up, 0.5, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_SPAWN
			if sndUfoSpawn != NULL al_play_sample(sndUfoSpawn, 0.3, pan, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
	off

func playSndAtPositionWithPitch soundType, xPos, pitch
	# Positional audio with pitch control (for combos)
	if !soundEnabled return ok
	
	# Calculate pan
	pan = (xPos - (BASE_W / 2)) / (BASE_W / 2)
	if pan < -1.0 pan = -1.0 ok
	if pan > 1.0 pan = 1.0 ok
	
	# Clamp pitch
	if pitch < 0.5 pitch = 0.5 ok
	if pitch > 2.0 pitch = 2.0 ok
	
	switch soundType
		on SOUND_SHOOT
			if sndShoot != NULL al_play_sample(sndShoot, 0.3, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_ENEMY_HIT
			if sndEnemyHit != NULL al_play_sample(sndEnemyHit, 0.3, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_HIT
			if sndUfoHit != NULL al_play_sample(sndUfoHit, 0.4, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_PLAYER_HIT
			if sndPlayerHit != NULL al_play_sample(sndPlayerHit, 1.0, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_POWERUP
			if sndPowerup != NULL al_play_sample(sndPowerup, 0.4, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_WAVE_CLEAR
			if sndWaveClear != NULL al_play_sample(sndWaveClear, 0.4, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_1UP
			if snd1Up != NULL al_play_sample(snd1Up, 0.5, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
		on SOUND_UFO_SPAWN
			if sndUfoSpawn != NULL al_play_sample(sndUfoSpawn, 0.3, pan, pitch, ALLEGRO_PLAYMODE_ONCE, sampleId) ok
	off

func playMusicType musicType
	if !musicEnabled return ok
	
	# Don't restart if same music is already playing
	if currentMusicType = musicType return ok
	
	# Stop current music
	al_stop_sample(musicSampleId)
	
	# Play the requested music
	musicSample = NULL
	switch musicType
		on MUSIC_MENU
			musicSample = musicMenu
		on MUSIC_MAIN
			musicSample = musicMain
		on MUSIC_BOSS
			musicSample = musicBoss
	off
	
	if musicSample != NULL
		al_play_sample(musicSample, 0.5, 0.0, 1.0, ALLEGRO_PLAYMODE_LOOP, musicSampleId)
		currentMusicType = musicType
	ok

func stopMusic
	al_stop_sample(musicSampleId)
	currentMusicType = MUSIC_NONE

func updateMusic
	# Determine which music should be playing based on game state
	switch gameState
		on STATE_MENU
			playMusicType(MUSIC_MENU)
		on STATE_PLAYING
			if bossActive
				playMusicType(MUSIC_BOSS)
			else
				playMusicType(MUSIC_MAIN)
			ok
		on STATE_PAUSED
			# Keep current music playing (do nothing)
		on STATE_GAMEOVER
			playMusicType(MUSIC_MENU)
	off

func toggleSound
	soundEnabled = !soundEnabled
	musicEnabled = soundEnabled
	
	# Use mixer gain to mute/unmute all audio without stopping
	if soundEnabled
		al_set_mixer_gain(al_get_default_mixer(), 1.0)
	else
		al_set_mixer_gain(al_get_default_mixer(), 0.0)
	ok
