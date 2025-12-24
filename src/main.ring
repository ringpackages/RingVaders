/*
	RingVaders - Modern Arcade Clone
	Written in the Ring Programming Language using Ring Allegro
	
	Controls:
	- Arrow Keys / WASD to move
	- SPACE to shoot
	- P to pause
	- S to toggle sound/music
	- ESC to quit
	
	Features:
	- Classic arcade gameplay with modern effects
	- Parallax starfield background
	- Boss battles every 5 waves
	- Powerups and combo system
	- Dynamic music: menu, gameplay, and boss tracks
*/

# Load Allegro game library
load "gamelib.ring"

# Load game modules

# Core
load "core/constants.ring"
load "core/globals.ring"
load "core/init.ring"
load "core/utils.ring"
load "core/cleanup.ring"

# Audio
load "audio/audio.ring"

# Input
load "input/input.ring"

# Entity
load "entities/player.ring"
load "entities/enemies.ring"
load "entities/boss.ring"
load "entities/bullets.ring"
load "entities/particles.ring"
load "entities/powerups.ring"

# Game logic
load "game/collisions.ring"
load "game/achievements.ring"
load "game/gamestate.ring"

# Graphics
load "graphics/ui.ring"
load "graphics/rendering.ring"

# ================== MAIN PROGRAM ==================

func main()
	# Initialize random number generator
	srandom(clock())
	
	# Set decimal precision for float calculations
	decimals(4)
	
	# Initialize Allegro
	al_init()
	al_init_font_addon()
	al_init_ttf_addon()
	al_init_primitives_addon()
	al_init_image_addon()
	al_install_keyboard()
	al_install_audio()
	al_init_acodec_addon()
	al_reserve_samples(8)
	
	# Create display
	display = al_create_display(SCREEN_WIDTH, SCREEN_HEIGHT)
	al_set_window_title(display, "RingVaders - Space Invaders Clone")
	
	# Create off-screen buffer for rendering
	gameBuffer = al_create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT)
	
	# Enable blending
	al_set_blender(ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA)
	
	# Initialize colors
	initColors()
	
	# Load fonts
	font = al_load_ttf_font("assets/fonts/PressStart2P.ttf", 12, 0)
	if font = NULL
		? "Warning: Could not load PressStart2P.ttf, trying system fonts"
		font = al_load_ttf_font("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18, 0)
	ok
	if font = NULL
		font = al_load_ttf_font("/usr/share/fonts/truetype/freefont/FreeSans.ttf", 18, 0)
	ok
	if font = NULL
		? "Warning: Could not load TTF font, using builtin"
		font = al_create_builtin_font()
	ok
	
	# Large font for titles
	fontBig = al_load_ttf_font("assets/fonts/PressStart2P.ttf", 24, 0)
	if fontBig = NULL
		fontBig = al_load_ttf_font("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36, 0)
	ok
	if fontBig = NULL
		fontBig = font
	ok
	
	# Initialize sounds
	initSounds()
	
	# Initialize entities
	initEntities()
	
	# Load saved data from files
	loadHighScore()
	loadAchievements()
	
	# Create event queue and timer
	event_queue = al_create_event_queue()
	timer = al_create_timer(1.0 / FPS)
	ev = al_new_allegro_event()
	
	# Register event sources
	al_register_event_source(event_queue, al_get_display_event_source(display))
	al_register_event_source(event_queue, al_get_timer_event_source(timer))
	al_register_event_source(event_queue, al_get_keyboard_event_source())
	
	# Start timer
	al_start_timer(timer)
	
	# Initialize FPS tracking
	fpsLastTime = al_get_time()
	
	redraw = true
	
	# Main game loop
	while true
		al_wait_for_event(event_queue, ev)
		
		evType = al_get_allegro_event_type(ev)
		
		if evType = ALLEGRO_EVENT_DISPLAY_CLOSE
			exit
		ok
		
		if evType = ALLEGRO_EVENT_TIMER
			frameCount++
			updateGame()
			redraw = true
		ok
		
		if evType = ALLEGRO_EVENT_KEY_DOWN
			handleKeyDown(al_get_allegro_event_keyboard_keycode(ev))
		ok
		
		if evType = ALLEGRO_EVENT_KEY_UP
			handleKeyUp(al_get_allegro_event_keyboard_keycode(ev))
		ok
		
		if redraw and al_is_event_queue_empty(event_queue)
			redraw = false
			drawGame()
			al_flip_display()
		ok
		
		callgc()
	end
	
	cleanup()
