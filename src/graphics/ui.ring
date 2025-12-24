/*
	RingVaders - UI Module
	User interface drawing and updates
*/

func updateUI
	if comboTimer > 0
		comboTimer--
		if comboTimer <= 0
			gameCombo = 0
		ok
	ok
	
	if shakeIntensity > 0
		shakeX = (random(200) - 100) / 100.0 * shakeIntensity
		shakeY = (random(200) - 100) / 100.0 * shakeIntensity
		shakeIntensity *= 0.9
		if shakeIntensity < 0.1 shakeIntensity = 0 ok
	else
		shakeX = 0
		shakeY = 0
	ok

func updateScorePopups
	for i = 1 to MAX_SCORE_POPUPS
		if scorePopups[i][:active]
			scorePopups[i][:y] -= 1.5
			scorePopups[i][:life]--
			if scorePopups[i][:life] <= 0
				scorePopups[i][:active] = false
			ok
		ok
	next

func updateLowHealthWarning
	if gameLives = 1 and gameState = STATE_PLAYING
		lowHealthTimer++
		# Heartbeat every 40 frames
		if lowHealthTimer % 40 = 0
			lowHealthBeat = true
			# Play a low thump sound (reuse existing sound with low pitch)
			if soundEnabled and sndPlayerHit != NULL
				al_play_sample(sndPlayerHit, 0.3, 0, 0.5, ALLEGRO_PLAYMODE_ONCE, sampleId)
			ok
		ok
		if lowHealthTimer % 40 = 5
			lowHealthBeat = false
		ok
	else
		lowHealthTimer = 0
		lowHealthBeat = false
	ok

func updateAchievementPopup
	if achievementPopupTimer > 0
		achievementPopupTimer--
	ok

func spawnScorePopup x, y, score
	for i = 1 to MAX_SCORE_POPUPS
		if !scorePopups[i][:active]
			scorePopups[i][:x] = x
			scorePopups[i][:y] = y
			scorePopups[i][:score] = score
			scorePopups[i][:life] = 45
			scorePopups[i][:active] = true
			return
		ok
	next

func drawUI offsetX
	# Score with shadow
	shadowColor = al_map_rgba(76, 175, 80, 80)
	al_draw_text(font, shadowColor, offsetX + 12, 12, ALLEGRO_ALIGN_LEFT, "SCORE: " + gameScore)
	al_draw_text(font, C_PRIMARY, offsetX + 10, 10, ALLEGRO_ALIGN_LEFT, "SCORE: " + gameScore)
	
	# Wave
	al_draw_text(font, C_PRIMARY, offsetX + BASE_W/2, 10, ALLEGRO_ALIGN_CENTER, "WAVE " + gameWave)
	
	# Lives (mini cannon icons) - show up to 5 lives
	lifeColor = al_map_rgb(76, 175, 80)
	for i = 1 to 5
		lx = offsetX + BASE_W - 130 + (i-1) * 25
		ly = 15
		if i <= gameLives
			# Mini cannon shape
			al_draw_filled_rectangle(lx - 8, ly + 2, lx + 8, ly + 6, lifeColor)
			al_draw_filled_rectangle(lx - 5, ly - 2, lx + 5, ly + 2, lifeColor)
			al_draw_filled_rectangle(lx - 2, ly - 8, lx + 2, ly - 2, lifeColor)
		else
			grayColor = al_map_rgb(68, 68, 68)
			al_draw_filled_rectangle(lx - 8, ly + 2, lx + 8, ly + 6, grayColor)
		ok
	next
	
	# Combo
	if comboTimer > 0 and gameCombo > 1
		comboText = "" + gameCombo + "x COMBO!"
		al_draw_text(font, C_ACCENT, offsetX + BASE_W/2, BASE_H/2 - 20, ALLEGRO_ALIGN_CENTER, comboText)
	ok
	
	# Powerup indicators
	py = BASE_H - 30
	if shieldPower > 0 and shieldHits > 0
		al_draw_text(font, al_map_rgb(90, 159, 212), offsetX + 100, py, ALLEGRO_ALIGN_LEFT, "SHIELD x" + shieldHits)
	ok
	if rapidPower > 0
		al_draw_text(font, C_TERTIARY, offsetX + 180, py, ALLEGRO_ALIGN_LEFT, "RAPID")
	ok
	if multiPower > 0
		al_draw_text(font, al_map_rgb(125, 211, 160), offsetX + 250, py, ALLEGRO_ALIGN_LEFT, "MULTI")
	ok
	if spreadPower > 0
		al_draw_text(font, al_map_rgb(212, 166, 90), offsetX + 320, py, ALLEGRO_ALIGN_LEFT, "SPREAD")
	ok
	
	# Audio (sound effects + music)
	if soundEnabled
		al_draw_text(font, al_map_rgb(125, 211, 160), offsetX + 420, py, ALLEGRO_ALIGN_LEFT, "AUDIO: ON")
	else
		al_draw_text(font, al_map_rgb(150, 150, 150), offsetX + 420, py, ALLEGRO_ALIGN_LEFT, "AUDIO: OFF")
	ok
	
	# Draw achievement popup
	if achievementPopupTimer > 0
		drawAchievementPopup(offsetX)
	ok
	
	# Draw low health warning effect
	if lowHealthBeat
		drawLowHealthEffect(offsetX)
	ok

func drawAchievementPopup offsetX
	# Slide in from top animation
	slideProgress = 1.0
	if achievementPopupTimer > 160
		slideProgress = (180 - achievementPopupTimer) / 20.0
	but achievementPopupTimer < 20
		slideProgress = achievementPopupTimer / 20.0
	ok
	
	popupY = -60 + slideProgress * 110
	
	# Wider background box
	boxWidth = 160
	al_draw_filled_rounded_rectangle(offsetX + BASE_W/2 - boxWidth, popupY, 
									 offsetX + BASE_W/2 + boxWidth, popupY + 50,
									 10, 10, al_map_rgba(0, 0, 0, 220))
	al_draw_rounded_rectangle(offsetX + BASE_W/2 - boxWidth, popupY,
							  offsetX + BASE_W/2 + boxWidth, popupY + 50,
							  10, 10, al_map_rgb(255, 215, 0), 2)
	
	# Trophy icon (simple star)
	starX = offsetX + BASE_W/2 - boxWidth + 25
	starY = popupY + 25
	al_draw_filled_circle(starX, starY, 10, al_map_rgb(255, 215, 0))
	al_draw_filled_circle(starX, starY, 5, al_map_rgb(255, 255, 200))
	
	# Text centered
	al_draw_text(font, al_map_rgb(255, 215, 0), offsetX + BASE_W/2, popupY + 8, 
				 ALLEGRO_ALIGN_CENTER, "ACHIEVEMENT UNLOCKED!")
	al_draw_text(font, C_WHITE, offsetX + BASE_W/2, popupY + 28, 
				 ALLEGRO_ALIGN_CENTER, achievementPopup)

func drawLowHealthEffect offsetX
	# Red vignette pulse when at 1 life
	pulseAlpha = floor(40 + sin(frameCount * 0.3) * 30)
	
	# Draw red border/vignette
	for i = 1 to 10
		alpha = pulseAlpha - i * 4
		if alpha > 0
			al_draw_rectangle(offsetX + i*3, i*3, offsetX + BASE_W - i*3, BASE_H - i*3,
							 al_map_rgba(255, 0, 0, alpha), 2)
		ok
	next
