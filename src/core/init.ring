/*
	RingVaders - Init Module
	Initialization functions
*/

func initColors
	# Arcade green color scheme
	C_PRIMARY = al_map_rgb(76, 175, 80)
	C_TERTIARY = al_map_rgb(129, 199, 132)
	C_ACCENT = al_map_rgb(255, 235, 59)
	C_EYES = al_map_rgb(20, 20, 20)
	C_BG = al_map_rgb(0, 0, 0)
	C_WHITE = al_map_rgb(255, 255, 255)

func initEntities
	# Initialize bullets
	bullets = []
	for i = 1 to MAX_BULLETS
		add(bullets, [:x=0, :y=0, :vx=0, :vy=0, :active=false])
	next
	
	enemyBullets = []
	for i = 1 to MAX_ENEMY_BULLETS
		add(enemyBullets, [:x=0, :y=0, :vx=0, :vy=0, :active=false])
	next
	
	enemies = []
	for i = 1 to MAX_ENEMIES
		add(enemies, [:x=0, :y=0, :etype=0, :points=10, :alive=false, :health=1, :maxHealth=1, :colorR=217, :colorG=119, :colorB=87, :animOffset=0, :hitFlash=0])
	next
	
	# Initialize achievements
	achievements = [
		[:id="first_blood", :name="First Blood", :desc="Kill your first enemy", :unlocked=false],
		[:id="combo_5", :name="Combo Master", :desc="Get a 5x combo", :unlocked=false],
		[:id="combo_10", :name="Combo King", :desc="Get a 10x combo", :unlocked=false],
		[:id="wave_5", :name="Survivor", :desc="Reach wave 5", :unlocked=false],
		[:id="wave_10", :name="Veteran", :desc="Reach wave 10", :unlocked=false],
		[:id="boss_kill", :name="Boss Slayer", :desc="Defeat a boss", :unlocked=false],
		[:id="perfect_wave", :name="Perfectionist", :desc="Clear a wave without damage", :unlocked=false],
		[:id="no_miss", :name="Sharpshooter", :desc="100% accuracy in a wave", :unlocked=false],
		[:id="kill_100", :name="Centurion", :desc="Kill 100 enemies total", :unlocked=false],
		[:id="powerup_collect", :name="Power Hungry", :desc="Collect 10 powerups", :unlocked=false]
	]
	
	particles = []
	for i = 1 to MAX_PARTICLES
		add(particles, [:x=0, :y=0, :vx=0, :vy=0, :life=0, :colorR=217, :colorG=119, :colorB=87, :size=4, :isSquare=false, :active=false])
	next
	
	powerups = []
	for i = 1 to MAX_POWERUPS
		add(powerups, [:x=0, :y=0, :ptype=0, :colorR=90, :colorG=159, :colorB=212, :vy=2, :size=20, :rotation=0, :active=false])
	next
	
	shields = []
	for i = 1 to MAX_SHIELDS
		add(shields, [:x=0, :y=0, :w=10, :h=10, :health=3, :active=false])
	next
	
	# Initialize stars (parallax background)
	stars = []
	for i = 1 to MAX_STARS
		add(stars, [:x=random(BASE_W), :y=random(BASE_H), :speed=0.5 + random(200)/100.0, :size=1 + random(2), :brightness=100 + random(155)])
	next
	
	# Initialize score popups
	scorePopups = []
	for i = 1 to MAX_SCORE_POPUPS
		add(scorePopups, [:x=0, :y=0, :score=0, :life=0, :active=false])
	next
	
	# Initialize bullet trails
	bulletTrails = []
	for i = 1 to MAX_BULLET_TRAILS
		add(bulletTrails, [:x=0, :y=0, :life=0, :colorR=255, :colorG=255, :colorB=255, :size=2, :active=false])
	next
