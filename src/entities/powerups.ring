/*
	RingVaders - Powerups Module
	Powerup system and rendering
*/

func updatePowerups
	for i = 1 to MAX_POWERUPS
		if powerups[i][:active]
			powerups[i][:y] += powerups[i][:vy]
			
			if fabs(powerups[i][:x] - playerX) < 25 and fabs(powerups[i][:y] - playerY) < 25
				powerupsCollected++
				switch powerups[i][:ptype]
					on POWERUP_SHIELD
						shieldPower = 420
						shieldHits = 3
						playSnd(SOUND_POWERUP)
					on POWERUP_RAPID
						rapidPower = 420
						playSnd(SOUND_POWERUP)
					on POWERUP_MULTI
						multiPower = 420
						playSnd(SOUND_POWERUP)
					on POWERUP_SPREAD
						spreadPower = 420
						playSnd(SOUND_POWERUP)
					on POWERUP_LIFE
						if gameLives < 5
							gameLives++
							playSnd(SOUND_1UP)
						ok
				off
				explode(powerups[i][:x], powerups[i][:y], powerups[i][:colorR], powerups[i][:colorG], powerups[i][:colorB], 12)
				powerups[i][:active] = false
				
				# Check powerup achievement
				if powerupsCollected >= 10
					unlockAchievement("powerup_collect")
				ok
			ok
			
			if powerups[i][:y] > BASE_H
				powerups[i][:active] = false
			ok
		ok
	next

func spawnPowerup x, y, forced
	# 22% drop rate
	if !forced and random(100) > 22
		return
	ok
	
	for i = 1 to MAX_POWERUPS
		if !powerups[i][:active]
			powerups[i][:x] = x
			powerups[i][:y] = y
			powerups[i][:ptype] = random(4)
			powerups[i][:vy] = 2
			powerups[i][:size] = 20
			powerups[i][:rotation] = 0
			powerups[i][:active] = true
			
			switch powerups[i][:ptype]
				on POWERUP_SHIELD
					powerups[i][:colorR] = 90
					powerups[i][:colorG] = 159
					powerups[i][:colorB] = 212
				on POWERUP_RAPID
					powerups[i][:colorR] = 232
					powerups[i][:colorG] = 145
					powerups[i][:colorB] = 117
				on POWERUP_MULTI
					powerups[i][:colorR] = 125
					powerups[i][:colorG] = 211
					powerups[i][:colorB] = 160
				on POWERUP_SPREAD
					powerups[i][:colorR] = 212
					powerups[i][:colorG] = 166
					powerups[i][:colorB] = 90
				on POWERUP_LIFE
					powerups[i][:colorR] = 255
					powerups[i][:colorG] = 107
					powerups[i][:colorB] = 214
			off
			return
		ok
	next

func drawPowerupGlow offsetX, offsetY, idx
	p = powerups[idx]
	x = offsetX + p[:x]
	y = offsetY + p[:y]
	
	# Get the appropriate image for this powerup type
	img = NULL
	switch p[:ptype]
		on POWERUP_SHIELD img = imgPowerupShield
		on POWERUP_RAPID img = imgPowerupRapid
		on POWERUP_MULTI img = imgPowerupMulti
		on POWERUP_SPREAD img = imgPowerupSpread
		on POWERUP_LIFE img = imgPowerupLife
	off
	
	if img != NULL
		# Get image dimensions for centering
		imgW = al_get_bitmap_width(img)
		imgH = al_get_bitmap_height(img)
		
		# Pulsing effect
		pulse = 1.0 + sin(frameCount * 0.1 + p[:x]) * 0.15
		
		# Bobbing up/down motion
		bobY = sin(frameCount * 0.08 + p[:x] * 0.1) * 3
		
		# Base size increased to 48 pixels
		baseSize = 48.0
		
		# Draw outer glow ring (pulsing)
		glowAlpha = floor(60 + sin(frameCount * 0.15) * 30)
		glowColor = al_map_rgba(p[:colorR], p[:colorG], p[:colorB], glowAlpha)
		glowScale = 1.5 * pulse
		al_draw_tinted_scaled_rotated_bitmap(img, glowColor,
			imgW/2, imgH/2, x, y + bobY, 
			glowScale * baseSize/imgW, glowScale * baseSize/imgH, 
			0, 0)
		
		# Draw inner glow (sharper)
		innerGlow = al_map_rgba(255, 255, 255, 40)
		al_draw_tinted_scaled_rotated_bitmap(img, innerGlow,
			imgW/2, imgH/2, x, y + bobY,
			1.15 * baseSize/imgW, 1.15 * baseSize/imgH,
			0, 0)
		
		# Draw main powerup image (scaled to ~48x48 with pulse)
		scale = baseSize / imgW * pulse
		al_draw_scaled_rotated_bitmap(img,
			imgW/2, imgH/2, x, y + bobY,
			scale, scale,
			0, 0)
		
		# Draw sparkle particles around powerup
		for sparkle = 1 to 4
			sparkleAngle = frameCount * 0.05 + sparkle * PI / 2
			sparkleRadius = 28 + sin(frameCount * 0.2 + sparkle) * 5
			sx = x + cos(sparkleAngle) * sparkleRadius
			sy = y + bobY + sin(sparkleAngle) * sparkleRadius
			sparkleSize = 2 + sin(frameCount * 0.3 + sparkle * 2) * 1.5
			sparkleAlpha = floor(150 + sin(frameCount * 0.25 + sparkle) * 100)
			al_draw_filled_circle(sx, sy, sparkleSize, al_map_rgba(255, 255, 255, sparkleAlpha))
		next
	else
		# Fallback to hexagon if image not loaded
		pcolor = al_map_rgb(p[:colorR], p[:colorG], p[:colorB])
		glowColor = al_map_rgba(p[:colorR], p[:colorG], p[:colorB], 80)
		drawHexagon(x, y, p[:size] + 4, 0, glowColor)
		drawHexagon(x, y, p[:size], 0, pcolor)
		letter = "?"
		al_draw_text(font, C_WHITE, x, y - 9, ALLEGRO_ALIGN_CENTER, letter)
	ok

func drawHexagon cx, cy, size, rotation, color
	for i = 0 to 5
		angle1 = rotation + i * PI / 3
		angle2 = rotation + (i + 1) * PI / 3
		x1 = cx + cos(angle1) * size
		y1 = cy + sin(angle1) * size
		x2 = cx + cos(angle2) * size
		y2 = cy + sin(angle2) * size
		al_draw_filled_triangle(cx, cy, x1, y1, x2, y2, color)
	next
