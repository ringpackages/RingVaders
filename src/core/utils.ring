/*
	RingVaders - Utils Module
	Utility functions for high scores, display, etc.
*/

func loadHighScore
	try
		savePath = getSavePath(HIGH_SCORE_FILE)
		if fexists(savePath)
			content = read(savePath)
			highScore = number(content)
			if highScore < 0 highScore = 0 ok
		ok
	catch
		highScore = 0
	done

func saveHighScore
	try
		write(getSavePath(HIGH_SCORE_FILE), "" + highScore)
	catch
		# Failed to save, ignore
	done

func loadAchievements
	try
		savePath = getSavePath(ACHIEVEMENTS_FILE)
		if fexists(savePath)
			content = read(savePath)
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
		write(getSavePath(ACHIEVEMENTS_FILE), content)
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

func initSaveDir
	# Get user home directory cross-platform
	if isWindows()
		home = sysget("APPDATA")
		if home = NULL
			home = sysget("USERPROFILE")
		ok
		SAVE_DIR = home + "\RingVaders\"
	else
		# Linux/macOS - prefer XDG_DATA_HOME, fallback to ~/.local/share
		home = sysget("XDG_DATA_HOME")
		if home = NULL
			home = sysget("HOME") + "/.local/share"
		ok
		SAVE_DIR = home + "/ringvaders/"
	ok
	
	# Create directory if it doesn't exist
	if not fexists(SAVE_DIR)
		if isWindows()
			systemSilent("mkdir " + char(34) + SAVE_DIR + char(34))
		but isUnix() and not isAndroid()
			systemSilent("mkdir -p " + char(34) + SAVE_DIR + char(34))
		ok
	ok

func getSavePath filename
	if SAVE_DIR = NULL
		initSaveDir()
	ok
	return SAVE_DIR + filename