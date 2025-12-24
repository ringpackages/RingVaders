/*
	RingVaders - Player Module
	Player logic, movement, and rendering
*/

func updatePlayer
	if keyLeft
		playerX -= playerSpeed
	ok
	if keyRight
		playerX += playerSpeed
	ok
	
	if playerX < 25 playerX = 25 ok
	if playerX > BASE_W - 25 playerX = BASE_W - 25 ok
	
	if playerCooldown > 0 playerCooldown-- ok
	
	cooldownTime = baseCooldown
	if rapidPower > 0 cooldownTime = baseCooldown / 3 ok
	
	if (keySpace or keyUp) and playerCooldown <= 0
		shotsFired++
		waveShotsFired++
		playerCooldown = cooldownTime
		playSndAtPosition(SOUND_SHOOT, playerX)
		
		if spreadPower > 0
			spawnBullet(playerX, playerY - 15, 0, -9)
			spawnBullet(playerX - 8, playerY - 12, -2, -9)
			spawnBullet(playerX + 8, playerY - 12, 2, -9)
		but multiPower > 0
			spawnBullet(playerX - 12, playerY - 15, 0, -9)
			spawnBullet(playerX, playerY - 18, 0, -9)
			spawnBullet(playerX + 12, playerY - 15, 0, -9)
		else
			spawnBullet(playerX, playerY - 15, 0, -9)
		ok
	ok
	
	if shieldPower > 0 shieldPower-- ok
	if rapidPower > 0 rapidPower-- ok
	if multiPower > 0 multiPower-- ok
	if spreadPower > 0 spreadPower-- ok
	if invincibleTimer > 0 invincibleTimer-- ok

func playerHit
	gameLives--
	waveDamageTaken = true
	invincibleTimer = 90
	explode(playerX, playerY, 76, 175, 80, 20)
	shakeIntensity = 10
	playSnd(SOUND_PLAYER_HIT)
	
	if gameLives <= 0
		startDeathAnimation()
	else
		playerX = BASE_W / 2
	ok

func startDeathAnimation
	gameState = STATE_PLAYER_DEATH
	deathAnimTimer = 0
	deathExplosionPhase = 0
	shakeIntensity = 15
	
	# Create ship fragment pieces that fly outward
	deathShipPieces = []
	angles = [0, 45, 90, 135, 180, 225, 270, 315]
	for i = 1 to len(angles)
		angle = angles[i] * PI / 180
		speed = 1.5 + random(10) / 10.0
		add(deathShipPieces, [
			:x = playerX,
			:y = playerY,
			:vx = cos(angle) * speed,
			:vy = sin(angle) * speed,
			:rot = random(360),
			:rotSpeed = (random(10) - 5) * 0.1,
			:size = 4 + random(8),
			:alpha = 255
		])
	next

func updateDeathAnimation
	deathAnimTimer++
	
	# Update ship pieces
	for i = 1 to len(deathShipPieces)
		piece = deathShipPieces[i]
		piece[:x] += piece[:vx]
		piece[:y] += piece[:vy]
		piece[:vy] += 0.03
		piece[:rot] += piece[:rotSpeed]
		piece[:alpha] = 255 * (1 - deathAnimTimer / deathAnimDuration)
		if piece[:alpha] < 0 piece[:alpha] = 0 ok
		deathShipPieces[i] = piece
	next
	
	# Trigger explosion bursts at different phases
	if deathAnimTimer = 1
		explode(playerX, playerY, 255, 100, 50, 30)
	ok
	if deathAnimTimer = 15
		explode(playerX - 10, playerY - 5, 255, 200, 50, 20)
	ok
	if deathAnimTimer = 30
		explode(playerX + 10, playerY + 5, 255, 150, 50, 25)
	ok
	if deathAnimTimer = 45
		explode(playerX, playerY - 10, 200, 200, 255, 15)
	ok
	
	# Screen shake during explosion
	if deathAnimTimer < 60
		shakeIntensity = 15 - (deathAnimTimer / 4)
	ok
	
	# Transition to game over after animation
	if deathAnimTimer >= deathAnimDuration
		doGameOver()
	ok

func drawPlayerShip offsetX, offsetY
	px = offsetX + playerX
	py = offsetY + playerY
	
	# Invincibility blinking effect - skip drawing every 4 frames
	if invincibleTimer > 0 and floor(frameCount / 4) % 2 = 1
		return
	ok
	
	# Cannon colors
	cannonColor = al_map_rgb(76, 175, 80)
	cannonLight = al_map_rgb(129, 199, 132)
	cannonDark = al_map_rgb(46, 125, 50)
	
	# Shield effect
	if shieldPower > 0 and shieldHits > 0
		alpha = floor(128 + sin(frameCount * 0.1) * 64)
		shieldColor = al_map_rgba(90, 159, 212, alpha)
		# Draw multiple rings based on shield hits remaining
		for i = 1 to shieldHits
			al_draw_circle(px, py, 26 + i * 5, shieldColor, 2)
		next
	ok
	
	# Glow behind cannon
	glowColor = al_map_rgba(76, 175, 80, 40)
	al_draw_filled_rectangle(px - 22, py - 8, px + 22, py + 14, glowColor)
	
	# Base of cannon (wide rectangle)
	al_draw_filled_rectangle(px - 20, py + 2, px + 20, py + 12, cannonColor)
	
	# Middle section
	al_draw_filled_rectangle(px - 14, py - 4, px + 14, py + 2, cannonColor)
	
	# Upper section
	al_draw_filled_rectangle(px - 8, py - 10, px + 8, py - 4, cannonColor)
	
	# Cannon barrel (top)
	al_draw_filled_rectangle(px - 3, py - 20, px + 3, py - 10, cannonColor)
	
	# Highlights
	al_draw_filled_rectangle(px - 18, py + 4, px - 14, py + 10, cannonLight)
	al_draw_filled_rectangle(px - 2, py - 18, px + 2, py - 12, cannonLight)
	
	# Dark accents
	al_draw_filled_rectangle(px + 14, py + 4, px + 18, py + 10, cannonDark)
	
	# Rapid fire indicator
	if rapidPower > 0
		al_draw_circle(px, py, 25, cannonLight, 2)
	ok

func drawDeathAnimation offsetX, offsetY
	# Draw ship fragments
	for i = 1 to len(deathShipPieces)
		piece = deathShipPieces[i]
		if piece[:alpha] > 0
			x = offsetX + piece[:x]
			y = offsetY + piece[:y]
			size = piece[:size]
			alpha = floor(piece[:alpha])
			
			# Draw fragment as glowing piece
			al_draw_filled_rectangle(x - size/2, y - size/2, x + size/2, y + size/2, 
									al_map_rgba(76, 175, 80, alpha))
			al_draw_filled_rectangle(x - size/3, y - size/3, x + size/3, y + size/3,
									al_map_rgba(150, 255, 150, alpha))
		ok
	next
	
	# Flash effect during early animation
	if deathAnimTimer < 10
		flashAlpha = (10 - deathAnimTimer) * 20
		al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(255, 255, 255, flashAlpha))
	ok
	
	# Fade to darker as animation progresses
	fadeAlpha = floor(deathAnimTimer * 1.5)
	if fadeAlpha > 180 fadeAlpha = 180 ok
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, fadeAlpha))
