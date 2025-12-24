/*
	RingVaders - Game State Module
	Game state management, waves, shields
*/

func startGame
	gameState = STATE_PLAYING
	gameScore = 0
	
	# Set lives based on difficulty
	switch gameDifficulty
		on DIFF_EASY
			gameLives = 5
		on DIFF_NORMAL
			gameLives = 3
		on DIFF_HARD
			gameLives = 2
	off
	
	gameWave = 1
	gameCombo = 0
	comboTimer = 0
	lastKillTime = 0
	shotsFired = 0
	shotsHit = 0
	gameStartTime = frameCount
	gamePlayTime = 0
	totalKills = 0
	maxCombo = 0
	powerupsCollected = 0
	shakeX = 0
	shakeY = 0
	shakeIntensity = 0
	
	playerX = BASE_W / 2
	playerY = BASE_H - 60
	shieldPower = 0
	shieldHits = 0
	invincibleTimer = 0
	rapidPower = 0
	multiPower = 0
	spreadPower = 0
	playerCooldown = 0
	
	for i = 1 to MAX_BULLETS
		bullets[i][:active] = false
	next
	for i = 1 to MAX_ENEMY_BULLETS
		enemyBullets[i][:active] = false
	next
	for i = 1 to MAX_PARTICLES
		particles[i][:active] = false
	next
	for i = 1 to MAX_POWERUPS
		powerups[i][:active] = false
	next
	for i = 1 to MAX_SCORE_POPUPS
		scorePopups[i][:active] = false
	next
	for i = 1 to MAX_BULLET_TRAILS
		bulletTrails[i][:active] = false
	next
	
	ufoActive = false
	bossActive = false
	
	createShields()
	spawnWave()

func doGameOver
	gameState = STATE_GAMEOVER
	
	# Calculate play time
	gamePlayTime = frameCount - gameStartTime
	
	if shotsFired > 0
		accuracy = shotsHit / shotsFired
		accuracyBonus = floor(accuracy * 1000)
		gameScore += accuracyBonus
	ok
	
	if gameScore > highScore
		highScore = gameScore
		saveHighScore()
	ok

func nextWave
	# This is called when boss is defeated
	# Trigger wave announcement (which handles wave increment and spawning)
	triggerWaveAnnouncement()
	comboTimer = 90

func createShields
	for i = 1 to MAX_SHIELDS
		shields[i][:active] = false
	next
	
	shieldW = 60
	shieldH = 40
	gap = (BASE_W - 4 * shieldW) / 5
	idx = 1
	
	for i = 0 to 3
		sx = gap + i * (shieldW + gap)
		sy = BASE_H - 150
		
		for r = 0 to 3
			for c = 0 to 5
				if r = 0 and (c = 0 or c = 5) loop ok
				
				if idx <= MAX_SHIELDS
					shields[idx][:x] = sx + c * 10
					shields[idx][:y] = sy + r * 10
					shields[idx][:w] = 10
					shields[idx][:h] = 10
					shields[idx][:health] = 3
					shields[idx][:active] = true
					idx++
				ok
			next
		next
	next

func triggerWaveAnnouncement
	gameState = STATE_WAVE_ANNOUNCE
	waveAnnounceTimer = 120
	
	# Check wave-based achievements before incrementing wave
	if not waveDamageTaken
		unlockAchievement("perfect_wave")
	ok
	
	# Sharpshooter: 100% accuracy in a wave
	if waveShotsFired > 0 and waveShotsHit = waveShotsFired
		unlockAchievement("no_miss")
	ok
	
	# Increment wave
	gameWave++
	
	# Play wave clear sound
	playSnd(SOUND_WAVE_CLEAR)

func updateWaveAnnouncement
	waveAnnounceTimer--
	
	if waveAnnounceTimer <= 0
		gameState = STATE_PLAYING
		
		# Boss battle every 5 waves
		if gameWave % 5 = 0
			spawnBoss()
			playSnd(SOUND_UFO_SPAWN)
		else
			spawnWave()
		ok
	ok

func updateStars
	for i = 1 to MAX_STARS
		stars[i][:y] += stars[i][:speed]
		if stars[i][:y] > BASE_H
			stars[i][:y] = 0
			stars[i][:x] = random(BASE_W)
			stars[i][:speed] = 0.5 + random(200)/100.0
			stars[i][:brightness] = 100 + random(155)
		ok
	next

func updateFPS
	fpsFrameCount++
	currentTime = al_get_time()
	
	# Update FPS every second
	if currentTime - fpsLastTime >= 1.0
		currentFPS = fpsFrameCount
		fpsFrameCount = 0
		fpsLastTime = currentTime
	ok

func updateGame
	# Update FPS counter
	updateFPS()
	
	# Always update stars (even in menu/pause for nice effect)
	updateStars()
	
	# Update music based on current game state
	updateMusic()
	
	if gameState = STATE_PLAYING
		updatePlayer()
		updateBullets()
		updateBulletTrails()
		updateEnemies()
		updateUFO()
		updateBoss()
		updateCollisions()
		updateParticles()
		updatePowerups()
		updateScorePopups()
		updateUI()
		updateLowHealthWarning()
		updateAchievementPopup()
		
		# Check wave complete (only if no boss active)
		if !bossActive
			aliveCount = 0
			for i = 1 to MAX_ENEMIES
				if enemies[i][:alive] aliveCount++ ok
			next
			if aliveCount = 0
				triggerWaveAnnouncement()
			ok
		ok
	ok
	
	# Handle wave announcement state
	if gameState = STATE_WAVE_ANNOUNCE
		updateWaveAnnouncement()
	ok
	
	# Handle player death animation
	if gameState = STATE_PLAYER_DEATH
		updateDeathAnimation()
		updateParticles()
	ok
