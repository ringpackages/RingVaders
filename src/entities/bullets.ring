/*
	RingVaders - Bullets Module
	Bullet spawning, movement, and trails
*/

func updateBullets
	for i = 1 to MAX_BULLETS
		if bullets[i][:active]
			# Spawn trail at current position
			spawnBulletTrail(bullets[i][:x], bullets[i][:y], 76, 175, 80)
			
			bullets[i][:y] += bullets[i][:vy]
			bullets[i][:x] += bullets[i][:vx]
			if bullets[i][:y] < 0 or bullets[i][:x] < 0 or bullets[i][:x] > BASE_W
				bullets[i][:active] = false
			ok
		ok
	next
	
	for i = 1 to MAX_ENEMY_BULLETS
		if enemyBullets[i][:active]
			# Spawn trail for enemy bullets (red/orange)
			spawnBulletTrail(enemyBullets[i][:x], enemyBullets[i][:y], 255, 100, 100)
			
			enemyBullets[i][:y] += enemyBullets[i][:vy]
			if enemyBullets[i][:y] > BASE_H
				enemyBullets[i][:active] = false
			ok
		ok
	next

func updateBulletTrails
	for i = 1 to MAX_BULLET_TRAILS
		if bulletTrails[i][:active]
			bulletTrails[i][:life]--
			if bulletTrails[i][:life] <= 0
				bulletTrails[i][:active] = false
			ok
		ok
	next

func spawnBullet x, y, vx, vy
	for i = 1 to MAX_BULLETS
		if !bullets[i][:active]
			bullets[i][:x] = x
			bullets[i][:y] = y
			bullets[i][:vx] = vx
			bullets[i][:vy] = vy
			bullets[i][:active] = true
			return
		ok
	next

func spawnEnemyBullet x, y
	for i = 1 to MAX_ENEMY_BULLETS
		if !enemyBullets[i][:active]
			enemyBullets[i][:x] = x
			enemyBullets[i][:y] = y
			enemyBullets[i][:vx] = 0
			# Cap bullet speed slightly below player speed
			bulletSpeed = 3.5 + gameWave * 0.15
			if bulletSpeed > 4.5 bulletSpeed = 4.5 ok
			enemyBullets[i][:vy] = bulletSpeed
			enemyBullets[i][:active] = true
			return
		ok
	next

func spawnBulletTrail x, y, r, g, b
	for i = 1 to MAX_BULLET_TRAILS
		if !bulletTrails[i][:active]
			bulletTrails[i][:x] = x
			bulletTrails[i][:y] = y
			bulletTrails[i][:life] = 8
			bulletTrails[i][:colorR] = r
			bulletTrails[i][:colorG] = g
			bulletTrails[i][:colorB] = b
			bulletTrails[i][:size] = 2
			bulletTrails[i][:active] = true
			return
		ok
	next
