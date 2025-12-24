/*
	RingVaders - Cleanup Module
	Resource cleanup and destruction
*/

func cleanup
	al_destroy_timer(timer)
	al_destroy_allegro_event(ev)
	al_destroy_event_queue(event_queue)
	al_destroy_font(font)
	# Only destroy fontBig if it's a different font
	if fontBig != NULL and fontBig != font
		al_destroy_font(fontBig)
	ok
	
	# Stop all audio
	al_stop_samples()
	
	# Destroy music samples
	if musicMenu != NULL al_destroy_sample(musicMenu) ok
	if musicMain != NULL al_destroy_sample(musicMain) ok
	if musicBoss != NULL al_destroy_sample(musicBoss) ok
	if musicSampleId != NULL al_destroy_allegro_sample_id(musicSampleId) ok
	
	if sndShoot != NULL al_destroy_sample(sndShoot) ok
	if sndEnemyHit != NULL al_destroy_sample(sndEnemyHit) ok
	if sndUfoHit != NULL al_destroy_sample(sndUfoHit) ok
	if sndPlayerHit != NULL al_destroy_sample(sndPlayerHit) ok
	if sndPowerup != NULL al_destroy_sample(sndPowerup) ok
	if sndWaveClear != NULL al_destroy_sample(sndWaveClear) ok
	if snd1Up != NULL al_destroy_sample(snd1Up) ok
	if sndUfoSpawn != NULL al_destroy_sample(sndUfoSpawn) ok
	if sampleId != NULL al_destroy_allegro_sample_id(sampleId) ok
	
	# Destroy powerup images
	if imgPowerupShield != NULL al_destroy_bitmap(imgPowerupShield) ok
	if imgPowerupRapid != NULL al_destroy_bitmap(imgPowerupRapid) ok
	if imgPowerupMulti != NULL al_destroy_bitmap(imgPowerupMulti) ok
	if imgPowerupSpread != NULL al_destroy_bitmap(imgPowerupSpread) ok
	if imgPowerupLife != NULL al_destroy_bitmap(imgPowerupLife) ok
	
	# Destroy game buffer
	if gameBuffer != NULL al_destroy_bitmap(gameBuffer) ok
	
	al_destroy_display(display)
