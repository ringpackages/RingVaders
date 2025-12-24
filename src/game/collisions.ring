/*
	RingVaders - Collisions Module
	Collision detection between entities
*/

func updateCollisions
	# Bullets vs UFO
	if ufoActive
		for i = 1 to MAX_BULLETS
			if bullets[i][:active]
				if fabs(bullets[i][:x] - ufoX) < 30 and fabs(bullets[i][:y] - ufoY) < 20
					multiplier = gameCombo + 1
					if multiplier > 10 multiplier = 10 ok
					earnedScore = ufoPoints * multiplier
					gameScore += earnedScore
					shotsHit++
					waveShotsHit++
					gameCombo++
					comboTimer = 60
					lastKillTime = frameCount
					
					# Spawn floating score popup
					spawnScorePopup(ufoX, ufoY, earnedScore)
					
					explode(ufoX, ufoY, 255, 0, 0, 15)
					shakeIntensity = 6
					playSndAtPosition(SOUND_UFO_HIT, ufoX)
					spawnPowerup(ufoX, ufoY, true)
					ufoActive = false
					bullets[i][:active] = false
				ok
			ok
		next
	ok
	
	# Bullets vs Enemies
	for i = 1 to MAX_BULLETS
		if bullets[i][:active]
			for j = 1 to MAX_ENEMIES
				if enemies[j][:alive]
					if fabs(bullets[i][:x] - enemies[j][:x]) < 20 and fabs(bullets[i][:y] - enemies[j][:y]) < 18
						bullets[i][:active] = false
						shotsHit++
						waveShotsHit++
						
						# Reduce enemy health
						enemies[j][:health]--
						enemies[j][:hitFlash] = 8
						
						if enemies[j][:health] <= 0
							# Enemy killed
							enemies[j][:alive] = false
							totalKills++
							
							if frameCount - lastKillTime < 60
								gameCombo++
							else
								gameCombo = 1
							ok
							lastKillTime = frameCount
							comboTimer = 60
							
							# Track max combo for achievements
							if gameCombo > maxCombo
								maxCombo = gameCombo
							ok
							
							multiplier = gameCombo
							if multiplier > 10 multiplier = 10 ok
							earnedScore = enemies[j][:points] * multiplier
							gameScore += earnedScore
							
							# Spawn floating score popup
							spawnScorePopup(enemies[j][:x], enemies[j][:y], earnedScore)
							
							explode(enemies[j][:x], enemies[j][:y], enemies[j][:colorR], enemies[j][:colorG], enemies[j][:colorB], 12)
							spawnPowerup(enemies[j][:x], enemies[j][:y], false)
							shakeIntensity = 4
							
							# Play hit sound with pitch based on combo
							playSndAtPositionWithPitch(SOUND_ENEMY_HIT, enemies[j][:x], (1.0 + (gameCombo - 1) * 0.1))
							
							# Check achievements
							checkAchievements()
						else
							# Enemy damaged but not killed (armored)
							explode(enemies[j][:x], enemies[j][:y], 255, 200, 100, 5)
							shakeIntensity = 2
							playSndAtPosition(SOUND_ENEMY_HIT, enemies[j][:x])
						ok
					ok
				ok
			next
		ok
	next
	
	# Enemy bullets vs Player (skip if invincible)
	if invincibleTimer <= 0
		for i = 1 to MAX_ENEMY_BULLETS
			if enemyBullets[i][:active]
				if fabs(enemyBullets[i][:x] - playerX) < 15 and fabs(enemyBullets[i][:y] - playerY) < 15
					enemyBullets[i][:active] = false
					if shieldHits > 0
						shieldHits--
						explode(playerX, playerY, 90, 159, 212, 10)
						playSnd(SOUND_POWERUP)
						shakeIntensity = 3
						if shieldHits <= 0
							shieldPower = 0
						ok
					else
						playerHit()
					ok
				ok
			ok
		next
	ok
	
	# Bullets vs Shields
	for i = 1 to MAX_BULLETS
		if bullets[i][:active]
			for j = 1 to MAX_SHIELDS
				if shields[j][:active]
					if bullets[i][:x] > shields[j][:x] and bullets[i][:x] < shields[j][:x] + shields[j][:w] and
					   bullets[i][:y] > shields[j][:y] and bullets[i][:y] < shields[j][:y] + shields[j][:h]
						shields[j][:health]--
						bullets[i][:active] = false
						if shields[j][:health] <= 0
							shields[j][:active] = false
							explode(shields[j][:x] + 5, shields[j][:y] + 5, 76, 175, 80, 5)
						ok
					ok
				ok
			next
		ok
	next
	
	# Enemy bullets vs Shields
	for i = 1 to MAX_ENEMY_BULLETS
		if enemyBullets[i][:active]
			for j = 1 to MAX_SHIELDS
				if shields[j][:active]
					if enemyBullets[i][:x] > shields[j][:x] and enemyBullets[i][:x] < shields[j][:x] + shields[j][:w] and
					   enemyBullets[i][:y] > shields[j][:y] and enemyBullets[i][:y] < shields[j][:y] + shields[j][:h]
						shields[j][:health]--
						enemyBullets[i][:active] = false
						if shields[j][:health] <= 0
							shields[j][:active] = false
							explode(shields[j][:x] + 5, shields[j][:y] + 5, 76, 175, 80, 5)
						ok
					ok
				ok
			next
		ok
	next
	
	# Bullets vs Boss
	if bossActive
		for i = 1 to MAX_BULLETS
			if bullets[i][:active]
				if fabs(bullets[i][:x] - bossX) < 60 and fabs(bullets[i][:y] - bossY) < 40
					bullets[i][:active] = false
					bossHealth--
					bossHitFlash = 8
					shotsHit++
					shakeIntensity = 2
					
					# Small explosion on hit
					explode(bullets[i][:x], bullets[i][:y], 255, 200, 0, 5)
					playSndAtPosition(SOUND_ENEMY_HIT, bossX)
					
					if bossHealth <= 0
						# Boss defeated!
						bossActive = false
						bossesDefeated++
						earnedScore = 1000 + gameWave * 200
						gameScore += earnedScore
						spawnScorePopup(bossX, bossY, earnedScore)
						explode(bossX, bossY, 255, 100, 0, 30)
						explode(bossX - 30, bossY, 255, 200, 0, 20)
						explode(bossX + 30, bossY, 255, 200, 0, 20)
						shakeIntensity = 15
						playSnd(SOUND_UFO_HIT)
						
						# Unlock boss achievement
						unlockAchievement("boss_kill")
						
						# Drop multiple powerups
						spawnPowerup(bossX - 30, bossY, true)
						spawnPowerup(bossX + 30, bossY, true)
						
						# Continue to next wave
						nextWave()
					ok
				ok
			ok
		next
	ok
