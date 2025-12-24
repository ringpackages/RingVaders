/*
	RingVaders - Achievements Module
	Achievement tracking and unlocking
*/

func unlockAchievement id
	for i = 1 to len(achievements)
		if achievements[i][:id] = id and !achievements[i][:unlocked]
			achievements[i][:unlocked] = true
			achievementPopup = achievements[i][:name]
			achievementPopupTimer = 180
			# Play achievement sound
			if soundEnabled and snd1Up != NULL
				al_play_sample(snd1Up, 0.8, 0, 1.0, ALLEGRO_PLAYMODE_ONCE, sampleId)
			ok
			saveAchievements()
			return
		ok
	next

func checkAchievements
	# First blood
	if totalKills >= 1
		unlockAchievement("first_blood")
	ok
	
	# Combo achievements
	if maxCombo >= 5
		unlockAchievement("combo_5")
	ok
	if maxCombo >= 10
		unlockAchievement("combo_10")
	ok
	
	# Wave achievements
	if gameWave >= 5
		unlockAchievement("wave_5")
	ok
	if gameWave >= 10
		unlockAchievement("wave_10")
	ok
	
	# Kill count
	if totalKills >= 100
		unlockAchievement("kill_100")
	ok
