

// -- Datums -- //

//We're including two new shuttle destinations. One is in orbit of our 'desert planet'
/datum/shuttle_destination/excursion/odin5a_orbit //Must be a unique path
	name = "Odin 5a Orbit" //The name of the destination
	my_area = /area/shuttle/excursion/space //The area the shuttle goes when it's settled at this destination
	preferred_interim_area = /area/shuttle/excursion/space_moving //The area the shuttle goes while it's moving there
	skip_me = TRUE //Must be TRUE on all away-mission destinations for reasons

	routes_to_make = list(
		/datum/shuttle_destination/excursion/odin5_orbit = 30 SECONDS
	)

//The other destination is landed on the surface
/datum/shuttle_destination/excursion/beach
	name = "Odin 5a Coastal Landing"
	my_area = /area/shuttle/excursion/away_beach
	preferred_interim_tag = "tether_excursion_transit_sand"
	skip_me = TRUE

	routes_to_make = list(
		/datum/shuttle_destination/excursion/odin5a_orbit = 30 SECONDS
	)

//This is a special subtype of the thing that generates ores on a map
//It will generate more rich ores because of the lower numbers than the normal one
/datum/random_map/noise/ore/beachmine
	descriptor = "beach mine ore distribution map"
	deep_val = 0.6 //More riches, normal is 0.7 and 0.8
	rare_val = 0.5

//The check_map_sanity proc is sometimes unsatisfied with how AMAZING our ores are
/datum/random_map/noise/ore/beachmine/check_map_sanity()
	var/rare_count = 0
	var/surface_count = 0
	var/deep_count = 0

	// Increment map sanity counters.
	for(var/value in map)
		if(value < rare_val)
			surface_count++
		else if(value < deep_val)
			rare_count++
		else
			deep_count++
	// Sanity check.
	if(surface_count < 100)
		admin_notice("<span class='danger'>Insufficient surface minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else if(rare_count < 50)
		admin_notice("<span class='danger'>Insufficient rare minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else if(deep_count < 50)
		admin_notice("<span class='danger'>Insufficient deep minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else
		return 1

// -- Objs -- //

//This object simply performs any map setup that needs to happen on our map if it loads.
//As with the above, you do need to place this object on the map somewhere.
/obj/away_mission_init/beachcave
	name = "away mission initializer - beachcave"

//In our case, it initializes the ores and random submaps in the beach's cave, then deletes itself
/obj/away_mission_init/beachcave/Initialize(mapload)
	new /datum/random_map/noise/ore/beachmine(null, 1, 1, Z_LEVEL_ODIN5A_CAVE, 64, 64)

	initialized = TRUE
	return INITIALIZE_HINT_QDEL

// Two mob spawners that are placed on the map that spawn some mobs!
// They keep track of their mob, and when it's dead, spawn another (only if nobody is looking)
// Note that if your map has step teleports, mobs may wander through them accidentally and not know how to get back
/obj/endeavor_away_spawner/beach_outside
	name = "Beach Outside Spawner" //Just a name
	faction = "beach_out" //Sets all the mobs to this faction so they don't infight
	atmos_comp = TRUE //Sets up their atmos tolerances to work in this setting, even if they don't normally (20% up/down tolerance for each gas, and heat)
	prob_spawn = 50 //Chance of this spawner spawning a mob (once this is missed, the spawner is 'depleted' and won't spawn anymore)
	prob_fall = 25 //Chance goes down by this much each time it spawns one (not defining and prob_spawn 100 means they spawn as soon as one dies)
	guard = 40 //They'll stay within this range (not defining this disables them staying nearby and they will wander the map (and through step teleports))
	mobs_to_pick_from = list(
		/mob/living/simple_mob/vore/aggressive/giant_snake
	)

/obj/endeavor_away_spawner/beach_outside_friendly
	name = "Fennec Spawner"
	faction = "fennec"
	atmos_comp = TRUE
	prob_spawn = 100
	prob_fall = 25
	guard = 40
	mobs_to_pick_from = list(
		/mob/living/simple_mob/vore/fennec
	)

/obj/endeavor_away_spawner/beach_cave
	name = "Beach Cave Spawner"
	faction = "beach_cave"
	atmos_comp = TRUE
	prob_spawn = 100
	prob_fall = 40
	guard = 20
	mobs_to_pick_from = list(
		/mob/living/simple_mob/vore/aggressive/frog = 3, //Frogs are 3x more likely to spawn than,
		/mob/living/simple_mob/vore/aggressive/deathclaw = 1, //these deathclaws are, with these values,
		/mob/living/simple_mob/animal/giant_spider = 3,
		/mob/living/simple_mob/vore/aggressive/giant_snake = 1,
		/mob/living/simple_mob/animal/giant_spider/ion = 2
	)

// These are step-teleporters, for map edge transitions
// This top one goes INTO the cave
/obj/effect/step_trigger/teleporter/away_beach_tocave/Initialize(mapload)
	. = ..()
	teleport_x = src.x //X is horizontal. This is a top of map transition, so you want the same horizontal alignment in the cave as you have on the beach
	teleport_y = 3 //2 is because it's putting you on row 2 of the map to the north
	teleport_z = z+1 //The cave is always our Z-level plus 1, because it's loaded after us

//This one goes OUT OF the cave
/obj/effect/step_trigger/teleporter/away_beach_tobeach/Initialize(mapload)
	. = ..()
	teleport_x = src.x //Same reason as bove
	teleport_y = world.maxy - 3 //This means "1 space from the top of the map"
	teleport_z = z-1 //Opposite of 'tocave', beach is always loaded as the map before us

// -- Turfs -- //

//These are just some special turfs for the beach water
/turf/simulated/floor/beach/coastwater/odin5a
	name = "Water"
	icon_state = "water"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 310.92

/turf/simulated/floor/beach/coastwater/Initialize(mapload)
	. = ..()
	add_overlay(image("icon"='icons/misc/beach.dmi',"icon_state"="water","layer"=MOB_LAYER+0.1))

/turf/simulated/floor/beach/coastline/odin5a
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 310.92


/turf/unsimulated/wall/planetary/odin5a
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 310.92 // About 37.7C / 100F

/turf/simulated/floor/beach/sand/desert/odin5a
	icon = 'icons/turf/desert.dmi'
	icon_state = "desert"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 310.92

/turf/simulated/floor/beach/sand/odin5a
	name = "Sand"
	icon_state = "sand"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 310.92

// -- Areas -- //

//And some special areas, including our shuttle landing spot (must be unique)
/area/shuttle/excursion/away_beach
	name = "\improper Excursion Shuttle - Beach"
	dynamic_lighting = 0

/area/endeavor_away/beach
	name = "\improper Away Mission - Odin 5a Beach"
	icon_state = "away"
	base_turf = /turf/simulated/floor/beach/sand/desert/odin5a //This is what the ground turns into if destroyed/bombed/etc
	//Not going to do sunlight simulations here like virgo3b
	//So we just make the whole beach fullbright all the time
	dynamic_lighting = 0

/area/endeavor_away/beach/powershed
	name = "\improper Away Mission - Odin 5a Coast PS"
	icon_state = "blue2"
	base_turf = /turf/simulated/floor/beach/sand

/area/endeavor_away/beach/coast
	name = "\improper Away Mission - Odin 5a Coast"
	icon_state = "blue2"
	base_turf = /turf/simulated/floor/beach/coastline

/area/endeavor_away/beach/water
	name = "\improper Away Mission - Odin 5a Water"
	icon_state = "bluenew"
	base_turf = /turf/simulated/floor/beach/coastwater

/area/endeavor_away/beach/eastereggisland
	name = "\improper Away Mission - Odin 5a Island"
	icon_state = "bluenew"
	base_turf = /turf/simulated/floor/beach/sand

/area/endeavor_away/beach/jungle
	name = "\improper Away Mission - Odin 5a Desert"
	icon_state = "green"
	base_turf = /turf/simulated/floor/beach/sand/desert

//Some areas for the cave, which are referenced by our init object to seed submaps and ores
/area/endeavor_away/cave
	flags = RAD_SHIELDED
	ambience = list('sound/ambience/ambimine.ogg', 'sound/ambience/song_game.ogg')
	base_turf = /turf/simulated/mineral/floor/ignore_mapgen/cave

/area/endeavor_away/cave/explored/normal
	name = "\improper Away Mission - Odin 5a Cave (E)"
	icon_state = "explored"

/area/endeavor_away/cave/unexplored/normal
	name = "\improper Away Mission - Odin 5a Cave (UE)"
	icon_state = "unexplored"

/area/endeavor_away/cave/explored/deep
	name = "\improper Away Mission - Odin 5a Cave Deep (E)"
	icon_state = "explored_deep"

/area/endeavor_away/cave/unexplored/deep
	name = "\improper Away Mission - Odin 5a Cave Deep (UE)"
	icon_state = "unexplored_deep"
