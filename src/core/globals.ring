/*
	RingVaders - Globals Module
	All global variable declarations
*/

# Allegro objects
display = NULL
event_queue = NULL
timer = NULL
ev = NULL
font = NULL
fontBig = NULL
gameBuffer = NULL
displayWidth = SCREEN_WIDTH
displayHeight = SCREEN_HEIGHT

# Colors
C_PRIMARY = NULL
C_TERTIARY = NULL
C_ACCENT = NULL
C_EYES = NULL
C_BG = NULL
C_WHITE = NULL

# Sound objects
sndShoot = NULL
sndEnemyHit = NULL
sndUfoHit = NULL
sndPlayerHit = NULL
sndPowerup = NULL
sndWaveClear = NULL
snd1Up = NULL
sndUfoSpawn = NULL
sampleId = NULL
soundEnabled = true

# Music objects
musicMenu = NULL
musicMain = NULL
musicBoss = NULL
currentMusicType = 0
musicSampleId = NULL
musicEnabled = true

# Powerup images
imgPowerupShield = NULL
imgPowerupRapid = NULL
imgPowerupMulti = NULL
imgPowerupSpread = NULL
imgPowerupLife = NULL

# Credits dragon image
imgDragon = NULL

# FPS tracking
fpsLastTime = 0
fpsFrameCount = 0
currentFPS = 0

# Game state
gameState = STATE_CREDITS
gameScore = 0
highScore = 0
gameLives = 3
gameWave = 1
gameCombo = 0
comboTimer = 0
lastKillTime = 0
shotsFired = 0
shotsHit = 0
gameStartTime = 0
gamePlayTime = 0
shakeX = 0
shakeY = 0
shakeIntensity = 0
frameCount = 0

# Low health warning
lowHealthTimer = 0
lowHealthBeat = false

# Player death animation
deathAnimTimer = 0
deathAnimDuration = 120 
deathShipPieces = []
deathExplosionPhase = 0

# Achievements system
achievements = []
achievementPopup = ""
achievementPopupTimer = 0
totalKills = 0
maxCombo = 0
bossesDefeated = 0
powerupsCollected = 0
waveDamageTaken = false
waveShotsFired = 0
waveShotsHit = 0

# Difficulty settings
gameDifficulty = DIFF_NORMAL
difficultyNames = ["EASY", "NORMAL", "HARD"]

# CRT effect
crtEnabled = false

# Fullscreen mode
isFullscreen = false

# Wave announcement
waveAnnounceTimer = 0

# Credits animation
creditsTimer = 0

# Player
playerX = BASE_W / 2
playerY = BASE_H - 60
playerSpeed = 5
playerCooldown = 0
baseCooldown = 15
shieldPower = 0
shieldHits = 0
invincibleTimer = 0
rapidPower = 0
multiPower = 0
spreadPower = 0

# Input
keyLeft = false
keyRight = false
keyUp = false
keySpace = false

# Entities
bullets = []
enemyBullets = []
enemies = []
particles = []
powerups = []
shields = []
stars = []
scorePopups = []
bulletTrails = []

# Boss
bossActive = false
bossX = 0
bossY = 0
bossHealth = 0
bossMaxHealth = 0
bossPhase = 0
bossShootTimer = 0
bossHitFlash = 0
bossDroppedPhase1 = false
bossDroppedPhase2 = false

# UFO
ufoActive = false
ufoX = 0
ufoY = 45
ufoDir = 1
ufoSpeed = 2
ufoPoints = 300

# Enemy movement
enemyDir = 1
enemySpeed = 0.5
baseEnemySpeed = 0.15
enemyDropAmount = 15
enemyShootChance = 0.002
totalEnemiesInWave = 55
waveGracePeriod = 0

# Enemy animation
ENEMY_ANIM_SPEED = 10
