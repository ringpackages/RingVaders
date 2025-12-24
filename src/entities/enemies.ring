/*
	RingVaders - Enemies Module
	Enemy logic, movement, and rendering
*/

func updateEnemies
	hitEdge = false
	
	# Update grace period
	if waveGracePeriod > 0
		waveGracePeriod--
	ok
	
	# Count alive enemies to speed up as they die
	aliveCount = 0
	for i = 1 to MAX_ENEMIES
		if enemies[i][:alive] aliveCount++ ok
	next
	
	# Speed multiplier - fewer enemies = faster movement
	if aliveCount > 0
		speedMultiplier = totalEnemiesInWave / aliveCount
		# Cap multiplier to prevent insane speed with last few enemies
		if speedMultiplier > 6 speedMultiplier = 6 ok
		enemySpeed = baseEnemySpeed * speedMultiplier
	ok
	
	for i = 1 to MAX_ENEMIES
		if enemies[i][:alive]
			enemies[i][:x] += enemyDir * enemySpeed
			if enemies[i][:x] < 35 or enemies[i][:x] > BASE_W - 35
				hitEdge = true
			ok
			
			# Only shoot after grace period
			if waveGracePeriod <= 0 and random(1000) < enemyShootChance * 1000
				spawnEnemyBullet(enemies[i][:x], enemies[i][:y] + 20)
			ok
			
			# Update hit flash
			if enemies[i][:hitFlash] > 0
				enemies[i][:hitFlash]--
			ok
		ok
	next
	
	if hitEdge
		enemyDir *= -1
		for i = 1 to MAX_ENEMIES
			if enemies[i][:alive]
				enemies[i][:y] += enemyDropAmount
			ok
		next
	ok
	
	for i = 1 to MAX_ENEMIES
		if enemies[i][:alive] and enemies[i][:y] > BASE_H - 100
			doGameOver()
			return
		ok
	next
	
	# UFO spawn
	if !ufoActive
		aliveCount = 0
		for i = 1 to MAX_ENEMIES
			if enemies[i][:alive] aliveCount++ ok
		next
		if aliveCount > 0 and random(2000) < (1 + gameWave)
			ufoActive = true
			if random(2) = 1
				ufoDir = 1
				ufoX = -60
			else
				ufoDir = -1
				ufoX = BASE_W + 60
			ok
			ufoSpeed = 2 + gameWave * 0.1
			if ufoSpeed > 3.5 ufoSpeed = 3.5 ok
			ufoPoints = 300 + gameWave * 25
			playSnd(SOUND_UFO_SPAWN)
		ok
	ok

func updateUFO
	if !ufoActive return ok
	
	ufoX += ufoDir * ufoSpeed
	
	if (ufoDir > 0 and ufoX > BASE_W + 80) or (ufoDir < 0 and ufoX < -80)
		ufoActive = false
	ok

func spawnWave
	for i = 1 to MAX_ENEMIES
		enemies[i][:alive] = false
	next
	
	# Reset wave tracking for achievements
	waveDamageTaken = false
	waveShotsFired = 0
	waveShotsHit = 0
	
	# 5 rows x 11 columns = 55 aliens
	rows = 5
	cols = 11
	
	# Tighter spacing to fit 11 columns in play area
	spacing = 50
	startX = (BASE_W - cols * spacing) / 2 + spacing / 2
	idx = 1
	
	for r = 0 to rows - 1
		for c = 0 to cols - 1
			if idx <= MAX_ENEMIES
				enemies[idx][:x] = startX + c * spacing
				enemies[idx][:y] = 70 + r * 40
				enemies[idx][:alive] = true
				enemies[idx][:animOffset] = random(120)
				
				# Assign enemy types based on row and wave
				# Later waves introduce armored (wave 3+) and speeder (wave 6+) enemies
				switch r
					on 0  # Bottom row - Crab type
						enemies[idx][:etype] = ENEMY_CRAB
						enemies[idx][:points] = 10 * (1 + floor(gameWave / 5))
						enemies[idx][:health] = 1
						enemies[idx][:maxHealth] = 1
						enemies[idx][:colorR] = 76
						enemies[idx][:colorG] = 175
						enemies[idx][:colorB] = 80
					on 1  # Second row - Crab or Armored (wave 3+)
						if gameWave >= 3 and c % 3 = 0
							enemies[idx][:etype] = ENEMY_ARMORED
							enemies[idx][:points] = 25 * (1 + floor(gameWave / 5))
							enemies[idx][:health] = 2
							enemies[idx][:maxHealth] = 2
							enemies[idx][:colorR] = 150
							enemies[idx][:colorG] = 150
							enemies[idx][:colorB] = 170
						else
							enemies[idx][:etype] = ENEMY_CRAB
							enemies[idx][:points] = 10 * (1 + floor(gameWave / 5))
							enemies[idx][:health] = 1
							enemies[idx][:maxHealth] = 1
							enemies[idx][:colorR] = 76
							enemies[idx][:colorG] = 175
							enemies[idx][:colorB] = 80
						ok
					on 2  # Middle row - Squid type
						enemies[idx][:etype] = ENEMY_SQUID
						enemies[idx][:points] = 20 * (1 + floor(gameWave / 5))
						enemies[idx][:health] = 1
						enemies[idx][:maxHealth] = 1
						enemies[idx][:colorR] = 0
						enemies[idx][:colorG] = 188
						enemies[idx][:colorB] = 212
					on 3  # Fourth row - Squid or Speeder (wave 6+)
						if gameWave >= 6 and c % 4 = 0
							enemies[idx][:etype] = ENEMY_SPEEDER
							enemies[idx][:points] = 35 * (1 + floor(gameWave / 5))
							enemies[idx][:health] = 1
							enemies[idx][:maxHealth] = 1
							enemies[idx][:colorR] = 255
							enemies[idx][:colorG] = 200
							enemies[idx][:colorB] = 50
						else
							enemies[idx][:etype] = ENEMY_SQUID
							enemies[idx][:points] = 20 * (1 + floor(gameWave / 5))
							enemies[idx][:health] = 1
							enemies[idx][:maxHealth] = 1
							enemies[idx][:colorR] = 0
							enemies[idx][:colorG] = 188
							enemies[idx][:colorB] = 212
						ok
					on 4  # Top row - Octopus type (most valuable)
						enemies[idx][:etype] = ENEMY_OCTOPUS
						enemies[idx][:points] = 30 * (1 + floor(gameWave / 5))
						enemies[idx][:health] = 1
						enemies[idx][:maxHealth] = 1
						enemies[idx][:colorR] = 156
						enemies[idx][:colorG] = 39
						enemies[idx][:colorB] = 176
				off
				
				idx++
			ok
		next
	next
	
	enemyDir = 1
	waveGracePeriod = 60
	
	# Apply difficulty modifiers
	diffSpeedMult = 1.0
	diffShootMult = 1.0
	switch gameDifficulty
		on DIFF_EASY
			diffSpeedMult = 0.7
			diffShootMult = 0.5
		on DIFF_NORMAL
			diffSpeedMult = 1.0
			diffShootMult = 1.0
		on DIFF_HARD
			diffSpeedMult = 1.4
			diffShootMult = 1.8
	off
	
	# Start slow, slight increase per wave
	# Base speed is very slow, speeds up dynamically as enemies die (see updateEnemies)
	waveScale = log(gameWave + 1) / log(2)  # Logarithmic scaling
	baseEnemySpeed = (0.12 + waveScale * 0.03) * diffSpeedMult
	if baseEnemySpeed > 0.35 * diffSpeedMult baseEnemySpeed = 0.35 * diffSpeedMult ok
	enemySpeed = baseEnemySpeed
	totalEnemiesInWave = 55  # For dynamic speed calculation
	
	enemyShootChance = (0.0008 + waveScale * 0.0006) * diffShootMult
	if enemyShootChance > 0.005 * diffShootMult enemyShootChance = 0.005 * diffShootMult ok

func drawAlienInvader x, y, scale, r, g, b
	# Check for sprite first
	# (sprites would be loaded based on enemy type, using procedural as fallback)
	
	drawAlienProceduralAnimated(x, y, scale, r, g, b, 0)

func drawAlienProceduralAnimated x, y, scale, r, g, b, animOffset
	# Animated alien with 4 animation frames
	mainColor = al_map_rgb(r, g, b)
	glowColor = al_map_rgba(r, g, b, 50)
	lightColor = al_map_rgb(floor(r * 1.3), floor(g * 1.3), floor(b * 1.3))
	if floor(r * 1.3) > 255 lightColor = al_map_rgb(255, floor(g * 1.3), floor(b * 1.3)) ok
	
	# Pixel size for blocky look
	px = 3 * scale
	
	# 4-frame animation cycle (smoother than 2-frame)
	animFrame = floor((frameCount + animOffset) / ENEMY_ANIM_SPEED) % 4
	
	# Breathing pulse effect
	breathe = sin((frameCount + animOffset) * 0.06) * 1.5 * scale
	
	# Antenna wiggle based on frame
	antennaL = 0
	antennaR = 0
	switch animFrame
		on 0
			antennaL = -2 * scale
			antennaR = 2 * scale
		on 1
			antennaL = 0
			antennaR = 0
		on 2
			antennaL = 2 * scale
			antennaR = -2 * scale
		on 3
			antennaL = 0
			antennaR = 0
	off
	
	# Glow effect
	al_draw_filled_rectangle(x - 12*px - 2, y - 8*px - 2, x + 12*px + 2, y + 8*px + 2, glowColor)
	
	# Main body (center block) with breathing
	al_draw_filled_rectangle(x - 8*px, y - 4*px + breathe, x + 8*px, y + 4*px, mainColor)
	
	# Head section (top)
	al_draw_filled_rectangle(x - 6*px, y - 6*px + breathe, x + 6*px, y - 4*px + breathe, mainColor)
	al_draw_filled_rectangle(x - 4*px, y - 8*px + breathe, x + 4*px, y - 6*px + breathe, mainColor)
	
	# Highlight on head
	al_draw_filled_rectangle(x - 3*px, y - 7*px + breathe, x + 1*px, y - 6*px + breathe, lightColor)
	
	# Antennas (animated wiggle)
	al_draw_filled_rectangle(x - 10*px, y - 8*px + antennaL + breathe, x - 8*px, y - 4*px + breathe, mainColor)
	al_draw_filled_rectangle(x + 8*px, y - 8*px + antennaR + breathe, x + 10*px, y - 4*px + breathe, mainColor)
	
	# Eyes (animated blink every ~3 seconds)
	blinkFrame = floor(frameCount / 180) % 20
	if blinkFrame = 0
		# Blinking - draw thin line
		al_draw_filled_rectangle(x - 5*px, y - 1*px, x - 2*px, y, C_EYES)
		al_draw_filled_rectangle(x + 2*px, y - 1*px, x + 5*px, y, C_EYES)
	else
		# Normal eyes
		al_draw_filled_rectangle(x - 5*px, y - 3*px, x - 2*px, y, C_EYES)
		al_draw_filled_rectangle(x + 2*px, y - 3*px, x + 5*px, y, C_EYES)
		# Eye shine
		al_draw_filled_rectangle(x - 4*px, y - 2*px, x - 3*px, y - 1*px, al_map_rgb(60, 60, 60))
		al_draw_filled_rectangle(x + 3*px, y - 2*px, x + 4*px, y - 1*px, al_map_rgb(60, 60, 60))
	ok
	
	# Arms/side extensions (animated wave)
	armWave = sin((frameCount + animOffset) * 0.1) * 2 * scale
	al_draw_filled_rectangle(x - 12*px, y - 2*px + armWave, x - 8*px, y + 2*px + armWave, mainColor)
	al_draw_filled_rectangle(x + 8*px, y - 2*px - armWave, x + 12*px, y + 2*px - armWave, mainColor)
	
	# Legs (4-frame walk cycle)
	switch animFrame
		on 0
			# Frame 1: Left leg forward, right back
			al_draw_filled_rectangle(x - 10*px, y + 4*px, x - 6*px, y + 8*px, mainColor)
			al_draw_filled_rectangle(x - 3*px, y + 4*px, x + 0*px, y + 6*px, mainColor)
			al_draw_filled_rectangle(x + 3*px, y + 4*px, x + 6*px, y + 5*px, mainColor)
			al_draw_filled_rectangle(x + 6*px, y + 4*px, x + 10*px, y + 6*px, mainColor)
		on 1
			# Frame 2: Both legs middle
			al_draw_filled_rectangle(x - 9*px, y + 4*px, x - 5*px, y + 7*px, mainColor)
			al_draw_filled_rectangle(x - 2*px, y + 4*px, x + 2*px, y + 7*px, mainColor)
			al_draw_filled_rectangle(x + 5*px, y + 4*px, x + 9*px, y + 7*px, mainColor)
		on 2
			# Frame 3: Right leg forward, left back
			al_draw_filled_rectangle(x - 10*px, y + 4*px, x - 6*px, y + 6*px, mainColor)
			al_draw_filled_rectangle(x - 3*px, y + 4*px, x + 0*px, y + 5*px, mainColor)
			al_draw_filled_rectangle(x + 0*px, y + 4*px, x + 3*px, y + 6*px, mainColor)
			al_draw_filled_rectangle(x + 6*px, y + 4*px, x + 10*px, y + 8*px, mainColor)
		on 3
			# Frame 4: Both legs tucked
			al_draw_filled_rectangle(x - 8*px, y + 4*px, x - 4*px, y + 6*px, mainColor)
			al_draw_filled_rectangle(x - 2*px, y + 4*px, x + 2*px, y + 8*px, mainColor)
			al_draw_filled_rectangle(x + 4*px, y + 4*px, x + 8*px, y + 6*px, mainColor)
	off

func drawArmoredEnemy x, y, scale, r, g, b, animOffset
	# Heavy armored enemy with shield plates
	mainColor = al_map_rgb(r, g, b)
	glowColor = al_map_rgba(r, g, b, 50)
	metalColor = al_map_rgb(floor(r * 0.7), floor(g * 0.7), floor(b * 0.8))
	shineColor = al_map_rgb(200, 200, 220)
	
	px = 3 * scale
	animFrame = floor((frameCount + animOffset) / 15) % 2
	
	# Glow
	al_draw_filled_rectangle(x - 14*px - 2, y - 10*px - 2, x + 14*px + 2, y + 8*px + 2, glowColor)
	
	# Heavy body (wider and boxier)
	al_draw_filled_rectangle(x - 12*px, y - 6*px, x + 12*px, y + 6*px, mainColor)
	
	# Armor plates
	al_draw_filled_rectangle(x - 14*px, y - 4*px, x - 10*px, y + 4*px, metalColor)
	al_draw_filled_rectangle(x + 10*px, y - 4*px, x + 14*px, y + 4*px, metalColor)
	
	# Top armor
	al_draw_filled_rectangle(x - 8*px, y - 10*px, x + 8*px, y - 6*px, metalColor)
	al_draw_filled_rectangle(x - 4*px, y - 8*px, x + 4*px, y - 6*px, shineColor)
	
	# Visor/eyes
	al_draw_filled_rectangle(x - 8*px, y - 3*px, x + 8*px, y + 1*px, al_map_rgb(40, 40, 50))
	al_draw_filled_rectangle(x - 6*px, y - 2*px, x - 2*px, y, al_map_rgb(255, 50, 50))
	al_draw_filled_rectangle(x + 2*px, y - 2*px, x + 6*px, y, al_map_rgb(255, 50, 50))
	
	# Legs (slower animation)
	if animFrame = 0
		al_draw_filled_rectangle(x - 10*px, y + 6*px, x - 6*px, y + 8*px, mainColor)
		al_draw_filled_rectangle(x + 6*px, y + 6*px, x + 10*px, y + 8*px, mainColor)
	else
		al_draw_filled_rectangle(x - 8*px, y + 6*px, x - 4*px, y + 8*px, mainColor)
		al_draw_filled_rectangle(x + 4*px, y + 6*px, x + 8*px, y + 8*px, mainColor)
	ok

func drawSpeederEnemy x, y, scale, r, g, b, animOffset
	# Fast sleek enemy with afterburner effect
	mainColor = al_map_rgb(r, g, b)
	glowColor = al_map_rgba(r, g, b, 60)
	trailColor = al_map_rgba(255, 150, 50, 80)
	
	px = 3 * scale
	animFrame = floor((frameCount + animOffset) / 6) % 4
	
	# Motion trail effect
	for t = 1 to 3
		trailAlpha = 30 - t * 8
		al_draw_filled_ellipse(x - t * 8, y, 10 - t*2, 6, al_map_rgba(r, g, b, trailAlpha))
	next
	
	# Afterburner glow
	burnerSize = 4 + sin((frameCount + animOffset) * 0.3) * 2
	al_draw_filled_ellipse(x - 12*px, y, burnerSize, burnerSize/2, trailColor)
	
	# Sleek body (aerodynamic shape)
	al_draw_filled_ellipse(x, y, 10*px, 5*px, mainColor)
	
	# Pointed nose
	al_draw_filled_triangle(x + 10*px, y - 3*px, x + 10*px, y + 3*px, x + 16*px, y, mainColor)
	
	# Cockpit
	al_draw_filled_ellipse(x + 4*px, y, 4*px, 3*px, al_map_rgb(100, 200, 255))
	al_draw_filled_ellipse(x + 5*px, y - 1*px, 2*px, 1*px, al_map_rgb(200, 255, 255))
	
	# Wings (animated flutter)
	wingOffset = sin((frameCount + animOffset) * 0.2) * 2 * scale
	al_draw_filled_triangle(x - 2*px, y - 5*px + wingOffset, x + 4*px, y - 2*px, x - 6*px, y - 8*px + wingOffset, mainColor)
	al_draw_filled_triangle(x - 2*px, y + 5*px - wingOffset, x + 4*px, y + 2*px, x - 6*px, y + 8*px - wingOffset, mainColor)

func drawUFOGlow offsetX, offsetY
	x = offsetX + ufoX
	y = offsetY + ufoY + sin(frameCount * 0.1) * 3
	
	# Flying saucer UFO
	ufoColor = al_map_rgb(255, 0, 0)
	glowColor = al_map_rgba(255, 0, 0, 60)
	lightColor = al_map_rgb(255, 100, 100)
	
	# Glow effect
	al_draw_filled_ellipse(x, y, 40, 18, glowColor)
	
	# Main saucer body (ellipse)
	al_draw_filled_ellipse(x, y, 35, 12, ufoColor)
	
	# Top dome
	al_draw_filled_ellipse(x, y - 6, 18, 10, lightColor)
	al_draw_filled_ellipse(x, y - 8, 12, 6, al_map_rgb(255, 150, 150))
	
	# Bottom rim detail
	al_draw_filled_rectangle(x - 30, y + 4, x + 30, y + 8, al_map_rgb(180, 0, 0))
	
	# Blinking lights
	lightPhase = floor(frameCount / 8) % 4
	for i = 0 to 3
		lx = x - 24 + i * 16
		if i = lightPhase
			al_draw_filled_circle(lx, y + 6, 3, al_map_rgb(255, 255, 0))
		else
			al_draw_filled_circle(lx, y + 6, 2, al_map_rgb(100, 100, 0))
		ok
	next
