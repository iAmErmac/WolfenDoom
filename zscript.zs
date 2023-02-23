version "4.6.1"

// Menu Components
#include "scripts/menus/iconlistmenu.zs"			// Skill Menu (with icons) Base
#include "scripts/menus/playermenunamebox.zs"			// Replacement player menu name box that colors name by default
#include "scripts/menus/messagebox.zs"				// Wolf3D-style message box
#include "scripts/conversations/conversationmenucomponents.zs"	// Replacement Conversation MenuComponents
#include "scripts/conversations/conversationmenubase.zs"	// Replacement Conversation Menu Base
#include "scripts/conversations/boaconversationmenu.zs"	// Replacement Conversation Menu
#include "scripts/menus/interface.zs"				// On-screen interfaces using menu code
#include "scripts/menus/finale.zs"				// Text-based intermission screens
#include "scripts/menus/help.zs"				// Localized help screen
#include "scripts/menus/optionmenu.zs"			// Custom option menu (For displaying translation completion percentages)
#include "scripts/menus/messagelog.zs"			// Message log
#include "scripts/menus/startup.zs"			// IWAD notice and disclaimer
#include "scripts/menus/achievements.zs"			// Achievement summary

// Classes/Libraries
#include "scripts/libraries/libeye/viewport.zs"		// Libeye by KeksDose, praise Mima
#include "scripts/libraries/libeye/projector.zs"		// https://forum.zdoom.org/viewtopic.php?f=105&t=64566
#include "scripts/libraries/libeye/projector_gl.zs"
#include "scripts/libraries/libeye/projector_planar.zs"
#include "scripts/libraries/DrawToHUD.zs"			// Drawing and coordinate translation to match HUD element scaling and positioning
#include "scripts/libraries/reader.zs"				// Ugly but functional parser for nested bracket data
#include "scripts/libraries/matrix.zs"				// Matrix functions
#include "scripts/libraries/breakstring.zs"			// Break string at width with proper carryover of text colors across lines

// Event Handler
#include "scripts/eventhandlers/InventoryClearHandler.zs"
#include "scripts/eventhandlers/MineSweeperHandler.zs"
#include "scripts/eventhandlers/CompassHandler.zs"
#include "scripts/eventhandlers/MapStatsHandler.zs"
#include "scripts/eventhandlers/UnderlayRenderer.zs"
#include "scripts/eventhandlers/InteractionHandler.zs"
#include "scripts/eventhandlers/KeyHandler.zs"
#include "scripts/eventhandlers/ParticleHandler.zs"
#include "scripts/eventhandlers/GroundSplashDataHandler.zs"
#include "scripts/eventhandlers/RevolvingDoor.zs"
#include "scripts/eventhandlers/IWADChecker.zs"
#include "scripts/eventhandlers/NetCommands.zs"
#include "scripts/eventhandlers/WideObjectivesDataHandler.zs"
#include "scripts/eventhandlers/ScreenLabelHandler.zs"
#include "scripts/eventhandlers/MessageHandler.zs"
#include "scripts/eventhandlers/ObjectiveHandler.zs"
#include "scripts/eventhandlers/Tracker.zs"
#include "scripts/eventhandlers/PickupSpecialFix.zs"
#include "scripts/eventhandlers/checkpoints.zs"			// Co-op checkpoints

// Status Bar
#include "scripts/BoAStatusBar.zs"
#include "scripts/BoAWidgets.zs"

// Actors
#include "scripts/actors/player.zs"				// Player
#include "scripts/actors/playerfollowers.zs"			// Player follower NPCs
#include "scripts/actors/enemies/base.zs"			// Base classes for enemies
#include "scripts/actors/enemies/attacks.zs"			// Enemy projectiles
#include "scripts/actors/enemies/tanks.zs"			// Tanks
#include "scripts/actors/enemies/drone.zs"			// Proto-Drone
#include "scripts/actors/enemies/animals.zs"			// Rat/Bat/Shark enemies
#include "scripts/actors/tracers.zs"				// Tracers base classes
#include "scripts/actors/enemies/stealth.zs"			// Stealth enabling actors
#include "scripts/actors/alertlights.zs"			// Base class for light objects that should affect "sneaking" light level
#include "scripts/actors/spawnspots.zs"			// Enemy spawners
#include "scripts/actors/alarm.zs"					// Alarm and Alarm Panel actors
#include "scripts/actors/enemies/medic.zs"			// Medic class
#include "scripts/actors/skyboxview.zs"			// Moving Skybox Viewpoint
#include "scripts/actors/gatekeeper.zs"			// Gatekeeper object
#include "scripts/actors/lightningbase.zs"			// Lightning effect
#include "scripts/actors/electricalarc.zs"			// Electrical Arc
#include "scripts/actors/tank.zs"					// Tank Components
#include "scripts/actors/mapmarkers.zs"			// Map and compass markers
#include "scripts/actors/keen.zs"				// Easter egg base actors
#include "scripts/actors/re.zs"				// More Easter egg actors
#include "scripts/actors/effects/effects.zs"			// Special effects
#include "scripts/actors/boulders.zs"				// 3D model boulders
#include "scripts/actors/soulfountain.zs"			// Soul fountain (C3M6_B)
#include "scripts/actors/groundsplash.zs"			// Ground soil "splashes"
#include "scripts/actors/enemies/nemesis.zs"			// Nemesis (C3M0_A)
#include "scripts/actors/enemies/controllable.zs"		// Controllable actors
#include "scripts/actors/enemies/zombies.zs"			// Zombies

/// Interactive Props
#include "scripts/actors/interactive.zs"			// Interactive actors (breakable vent, statue, etc.)
#include "scripts/actors/tiltable.zs"				// Items that slide with level tilt
#include "scripts/actors/ladder.zs"				// Climbable Ladders
#include "scripts/actors/bombard.zs"				// Bombardment shells for C1M3

/// Decorative Props
#include "scripts/actors/miscellaneous.zs"
#include "scripts/actors/debris.zs"				// Debris mounds
#include "scripts/actors/mountains.zs"				// Mountain landscape for zeppelin flight
#include "scripts/actors/rocks.zs"				// Rock spawner base actor

/// Inventory
#include "scripts/actors/items/stackable.zs"			// Stackable inventory base class (Ammo-style top-level class inheritance for inventory items)
#include "scripts/actors/items/money.zs"			// Money (can be made dormant to prevent player from picking it up)
#include "scripts/actors/items/weapons.zs"			// ZScriptified weapon components
#include "scripts/actors/items/soul.zs"			// Soul inventory items
#include "scripts/actors/items/chest.zs"			// Supply chest
#include "scripts/actors/items/powerups.zs"			// Lantern and Minesweeper
#include "scripts/actors/items/vserum.zs"			// Vitality Serum (max health +5)
#include "scripts/actors/items/compassitem.zs"			// Base class for quest items (files, clues, Spear of Destiny, etc.) that show up on the compass
#include "scripts/actors/items/grenades.zs"			// Base class for all grenade type actors
#include "scripts/actors/items/meal.zs"			// Meal fix
#include "scripts/actors/items/parallelitem.zs"		// "Parallel" inventory items
#include "scripts/actors/items/pickups.zs"			// Standard item pickups

/// Player & Monsters Effects Inventory Items
#include "scripts/items/tilt.zs"				// Nash's tilt implementation
#include "scripts/items/visibility.zs"				// Stealth visibility handling for player
#include "scripts/items/underwater.zs"				// Underwater effects handling
#include "scripts/items/heartbeat.zs"				// Heartbeat and low health screen overlay handling
#include "scripts/items/sprint.zs"				// Sprint handling
#include "scripts/items/footsteps.zs"				// Footstep handling

/// Shaders
#include "scripts/shaders/shadercontrol_base.zs"		// Talon1024 - Generic custom shader controls
#include "scripts/shaders/shadercontrol.zs"			// Talon1024 - Shader controllers
#include "scripts/shaders/underwater.zs"			// Underwater
#include "scripts/shaders/postprocessing.zs"			// Postprocessing Shaders + PixelEater MotionBlur eventhandlers
#include "scripts/shaders/colorgrade.zs"			// Exl's Color Grading

/// Miscellaneous
#include "scripts/libraries/zstools.zs"			// ZScript Tools
#include "scripts/libraries/acstools.zs"			// ACS Tools

/////////////////////////////////////////////
//ACTORS CONVERTED FROM DECORATE: beginning//
/////////////////////////////////////////////

//Player
#include "scripts/decorate/misc/player.zs"

//Weapons
#include "scripts/decorate/weapons/ammo.zs"
#include "scripts/decorate/weapons/shovel.zs"
#include "scripts/decorate/weapons/knife.zs"
#include "scripts/decorate/weapons/luger.zs"
#include "scripts/decorate/weapons/p38.zs"
#include "scripts/decorate/weapons/shotgun.zs"
#include "scripts/decorate/weapons/g43.zs"
#include "scripts/decorate/weapons/kar98k.zs"
#include "scripts/decorate/weapons/browning.zs"
#include "scripts/decorate/weapons/mp40.zs"
#include "scripts/decorate/weapons/flamer.zs"
#include "scripts/decorate/weapons/nebelwerfer.zs"
#include "scripts/decorate/weapons/umg43.zs"
#include "scripts/decorate/weapons/stenmk2.zs"
#include "scripts/decorate/weapons/truckgun.zs"
#include "scripts/decorate/weapons/panzerschreck.zs"
#include "scripts/decorate/weapons/granate.zs"
#include "scripts/decorate/weapons/bullets.zs"
#include "scripts/decorate/weapons/firebrand.zs"
#include "scripts/decorate/weapons/astrostein.zs"
#include "scripts/decorate/weapons/tesla.zs"
#include "scripts/decorate/weapons/fakeid.zs"
#include "scripts/decorate/weapons/kicks.zs" 		//AFADoomer

//Model Base
#include "scripts/decorate/models/base.zs"

//Props
#include "scripts/decorate/props/bath.zs"
#include "scripts/decorate/props/bureau.zs"
#include "scripts/decorate/props/camp.zs"
#include "scripts/decorate/props/castle.zs"
#include "scripts/decorate/props/debris.zs"
#include "scripts/decorate/props/egypt.zs"
#include "scripts/decorate/props/flags.zs"
#include "scripts/decorate/props/furniture.zs"
#include "scripts/decorate/props/gore.zs"
#include "scripts/decorate/props/industrial.zs"
#include "scripts/decorate/props/kitchen.zs"
#include "scripts/decorate/props/labs.zs"
#include "scripts/decorate/props/lights.zs"
#include "scripts/decorate/props/shops.zs"
#include "scripts/decorate/props/street.zs"
#include "scripts/decorate/props/tech.zs"
#include "scripts/decorate/props/trees.zs"
#include "scripts/decorate/props/underwater.zs"
#include "scripts/decorate/props/vehicles.zs"
#include "scripts/decorate/props/walldecs.zs"
#include "scripts/decorate/props/astrostein.zs"		//Secret Operation Episode 2

//Items
#include "scripts/decorate/items/armor.zs"
#include "scripts/decorate/items/health.zs"
#include "scripts/decorate/items/keys.zs"
#include "scripts/decorate/items/mission.zs"
#include "scripts/decorate/items/powerups.zs"
#include "scripts/decorate/items/treasure.zs"
#include "scripts/decorate/items/astrostein.zs"		//Secret Operation Episode 2

//Special Effects
#include "scripts/decorate/sfx/clouds.zs"
#include "scripts/decorate/sfx/fog.zs"
#include "scripts/decorate/sfx/glass.zs"
#include "scripts/decorate/sfx/explosion.zs"
#include "scripts/decorate/sfx/flare.zs"
#include "scripts/decorate/sfx/fireworks.zs"
#include "scripts/decorate/sfx/waterlits.zs"
#include "scripts/decorate/sfx/rings.zs"
#include "scripts/decorate/sfx/swirl.zs"
#include "scripts/decorate/sfx/lightning.zs"
#include "scripts/decorate/sfx/skyboxtracer.zs"
#include "scripts/decorate/sfx/terrainsplashes.zs"
#include "scripts/decorate/sfx/vollight.zs"
#include "scripts/decorate/sfx/creepyrift.zs"

//Critters
#include "scripts/decorate/critters/bird.zs"
#include "scripts/decorate/critters/farm.zs"
#include "scripts/decorate/critters/pollen.zs"
#include "scripts/decorate/critters/swarm.zs"
#include "scripts/decorate/critters/rats.zs"
#include "scripts/decorate/props/zyklon.zs"

//Monsters
#include "scripts/decorate/monsters/shared.zs"		//Place this always as first
#include "scripts/decorate/monsters/nazis.zs"		//and this as second - ozy81
#include "scripts/decorate/monsters/bosses.zs"
#include "scripts/decorate/monsters/mechas.zs"
#include "scripts/decorate/monsters/mutants.zs"
#include "scripts/decorate/monsters/occult.zs"
#include "scripts/decorate/monsters/panzers.zs"
#include "scripts/decorate/monsters/prisoner.zs"
#include "scripts/decorate/monsters/robots.zs"
#include "scripts/decorate/monsters/npcs.zs"
#include "scripts/decorate/monsters/russians.zs"
#include "scripts/decorate/monsters/zombies.zs"
#include "scripts/decorate/monsters/astrostein.zs"	//Secret Operation Episode 2
#include "scripts/decorate/monsters/stealth.zs"		//MaxED & AFADoomer

//Elements
#include "scripts/decorate/misc/exclamation.zs"

//EasterEggs
#include "scripts/decorate/misc/ckeen.zs"
#include "scripts/decorate/misc/eastereggs.zs"

//Hazards
#include "scripts/decorate/hazards/barrels.zs"
#include "scripts/decorate/hazards/electricity.zs"
#include "scripts/decorate/hazards/fallingrock.zs"
#include "scripts/decorate/hazards/gasflask.zs"
#include "scripts/decorate/hazards/mine.zs"
#include "scripts/decorate/hazards/traps.zs"

//Models
#include "scripts/decorate/models/furniture.zs"
#include "scripts/decorate/models/mission.zs"
#include "scripts/decorate/models/obstacles.zs"
#include "scripts/decorate/models/scenery.zs"
#include "scripts/decorate/models/special.zs"
#include "scripts/decorate/models/statues.zs"
#include "scripts/decorate/models/vehicles.zs"
#include "scripts/decorate/models/mapobjects.zs"

//Gore
#include "scripts/decorate/misc/nashgore.zs"
#include "scripts/decorate/misc/droplets.zs"

//Misc
#include "scripts/decorate/misc/civilians.zs"
#include "scripts/decorate/misc/cutscenes.zs"
#include "scripts/decorate/misc/teleporter.zs"

///////////////////////////////////////
//ACTORS CONVERTED FROM DECORATE: end//
///////////////////////////////////////

