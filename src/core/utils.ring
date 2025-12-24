/*
	RingVaders - Utils Module
	Utility functions for high scores, display, etc.
*/

func loadHighScore
	try
		if fexists(HIGH_SCORE_FILE)
			content = read(HIGH_SCORE_FILE)
			highScore = number(content)
			if highScore < 0 highScore = 0 ok
		ok
	catch
		highScore = 0
	done

func saveHighScore
	try
		write(HIGH_SCORE_FILE, "" + highScore)
	catch
		# Failed to save, ignore
	done

func loadAchievements
	try
		if fexists(ACHIEVEMENTS_FILE)
			content = read(ACHIEVEMENTS_FILE)
			lines = str2list(content)
			for line in lines
				achievementId = trim(line)
				if len(achievementId) > 0
					for i = 1 to len(achievements)
						if achievements[i][:id] = achievementId
							achievements[i][:unlocked] = true
						ok
					next
				ok
			next
		ok
	catch
		# Failed to load, achievements start fresh
	done

func saveAchievements
	try
		content = ""
		for i = 1 to len(achievements)
			if achievements[i][:unlocked]
				content += achievements[i][:id] + nl
			ok
		next
		write(ACHIEVEMENTS_FILE, content)
	catch
		# Failed to save, ignore
	done

func toggleFullscreen
	isFullscreen = !isFullscreen
	if isFullscreen
		al_set_display_flag(display, ALLEGRO_FULLSCREEN_WINDOW, true)
	else
		al_set_display_flag(display, ALLEGRO_FULLSCREEN_WINDOW, false)
	ok
	# Update display dimensions for proper scaling
	displayWidth = al_get_display_width(display)
	displayHeight = al_get_display_height(display)
