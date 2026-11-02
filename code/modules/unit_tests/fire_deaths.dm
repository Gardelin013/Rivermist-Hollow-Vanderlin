/datum/unit_test/fire_deaths_undead_burn_down

/datum/unit_test/fire_deaths_undead_burn_down/Run()
	var/mob/living/carbon/human/species/zizombie/npc/zombie = allocate(/mob/living/carbon/human/species/zizombie/npc)
	zombie.after_creation()
	zombie.configure_mind()
	TEST_ASSERT(zombie.mob_biotypes & MOB_UNDEAD, "Test setup needs an undead zizombie.")
	TEST_ASSERT_NOTNULL(zombie.mind, "Test setup needs the keyless mind NPC zizombies carry.")
	TEST_ASSERT(!zombie.defeat_system_is_eligible(), "A keyless NPC undead must not enter defeat, or it is knocked out and stabilised instead of killed.")

	var/obj/item/bodypart/chest = zombie.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_NOTNULL(chest, "Test setup needs a chest.")
	chest.receive_damage(burn = 1000)
	zombie.updatehealth()
	TEST_ASSERT_EQUAL(zombie.stat, DEAD, "An undead whose chest is burnt to its limit must die.")

/datum/unit_test/fire_deaths_living_survive_burns

/datum/unit_test/fire_deaths_living_survive_burns/Run()
	var/mob/living/carbon/human/living = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = living.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_NOTNULL(chest, "Test setup needs a chest.")
	chest.receive_damage(burn = 1000)
	living.updatehealth()
	TEST_ASSERT(living.stat != DEAD, "Burns alone must still not kill a living human.")

/datum/unit_test/fire_deaths_simple_mob_burns_to_ash

/datum/unit_test/fire_deaths_simple_mob_burns_to_ash/Run()
	var/turf/pyre_turf = run_loc_floor_bottom_left
	var/mob/living/simple_animal/hostile/beast = allocate(/mob/living/simple_animal/hostile, pyre_turf)
	beast.adjust_fire_stacks(5)
	beast.IgniteMob()
	TEST_ASSERT(beast.on_fire, "Test setup needs a burning simple mob.")
	beast.death()
	TEST_ASSERT_EQUAL(beast.stat, DEAD, "Test setup needs a dead simple mob.")

	beast.handle_fire()
	TEST_ASSERT(QDELETED(beast), "A simple mob that died on fire must burn away instead of leaving a carcass.")
	TEST_ASSERT_NOTNULL(locate(/obj/item/fertilizer/ash) in pyre_turf, "A simple mob that burnt away must leave ash behind.")
