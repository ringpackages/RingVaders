/*
	RingVaders - Input Module
	Keyboard input handling
*/

func handleKeyDown keycode
	if keycode = ALLEGRO_KEY_LEFT or keycode = ALLEGRO_KEY_A
		keyLeft = true
	ok
	if keycode = ALLEGRO_KEY_RIGHT or keycode = ALLEGRO_KEY_D
		keyRight = true
	ok
	if keycode = ALLEGRO_KEY_UP or keycode = ALLEGRO_KEY_W
		keyUp = true
	ok
	if keycode = ALLEGRO_KEY_SPACE
		keySpace = true
		if gameState = STATE_MENU or gameState = STATE_GAMEOVER
			startGame()
		ok
	ok
	if keycode = ALLEGRO_KEY_P
		if gameState = STATE_PLAYING
			gameState = STATE_PAUSED
		but gameState = STATE_PAUSED
			gameState = STATE_PLAYING
		ok
	ok
	if keycode = ALLEGRO_KEY_S
		toggleSound()
	ok
	if keycode = ALLEGRO_KEY_C
		crtEnabled = !crtEnabled
	ok
	if keycode = ALLEGRO_KEY_F
		toggleFullscreen()
	ok
	if keycode = ALLEGRO_KEY_ESCAPE
		if gameState = STATE_PLAYER_DEATH or gameState = STATE_GAMEOVER
			# Return to menu instead of exiting
			gameState = STATE_MENU
			stopMusic()
			playMusicType(MUSIC_MENU)
		but gameState = STATE_PLAYING
			# Quit to the menu
			gameState = STATE_MENU
		but gameState = STATE_PAUSED
			# Resume the game
			gameState = STATE_PLAYING
		but gameState = STATE_ACHIEVEMENTS
			# Return to menu from achievements
			gameState = STATE_MENU
		but gameState = STATE_MENU
			# Only exit from menu
			exit
		ok
	ok
	# Difficulty selection in menu (left/right arrows)
	if gameState = STATE_MENU
		if keycode = ALLEGRO_KEY_LEFT
			gameDifficulty--
			if gameDifficulty < DIFF_EASY gameDifficulty = DIFF_HARD ok
		ok
		if keycode = ALLEGRO_KEY_RIGHT
			gameDifficulty++
			if gameDifficulty > DIFF_HARD gameDifficulty = DIFF_EASY ok
		ok
	ok
	if keycode = ALLEGRO_KEY_ENTER
		if gameState = STATE_MENU or gameState = STATE_GAMEOVER
			startGame()
		ok
	ok
	# Achievements screen toggle (TAB key)
	if keycode = ALLEGRO_KEY_TAB
		if gameState = STATE_MENU
			gameState = STATE_ACHIEVEMENTS
		but gameState = STATE_ACHIEVEMENTS
			gameState = STATE_MENU
		ok
	ok

func handleKeyUp keycode
	if keycode = ALLEGRO_KEY_LEFT or keycode = ALLEGRO_KEY_A
		keyLeft = false
	ok
	if keycode = ALLEGRO_KEY_RIGHT or keycode = ALLEGRO_KEY_D
		keyRight = false
	ok
	if keycode = ALLEGRO_KEY_UP or keycode = ALLEGRO_KEY_W
		keyUp = false
	ok
	if keycode = ALLEGRO_KEY_SPACE
		keySpace = false
	ok
