/*
	RingVaders - Rendering Module
	Main drawing and visual effects
*/

func drawGame
	# Render to off-screen buffer first
	al_set_target_bitmap(gameBuffer)
	al_clear_to_color(C_BG)
	
	offsetX = (SCREEN_WIDTH - BASE_W) / 2 + shakeX
	offsetY = shakeY
	
	drawBackground(offsetX, offsetY)
	
	if gameState = STATE_MENU
		drawMenu(offsetX)
	ok
	if gameState = STATE_ACHIEVEMENTS
		drawAchievementsScreen(offsetX)
	ok
	if gameState = STATE_PLAYING or gameState = STATE_WAVE_ANNOUNCE
		drawPlayfield(offsetX, offsetY)
		if gameState = STATE_WAVE_ANNOUNCE
			drawWaveAnnouncement(offsetX)
		ok
	ok
	if gameState = STATE_PAUSED
		drawPlayfield(offsetX, offsetY)
		drawPauseOverlay(offsetX)
	ok
	if gameState = STATE_GAMEOVER
		drawPlayfield(offsetX, offsetY)
		drawGameOverOverlay(offsetX)
	ok
	if gameState = STATE_PLAYER_DEATH
		drawPlayfield(offsetX, offsetY)
		drawDeathAnimation(offsetX, offsetY)
	ok
	
	# CRT scanline effect (drawn last, on top of everything)
	if crtEnabled
		drawCRTEffect()
	ok
	
	# FPS always visible, hints only in menu/pause
	if gameState = STATE_MENU or gameState = STATE_PAUSED or gameState = STATE_ACHIEVEMENTS
		al_draw_text(font, C_WHITE, 10, SCREEN_HEIGHT - 20, ALLEGRO_ALIGN_LEFT, "FPS: " + currentFPS + " | C: CRT | F: Fullscreen")
	else
		al_draw_text(font, al_map_rgba(255, 255, 255, 120), 10, SCREEN_HEIGHT - 20, ALLEGRO_ALIGN_LEFT, "FPS: " + currentFPS)
	ok
	
	# Now draw buffer to display with scaling
	al_set_target_backbuffer(display)
	al_clear_to_color(al_map_rgb(0, 0, 0))
	
	if isFullscreen
		# Calculate scaling to fit display while maintaining aspect ratio
		scaleX = displayWidth / SCREEN_WIDTH
		scaleY = displayHeight / SCREEN_HEIGHT
		scale = scaleX
		if scaleY < scaleX
			scale = scaleY
		ok
		
		# Center the scaled game on screen
		drawW = SCREEN_WIDTH * scale
		drawH = SCREEN_HEIGHT * scale
		drawX = (displayWidth - drawW) / 2
		drawY = (displayHeight - drawH) / 2
		
		al_draw_scaled_bitmap(gameBuffer, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
							  drawX, drawY, drawW, drawH, 0)
	else
		# Windowed mode - draw 1:1
		al_draw_bitmap(gameBuffer, 0, 0, 0)
	ok

func drawBackground offsetX, offsetY
	# Draw parallax starfield
	for i = 1 to MAX_STARS
		sx = offsetX + stars[i][:x]
		sy = offsetY + stars[i][:y]
		brightness = stars[i][:brightness]
		size = stars[i][:size]
		
		# Twinkle effect
		twinkle = sin(frameCount * 0.1 + i) * 30
		finalBrightness = brightness + twinkle
		if finalBrightness > 255 finalBrightness = 255 ok
		if finalBrightness < 50 finalBrightness = 50 ok
		
		starColor = al_map_rgb(finalBrightness, finalBrightness, finalBrightness)
		
		# Larger stars get a subtle glow
		if size > 1
			glowColor = al_map_rgba(finalBrightness, finalBrightness, finalBrightness, 30)
			al_draw_filled_circle(sx, sy, size + 1, glowColor)
		ok
		
		al_draw_filled_circle(sx, sy, size, starColor)
	next

func drawMenu offsetX
	# Title with glow (big font)
	glowColor = al_map_rgba(76, 175, 80, 80)
	al_draw_text(fontBig, glowColor, offsetX + BASE_W/2 + 3, 123, ALLEGRO_ALIGN_CENTER, "RingVaders")
	al_draw_text(fontBig, C_PRIMARY, offsetX + BASE_W/2, 120, ALLEGRO_ALIGN_CENTER, "RingVaders")
	
	al_draw_text(font, C_ACCENT, offsetX + BASE_W/2, 180, ALLEGRO_ALIGN_CENTER, "Defend Earth from the Alien Invasion!")
	
	# Preview alien with glow
	drawAlienInvader(offsetX + BASE_W/2, 280, 2.5, 76, 175, 80)
	
	# Difficulty selector
	al_draw_text(font, C_WHITE, offsetX + BASE_W/2, 370, ALLEGRO_ALIGN_CENTER, "DIFFICULTY:")
	
	# Draw difficulty options with arrows
	diffColor = C_ACCENT
	diffText = "< " + difficultyNames[gameDifficulty + 1] + " >"
	
	# Pulsing highlight on selected difficulty
	diffPulse = 200 + floor(sin(frameCount * 0.1) * 55)
	diffColor = al_map_rgba(255, 235, 59, diffPulse)
	al_draw_text(font, diffColor, offsetX + BASE_W/2, 395, ALLEGRO_ALIGN_CENTER, diffText)
	
	al_draw_text(font, C_WHITE, offsetX + BASE_W/2, 440, ALLEGRO_ALIGN_CENTER, "Arrow Keys / WASD to move")
	al_draw_text(font, C_WHITE, offsetX + BASE_W/2, 460, ALLEGRO_ALIGN_CENTER, "SPACE to shoot | P pause | S sound")
	al_draw_text(font, C_ACCENT, offsetX + BASE_W/2, 500, ALLEGRO_ALIGN_CENTER, "Chain kills for combo multipliers!")
	
	al_draw_text(font, C_PRIMARY, offsetX + BASE_W/2, 540, ALLEGRO_ALIGN_CENTER, "HIGH SCORE: " + highScore)
	
	# Pulsing start
	pulseAlpha = 180 + floor(sin(frameCount * 0.08) * 75)
	pulseColor = al_map_rgba(255, 255, 255, pulseAlpha)
	al_draw_text(font, pulseColor, offsetX + BASE_W/2, 590, ALLEGRO_ALIGN_CENTER, "Press SPACE to Start")
	
	# Achievements hint
	al_draw_text(font, al_map_rgb(150, 150, 150), offsetX + BASE_W/2, 630, ALLEGRO_ALIGN_CENTER, "TAB - Achievements")

func drawAchievementsScreen offsetX
	# Title
	glowColor = al_map_rgba(255, 215, 0, 80)
	al_draw_text(fontBig, glowColor, offsetX + BASE_W/2 + 3, 53, ALLEGRO_ALIGN_CENTER, "ACHIEVEMENTS")
	al_draw_text(fontBig, al_map_rgb(255, 215, 0), offsetX + BASE_W/2, 50, ALLEGRO_ALIGN_CENTER, "ACHIEVEMENTS")
	
	# Count unlocked
	unlockedCount = 0
	for i = 1 to len(achievements)
		if achievements[i][:unlocked]
			unlockedCount++
		ok
	next
	
	# Progress text
	al_draw_text(font, C_WHITE, offsetX + BASE_W/2, 95, ALLEGRO_ALIGN_CENTER, "" + unlockedCount + " / " + len(achievements) + " Unlocked")
	
	# Achievements list box
	boxX = offsetX + BASE_W/2 - 270
	boxY = 130
	boxW = 540
	boxH = 420
	
	al_draw_filled_rounded_rectangle(boxX, boxY, boxX + boxW, boxY + boxH, 10, 10, al_map_rgba(0, 0, 0, 200))
	al_draw_rounded_rectangle(boxX, boxY, boxX + boxW, boxY + boxH, 10, 10, al_map_rgb(255, 215, 0), 2)
	
	# Draw each achievement
	entryY = boxY + 20
	for i = 1 to len(achievements)
		ach = achievements[i]
		
		if ach[:unlocked]
			# Unlocked - gold color with star
			iconColor = al_map_rgb(255, 215, 0)
			nameColor = al_map_rgb(255, 215, 0)
			descColor = al_map_rgb(200, 200, 200)
			
			# Star icon
			al_draw_filled_circle(boxX + 25, entryY + 12, 8, iconColor)
			al_draw_filled_circle(boxX + 25, entryY + 12, 4, al_map_rgb(255, 255, 200))
		else
			# Locked - gray with lock
			iconColor = al_map_rgb(80, 80, 80)
			nameColor = al_map_rgb(120, 120, 120)
			descColor = al_map_rgb(80, 80, 80)
			
			# Lock icon (simple square)
			al_draw_filled_rectangle(boxX + 19, entryY + 6, boxX + 31, entryY + 18, iconColor)
			al_draw_rectangle(boxX + 21, entryY + 2, boxX + 29, entryY + 8, iconColor, 2)
		ok
		
		# Achievement name
		al_draw_text(font, nameColor, boxX + 45, entryY, ALLEGRO_ALIGN_LEFT, ach[:name])
		
		# Achievement description
		al_draw_text(font, descColor, boxX + 45, entryY + 20, ALLEGRO_ALIGN_LEFT, ach[:desc])
		
		entryY += 40
	next
	
	# Back hint
	pulseAlpha = 180 + floor(sin(frameCount * 0.08) * 75)
	al_draw_text(font, al_map_rgba(255, 255, 255, pulseAlpha), offsetX + BASE_W/2, BASE_H - 60, ALLEGRO_ALIGN_CENTER, "Press TAB or ESC to go back")

func drawPlayfield offsetX, offsetY
	# Draw shields with highlight
	for i = 1 to MAX_SHIELDS
		if shields[i][:active]
			sx = offsetX + shields[i][:x]
			sy = offsetY + shields[i][:y]
			alpha = shields[i][:health] * 85
			shieldColor = al_map_rgba(76, 175, 80, alpha)
			
			if shields[i][:health] = 3
				glowColor = al_map_rgba(129, 199, 132, 40)
				al_draw_filled_rectangle(sx - 1, sy - 1, sx + shields[i][:w] + 1, sy + shields[i][:h] + 1, glowColor)
			ok
			
			al_draw_filled_rectangle(sx, sy, sx + shields[i][:w], sy + shields[i][:h], shieldColor)
		ok
	next
	
	# Draw player with effects
	drawPlayerShip(offsetX, offsetY)
	
	# Draw enemies with glow and individual animations
	for i = 1 to MAX_ENEMIES
		if enemies[i][:alive]
			ex = offsetX + enemies[i][:x]
			ey = offsetY + enemies[i][:y]
			er = enemies[i][:colorR]
			eg = enemies[i][:colorG]
			eb = enemies[i][:colorB]
			eAnim = enemies[i][:animOffset]
			
			# Flash white when hit
			if enemies[i][:hitFlash] > 0
				er = 255
				eg = 255
				eb = 255
			ok
			
			# Use appropriate drawing function based on enemy type
			switch enemies[i][:etype]
				on ENEMY_ARMORED
					drawArmoredEnemy(ex, ey, 0.8, er, eg, eb, eAnim)
				on ENEMY_SPEEDER
					drawSpeederEnemy(ex, ey, 0.8, er, eg, eb, eAnim)
				other
					drawAlienProceduralAnimated(ex, ey, 0.8, er, eg, eb, eAnim)
			off
		ok
	next
	
	# Draw UFO
	if ufoActive
		drawUFOGlow(offsetX, offsetY)
	ok
	
	# Draw player bullets with gradient
	for i = 1 to MAX_BULLETS
		if bullets[i][:active]
			bx = offsetX + bullets[i][:x]
			by = offsetY + bullets[i][:y]
			
			# Glow
			glowColor = al_map_rgba(255, 179, 71, 60)
			al_draw_filled_rectangle(bx - 4, by - 12, bx + 4, by + 7, glowColor)
			
			# Gradient (3 parts)
			al_draw_filled_rectangle(bx - 2, by - 10, bx + 2, by - 5, C_ACCENT)
			al_draw_filled_rectangle(bx - 2, by - 5, bx + 2, by, C_TERTIARY)
			al_draw_filled_rectangle(bx - 2, by, bx + 2, by + 5, C_PRIMARY)
			
			# Core
			al_draw_filled_rectangle(bx - 1, by - 8, bx + 1, by + 2, C_WHITE)
		ok
	next
	
	# Draw enemy bullets with glow
	for i = 1 to MAX_ENEMY_BULLETS
		if enemyBullets[i][:active]
			bx = offsetX + enemyBullets[i][:x]
			by = offsetY + enemyBullets[i][:y]
			
			glowColor = al_map_rgba(217, 119, 87, 60)
			al_draw_filled_rectangle(bx - 5, by - 5, bx + 5, by + 5, glowColor)
			al_draw_filled_rectangle(bx - 3, by - 3, bx + 3, by + 3, C_PRIMARY)
			al_draw_filled_rectangle(bx - 1, by - 1, bx + 1, by + 1, C_TERTIARY)
		ok
	next
	
	# Draw particles with glow
	for i = 1 to MAX_PARTICLES
		if particles[i][:active]
			alpha = floor(particles[i][:life] * 5)
			if alpha > 255 alpha = 255 ok
			
			px = offsetX + particles[i][:x]
			py = offsetY + particles[i][:y]
			psize = particles[i][:size]
			
			glowAlpha = floor(alpha * 0.4)
			glowColor = al_map_rgba(particles[i][:colorR], particles[i][:colorG], particles[i][:colorB], glowAlpha)
			pcolor = al_map_rgba(particles[i][:colorR], particles[i][:colorG], particles[i][:colorB], alpha)
			
			if particles[i][:isSquare]
				al_draw_filled_rectangle(px - psize/2 - 2, py - psize/2 - 2, px + psize/2 + 2, py + psize/2 + 2, glowColor)
				al_draw_filled_rectangle(px - psize/2, py - psize/2, px + psize/2, py + psize/2, pcolor)
			else
				al_draw_filled_circle(px, py, psize + 2, glowColor)
				al_draw_filled_circle(px, py, psize, pcolor)
			ok
		ok
	next
	
	# Draw powerups with glow
	for i = 1 to MAX_POWERUPS
		if powerups[i][:active]
			drawPowerupGlow(offsetX, offsetY, i)
		ok
	next
	
	# Draw bullet trails
	for i = 1 to MAX_BULLET_TRAILS
		if bulletTrails[i][:active]
			alpha = floor(bulletTrails[i][:life] * 25)
			if alpha > 200 alpha = 200 ok
			tx = offsetX + bulletTrails[i][:x]
			ty = offsetY + bulletTrails[i][:y]
			trailColor = al_map_rgba(bulletTrails[i][:colorR], bulletTrails[i][:colorG], bulletTrails[i][:colorB], alpha)
			al_draw_filled_circle(tx, ty, bulletTrails[i][:size], trailColor)
		ok
	next
	
	# Draw boss
	if bossActive
		drawBoss(offsetX, offsetY)
	ok
	
	# Draw score popups
	for i = 1 to MAX_SCORE_POPUPS
		if scorePopups[i][:active]
			alpha = floor(scorePopups[i][:life] * 5.5)
			if alpha > 255 alpha = 255 ok
			popColor = al_map_rgba(255, 235, 59, alpha)
			glowColor = al_map_rgba(255, 235, 59, floor(alpha * 0.4))
			px = offsetX + scorePopups[i][:x]
			py = offsetY + scorePopups[i][:y]
			scoreText = "+" + scorePopups[i][:score]
			al_draw_text(font, glowColor, px + 1, py + 1, ALLEGRO_ALIGN_CENTER, scoreText)
			al_draw_text(font, popColor, px, py, ALLEGRO_ALIGN_CENTER, scoreText)
		ok
	next
	
	# Draw UI
	drawUI(offsetX)

func drawPauseOverlay offsetX
	# Simulate blur with multiple layered overlays
	# Layer 1: Dark base
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, 150))
	
	# Layer 2: Scanline pattern for frosted effect
	for y = 0 to BASE_H step 4
		al_draw_line(offsetX, y, offsetX + BASE_W, y, al_map_rgba(20, 40, 20, 80), 1)
	next
	
	# Layer 3: Vignette effect (darker edges)
	for i = 1 to 5
		alpha = 30 - i * 5
		margin = i * 20
		al_draw_rectangle(offsetX + margin, margin, offsetX + BASE_W - margin, BASE_H - margin, 
						 al_map_rgba(0, 0, 0, alpha), 2)
	next
	
	# Layer 4: Final darkening
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, 100))
	
	# Glowing title (big font)
	glowColor = al_map_rgba(76, 175, 80, 60)
	for i = 1 to 3
		al_draw_text(fontBig, glowColor, offsetX + BASE_W/2 + i, BASE_H/2 - 40 + i, ALLEGRO_ALIGN_CENTER, "PAUSED")
	next
	al_draw_text(fontBig, C_PRIMARY, offsetX + BASE_W/2, BASE_H/2 - 40, ALLEGRO_ALIGN_CENTER, "PAUSED")
	
	# Pulsing continue text
	pulseAlpha = 180 + floor(sin(frameCount * 0.08) * 75)
	al_draw_text(font, al_map_rgba(255, 255, 255, pulseAlpha), offsetX + BASE_W/2, BASE_H/2 + 40, ALLEGRO_ALIGN_CENTER, "Press P or SPACE to continue")

func drawGameOverOverlay offsetX
	# Simulate blur with layered overlays
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, 180))
	
	# Scanline pattern
	for y = 0 to BASE_H step 4
		al_draw_line(offsetX, y, offsetX + BASE_W, y, al_map_rgba(20, 40, 20, 60), 1)
	next
	
	# Vignette
	for i = 1 to 5
		alpha = 25 - i * 4
		margin = i * 25
		al_draw_rectangle(offsetX + margin, margin, offsetX + BASE_W - margin, BASE_H - margin, 
						 al_map_rgba(0, 0, 0, alpha), 2)
	next
	
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, 80))
	
	# Glowing "GAME OVER" title (big font)
	for i = 1 to 4
		al_draw_text(fontBig, al_map_rgba(255, 0, 0, 40), offsetX + BASE_W/2 + i, 90 + i, ALLEGRO_ALIGN_CENTER, "GAME OVER")
	next
	al_draw_text(fontBig, al_map_rgb(255, 0, 0), offsetX + BASE_W/2, 90, ALLEGRO_ALIGN_CENTER, "GAME OVER")
	
	# Score with glow
	al_draw_text(font, al_map_rgba(255, 235, 59, 60), offsetX + BASE_W/2 + 1, 151, ALLEGRO_ALIGN_CENTER, "FINAL SCORE: " + gameScore)
	al_draw_text(font, C_ACCENT, offsetX + BASE_W/2, 150, ALLEGRO_ALIGN_CENTER, "FINAL SCORE: " + gameScore)
	
	# Statistics box
	boxX = offsetX + BASE_W/2 - 180
	boxY = 190
	boxW = 360
	boxH = 280
	
	# Box background
	al_draw_filled_rounded_rectangle(boxX, boxY, boxX + boxW, boxY + boxH, 10, 10, al_map_rgba(0, 0, 0, 200))
	al_draw_rounded_rectangle(boxX, boxY, boxX + boxW, boxY + boxH, 10, 10, C_PRIMARY, 2)
	
	# Statistics title
	al_draw_text(font, C_PRIMARY, offsetX + BASE_W/2, boxY + 15, ALLEGRO_ALIGN_CENTER, "- STATISTICS -")
	
	# Stats layout
	statY = boxY + 50
	statSpacing = 28
	labelX = boxX + 20
	valueX = boxX + boxW - 20
	
	# Wave reached
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Wave Reached")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + gameWave)
	statY += statSpacing
	
	# Enemies killed
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Enemies Killed")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + totalKills)
	statY += statSpacing
	
	# Accuracy
	if shotsFired > 0
		accuracy = floor((shotsHit * 100) / shotsFired)
	else
		accuracy = 0
	ok
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Accuracy")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + accuracy + "%")
	statY += statSpacing
	
	# Best combo
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Best Combo")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + maxCombo + "x")
	statY += statSpacing
	
	# Powerups collected
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Powerups")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + powerupsCollected)
	statY += statSpacing
	
	# Bosses defeated
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Bosses Defeated")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, "" + bossesDefeated)
	statY += statSpacing
	
	# Time played
	totalSeconds = floor(gamePlayTime / FPS)
	minutes = floor(totalSeconds / 60)
	seconds = totalSeconds % 60
	if seconds < 10
		timeStr = "" + minutes + ":0" + seconds
	else
		timeStr = "" + minutes + ":" + seconds
	ok
	al_draw_text(font, C_WHITE, labelX, statY, ALLEGRO_ALIGN_LEFT, "Time Played")
	al_draw_text(font, C_ACCENT, valueX, statY, ALLEGRO_ALIGN_RIGHT, timeStr)
	
	# High score
	al_draw_text(font, al_map_rgba(76, 175, 80, 60), offsetX + BASE_W/2 + 1, boxY + boxH + 25, ALLEGRO_ALIGN_CENTER, "HIGH SCORE: " + highScore)
	al_draw_text(font, C_PRIMARY, offsetX + BASE_W/2, boxY + boxH + 24, ALLEGRO_ALIGN_CENTER, "HIGH SCORE: " + highScore)
	
	# New high score indicator
	if gameScore >= highScore and gameScore > 0
		pulseColor = al_map_rgba(255, 215, 0, 150 + floor(sin(frameCount * 0.15) * 100))
		al_draw_text(font, pulseColor, offsetX + BASE_W/2, boxY + boxH + 50, ALLEGRO_ALIGN_CENTER, "NEW HIGH SCORE!")
	ok
	
	# Pulsing play again
	pulseAlpha = 180 + floor(sin(frameCount * 0.08) * 75)
	al_draw_text(font, al_map_rgba(255, 255, 255, pulseAlpha), offsetX + BASE_W/2, BASE_H - 80, ALLEGRO_ALIGN_CENTER, "Press SPACE to Play Again")
	al_draw_text(font, al_map_rgba(150, 150, 150, pulseAlpha), offsetX + BASE_W/2, BASE_H - 50, ALLEGRO_ALIGN_CENTER, "Press ESC for Menu")

func drawWaveAnnouncement offsetX
	# Calculate animation progress (0 to 1)
	progress = waveAnnounceTimer / 120.0
	
	# Darken background
	al_draw_filled_rectangle(offsetX, 0, offsetX + BASE_W, BASE_H, al_map_rgba(0, 0, 0, 150))
	
	# Wave text animation
	waveText = "WAVE " + gameWave
	
	# Scale effect (zoom in then out)
	if progress < 0.3
		scale = progress / 0.3
	but progress > 0.7
		scale = (1.0 - progress) / 0.3
	else
		scale = 1.0
	ok
	
	# Alpha fade in/out
	if progress < 0.2
		alpha = floor(progress / 0.2 * 255)
	but progress > 0.8
		alpha = floor((1.0 - progress) / 0.2 * 255)
	else
		alpha = 255
	ok
	if alpha > 255 alpha = 255 ok
	if alpha < 0 alpha = 0 ok
	
	# Draw glowing wave text
	glowColor = al_map_rgba(76, 175, 80, floor(alpha * 0.4))
	textColor = al_map_rgba(76, 175, 80, alpha)
	
	# Glow layers
	for i = 1 to 4
		al_draw_text(fontBig, glowColor, offsetX + BASE_W/2 + i, BASE_H/2 - 40 + i, ALLEGRO_ALIGN_CENTER, waveText)
	next
	al_draw_text(fontBig, textColor, offsetX + BASE_W/2, BASE_H/2 - 40, ALLEGRO_ALIGN_CENTER, waveText)
	
	# Difficulty indicator
	diffText = "< " + difficultyNames[gameDifficulty + 1] + " >"
	al_draw_text(font, al_map_rgba(255, 235, 59, alpha), offsetX + BASE_W/2, BASE_H/2 + 20, ALLEGRO_ALIGN_CENTER, diffText)
	
	# "GET READY" text
	if progress > 0.3 and progress < 0.8
		readyAlpha = floor(sin((progress - 0.3) * 10) * 127 + 128)
		al_draw_text(font, al_map_rgba(255, 255, 255, readyAlpha), offsetX + BASE_W/2, BASE_H/2 + 60, ALLEGRO_ALIGN_CENTER, "GET READY!")
	ok

func drawCRTEffect
	# Scanlines (horizontal lines across the screen)
	for y = 0 to SCREEN_HEIGHT step 3
		al_draw_line(0, y, SCREEN_WIDTH, y, al_map_rgba(0, 0, 0, 50), 1)
	next
	
	# Subtle green tint overlay
	al_draw_filled_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, al_map_rgba(0, 20, 0, 15))
	
	# Vignette effect (darker corners)
	# Top-left corner
	for i = 1 to 8
		alpha = 20 - i * 2
		al_draw_filled_triangle(0, 0, i * 25, 0, 0, i * 25, al_map_rgba(0, 0, 0, alpha))
	next
	# Top-right corner
	for i = 1 to 8
		alpha = 20 - i * 2
		al_draw_filled_triangle(SCREEN_WIDTH, 0, SCREEN_WIDTH - i * 25, 0, SCREEN_WIDTH, i * 25, al_map_rgba(0, 0, 0, alpha))
	next
	# Bottom-left corner
	for i = 1 to 8
		alpha = 20 - i * 2
		al_draw_filled_triangle(0, SCREEN_HEIGHT, i * 25, SCREEN_HEIGHT, 0, SCREEN_HEIGHT - i * 25, al_map_rgba(0, 0, 0, alpha))
	next
	# Bottom-right corner
	for i = 1 to 8
		alpha = 20 - i * 2
		al_draw_filled_triangle(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_WIDTH - i * 25, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - i * 25, al_map_rgba(0, 0, 0, alpha))
	next
	
	# Subtle screen flicker (every ~2 seconds)
	if floor(frameCount / 120) % 10 = 0
		al_draw_filled_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, al_map_rgba(255, 255, 255, 3))
	ok
