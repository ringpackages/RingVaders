/*
	RingVaders - Particles Module
	Particle effects and explosions
*/

func updateParticles
	for i = 1 to MAX_PARTICLES
		if particles[i][:active]
			particles[i][:x] += particles[i][:vx]
			particles[i][:y] += particles[i][:vy]
			particles[i][:vy] += 0.05
			particles[i][:life]--
			particles[i][:size] *= 0.97
			if particles[i][:life] <= 0
				particles[i][:active] = false
			ok
		ok
	next

func explode x, y, r, g, b, count
	# Use the passed color with slight variations
	colors = [ 
		[r, g, b],
		[min(r + 40, 255), min(g + 40, 255), min(b + 40, 255)],
		[max(r - 30, 0), max(g - 30, 0), max(b - 30, 0)],
		[255, 255, 255]
	]
	
	for i = 1 to count
		for j = 1 to MAX_PARTICLES
			if !particles[j][:active]
				angle = random(628) / 100.0
				speed = 1 + random(300) / 100.0
				
				particles[j][:x] = x
				particles[j][:y] = y
				particles[j][:vx] = cos(angle) * speed
				particles[j][:vy] = sin(angle) * speed
				particles[j][:life] = 30 + random(20)
				
				colorIdx = 1 + random(3)
				particles[j][:colorR] = colors[colorIdx][1]
				particles[j][:colorG] = colors[colorIdx][2]
				particles[j][:colorB] = colors[colorIdx][3]
				
				particles[j][:size] = 2 + random(4)
				particles[j][:isSquare] = (random(2) = 1)
				particles[j][:active] = true
				exit
			ok
		next
	next
