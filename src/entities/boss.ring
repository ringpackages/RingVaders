/*
	RingVaders - Boss Module
	Boss enemy logic and rendering
*/

func updateBoss
	if !bossActive return ok
	
	# Boss movement (side to side)
	bossX += sin(frameCount * 0.02) * 2
	
	# Keep boss in bounds
	if bossX < 80 bossX = 80 ok
	if bossX > BASE_W - 80 bossX = BASE_W - 80 ok
	
	# Boss shooting - slower shooting at dangerous phases
	bossShootTimer--
	if bossShootTimer <= 0
		baseTimer = 30 - gameWave * 2
		if baseTimer < 15 baseTimer = 15 ok
		# Phase 2 (5-way) gets extra delay
		if bossPhase = 2
			bossShootTimer = baseTimer + 10
		else
			bossShootTimer = baseTimer
		ok
		
		# Different attack patterns based on phase
		switch bossPhase
			on 0
				# Single aimed shot
				spawnEnemyBullet(bossX, bossY + 40)
			on 1
				# Triple spread
				spawnEnemyBullet(bossX - 30, bossY + 40)
				spawnEnemyBullet(bossX, bossY + 40)
				spawnEnemyBullet(bossX + 30, bossY + 40)
			on 2
				# Five-way spread
				spawnEnemyBullet(bossX - 50, bossY + 30)
				spawnEnemyBullet(bossX - 25, bossY + 40)
				spawnEnemyBullet(bossX, bossY + 45)
				spawnEnemyBullet(bossX + 25, bossY + 40)
				spawnEnemyBullet(bossX + 50, bossY + 30)
		off
	ok
	
	# Update phase based on health
	healthPercent = bossHealth * 100 / bossMaxHealth
	if healthPercent > 66
		bossPhase = 0
	but healthPercent > 33
		bossPhase = 1
		# Drop powerup when entering phase 1 (66% health)
		if !bossDroppedPhase1
			bossDroppedPhase1 = true
			spawnPowerup(bossX, bossY + 60, true)
			playSnd(SOUND_POWERUP)
		ok
	else
		bossPhase = 2
		# Drop powerup when entering phase 2 (33% health)
		if !bossDroppedPhase2
			bossDroppedPhase2 = true
			spawnPowerup(bossX, bossY + 60, true)
			playSnd(SOUND_POWERUP)
		ok
	ok
	
	# Reduce hit flash
	if bossHitFlash > 0 bossHitFlash-- ok

func spawnBoss
	bossActive = true
	bossX = BASE_W / 2
	bossY = 80
	
	# Boss health based on difficulty
	baseHealth = 50 + gameWave * 15
	switch gameDifficulty
		on DIFF_EASY
			bossMaxHealth = floor(baseHealth * 0.6)
		on DIFF_NORMAL
			bossMaxHealth = baseHealth
		on DIFF_HARD
			bossMaxHealth = floor(baseHealth * 1.5)
	off
	
	bossHealth = bossMaxHealth
	bossPhase = 0
	bossShootTimer = 60
	bossHitFlash = 0
	bossDroppedPhase1 = false
	bossDroppedPhase2 = false

func drawBoss offsetX, offsetY
	x = offsetX + bossX
	y = offsetY + bossY
	
	# Boss colors based on phase
	switch bossPhase
		on 0
			bossColorR = 156
			bossColorG = 39
			bossColorB = 176
		on 1
			bossColorR = 255
			bossColorG = 152
			bossColorB = 0
		on 2
			bossColorR = 244
			bossColorG = 67
			bossColorB = 54
	off
	
	# Flash white when hit
	if bossHitFlash > 0
		bossColorR = 255
		bossColorG = 255
		bossColorB = 255
	ok
	
	mainColor = al_map_rgb(bossColorR, bossColorG, bossColorB)
	glowColor = al_map_rgba(bossColorR, bossColorG, bossColorB, 60)
	darkColor = al_map_rgb(floor(bossColorR * 0.7), floor(bossColorG * 0.7), floor(bossColorB * 0.7))
	
	# Floating animation
	floatY = sin(frameCount * 0.05) * 5
	y = y + floatY
	
	# Glow effect
	al_draw_filled_ellipse(x, y, 75, 50, glowColor)
	
	# Main body (large alien)
	al_draw_filled_rectangle(x - 60, y - 30, x + 60, y + 30, mainColor)
	
	# Head
	al_draw_filled_rectangle(x - 40, y - 45, x + 40, y - 30, mainColor)
	al_draw_filled_rectangle(x - 25, y - 55, x + 25, y - 45, mainColor)
	
	# Horns/antennas
	pulse = sin(frameCount * 0.1) * 4
	al_draw_filled_rectangle(x - 55, y - 55 + pulse, x - 45, y - 30, mainColor)
	al_draw_filled_rectangle(x + 45, y - 55 - pulse, x + 55, y - 30, mainColor)
	
	# Eyes (menacing)
	al_draw_filled_rectangle(x - 35, y - 20, x - 10, y, C_EYES)
	al_draw_filled_rectangle(x + 10, y - 20, x + 35, y, C_EYES)
	
	# Eye glow (red for danger)
	eyeGlow = al_map_rgba(255, 0, 0, 100 + floor(sin(frameCount * 0.15) * 50))
	al_draw_filled_rectangle(x - 30, y - 15, x - 15, y - 5, eyeGlow)
	al_draw_filled_rectangle(x + 15, y - 15, x + 30, y - 5, eyeGlow)
	
	# Side cannons
	al_draw_filled_rectangle(x - 75, y - 10, x - 60, y + 20, darkColor)
	al_draw_filled_rectangle(x + 60, y - 10, x + 75, y + 20, darkColor)
	
	# Bottom details
	legPhase = floor(frameCount / 20) % 2
	if legPhase = 0
		al_draw_filled_rectangle(x - 50, y + 30, x - 35, y + 45, mainColor)
		al_draw_filled_rectangle(x - 15, y + 30, x + 15, y + 40, mainColor)
		al_draw_filled_rectangle(x + 35, y + 30, x + 50, y + 45, mainColor)
	else
		al_draw_filled_rectangle(x - 45, y + 30, x - 30, y + 40, mainColor)
		al_draw_filled_rectangle(x - 10, y + 30, x + 10, y + 50, mainColor)
		al_draw_filled_rectangle(x + 30, y + 30, x + 45, y + 40, mainColor)
	ok
	
	# Health bar
	healthBarWidth = 100
	healthPercent = bossHealth / bossMaxHealth
	al_draw_filled_rectangle(x - healthBarWidth/2 - 2, y - 70, x + healthBarWidth/2 + 2, y - 60, al_map_rgb(40, 40, 40))
	al_draw_filled_rectangle(x - healthBarWidth/2, y - 68, x - healthBarWidth/2 + healthBarWidth * healthPercent, y - 62, al_map_rgb(255, 0, 0))
	
	# "BOSS" label
	al_draw_text(font, C_WHITE, x, y - 85, ALLEGRO_ALIGN_CENTER, "BOSS")
