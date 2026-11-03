/// The hunt: the posture gate, temper, the rush, the damage budget, the sprint and the overwhelmed beat.
/datum/unit_test/ai_horny_hunt
	abstract_type = /datum/unit_test/ai_horny_hunt
#ifdef FOCUS_AI_HORNY_HUNT_TEST
	focus = TRUE
#endif

/// A goblin that wants a clientless partner, with the hunt behaviour running.
/datum/unit_test/ai_horny_hunt/proc/start_hunt(mob/living/carbon/human/species/goblin/npc/goblin, mob/living/carbon/human/partner)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	return controller

/// One perform of the hunt behaviour, as SSai_behaviors would run it.
/datum/unit_test/ai_horny_hunt/proc/hunt_tick(datum/ai_controller/controller)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	hunt.perform(0.1, controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)

/// Teardown: a floored, grabbed human runtimes in its async get_up() when deleted.
/datum/unit_test/ai_horny_hunt/proc/end_hunt(datum/ai_controller/controller, mob/living/partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	if(LAZYACCESS(controller.current_behaviors, hunt))
		hunt.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	var/mob/living/pawn = controller.pawn
	pawn.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// Nothing starts on a target that is still on its feet and free.
/datum/unit_test/ai_horny_hunt/act_waits_for_a_subdued_target

/datum/unit_test/ai_horny_hunt/act_waits_for_a_subdued_target/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "Test setup: the hunt should start.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_SEIZE, "A hunter already next to its target skips the tell and goes for the catch.")
	TEST_ASSERT(!horny_target_is_subdued(goblin, partner), "Test setup: a standing, free partner is not subdued.")

	for(var/i in 1 to 3)
		controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time + 1 MINUTES) // no takedown roll: the partner keeps their feet
		hunt_tick(controller)
		TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_USE, "No act may start while the partner stands free (phase [controller.blackboard[BB_HORNY_PHASE]], lying [partner.body_position == LYING_DOWN], pulledby [partner.pulledby], grab [goblin.grab_state], restrained [HAS_TRAIT(partner, TRAIT_RESTRAINED)], yield [partner.surrendering], buckled [partner.buckled]).")
	TEST_ASSERT(!length(partner.sex_scene?.get_actions_involving(partner)), "No sex action may run on a standing, free partner.")

	partner.SetKnockdown(30 SECONDS)
	TEST_ASSERT(horny_target_is_subdued(goblin, partner), "A floored partner counts as subdued.")
	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_SEIZE, "Once the partner is down the hunt moves past the catch.")
	end_hunt(controller, partner)

/// A fireball to the face makes the hunter come on faster; it does not end the hunt.
/datum/unit_test/ai_horny_hunt/ranged_hits_rush_without_cancel

/datum/unit_test/ai_horny_hunt/ranged_hits_rush_without_cancel/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)

	for(var/i in 1 to 3)
		controller.set_blackboard_key(BB_LAST_RANGED_ATTACKER, partner)
		controller.set_blackboard_key(BB_LAST_RANGED_HIT_TIME, world.time)
		SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, 1)
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] >= HORNY_TEMPER_ROUGH, "Three ranged hits should leave the hunter rough-tempered.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_RUSH_UNTIL] > world.time, "A ranged hit should start a rush.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], partner, "Light ranged hits must not end the hunt.")
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_AGGRO_TARGET], "Light ranged hits must not turn the hunter hostile.")
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "The hunt behaviour must survive light ranged hits.")
	end_hunt(controller, partner)

/// Damage past the budget turns the hunt into a real fight.
/datum/unit_test/ai_horny_hunt/damage_budget_turns_the_hunt_into_a_fight

/datum/unit_test/ai_horny_hunt/damage_budget_turns_the_hunt_into_a_fight/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/budget = goblin.maxHealth * HORNY_LETHAL_DAMAGE_SHARE

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, budget * 0.5)
	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	TEST_ASSERT(!hostile_targets || isnull(hostile_targets[partner]), "Half the budget is a rough partner, not a mortal threat.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], partner, "Half the budget keeps the hunt alive.")

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, budget * 0.6)
	hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	TEST_ASSERT(hostile_targets && !isnull(hostile_targets[partner]), "Damage past the budget makes the partner hostile.")
	TEST_ASSERT_NULL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], "A fight clears the horny target.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], partner, "The attacker becomes the combat target.")
	end_hunt(controller, partner)

/// An attacker the hunter may not want is mortal danger: combat first.
/datum/unit_test/ai_horny_hunt/third_party_attack_takes_priority

/datum/unit_test/ai_horny_hunt/third_party_attack_takes_priority/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, stranger, 5)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], stranger, "A stranger's attack must become the combat target at once.")
	TEST_ASSERT_NULL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], "Mortal danger ends the hunt.")
	end_hunt(controller, partner)

/// A furious humanoid wrestles instead of using, then comes back calmer.
/datum/unit_test/ai_horny_hunt/furious_humanoid_breaks_off_and_returns

/datum/unit_test/ai_horny_hunt/furious_humanoid_breaks_off_and_returns/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	controller.set_blackboard_key(BB_HORNY_TEMPER, HORNY_TEMPER_FURIOUS + 10)
	controller.set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)

	hunt_tick(controller)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_BREAK_OFF, "A furious hunter breaks off.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_BREAK_OFF_UNTIL] > world.time, "The break-off has an end.")
	TEST_ASSERT(!length(partner.sex_scene?.get_actions_involving(partner)), "No act runs during a break-off.")

	controller.set_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL, world.time - 1)
	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_BREAK_OFF, "The hunt resumes when the window ends.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] <= HORNY_TEMPER_ROUGH, "Coming back calms the hunter to rough at most.")
	end_hunt(controller, partner)

/// A humanoid hunter runs while it rushes, and walks again when the hunt ends.
/datum/unit_test/ai_horny_hunt/hunting_human_runs_and_walks_after

/datum/unit_test/ai_horny_hunt/hunting_human_runs_and_walks_after/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_NOTICE, "A hunter with a gap to close starts with the tell.")

	controller.set_blackboard_key(BB_HORNY_PHASE, HORNY_PHASE_STALK)
	controller.set_blackboard_key(BB_HORNY_RUSH_UNTIL, world.time + 10 SECONDS)
	hunt_tick(controller)
	TEST_ASSERT_EQUAL(goblin.m_intent, MOVE_INTENT_RUN, "A rushing humanoid hunter should switch to the run intent.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_SPRINTING], "The hunt should remember that it set the run intent.")

	hunt.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT_EQUAL(goblin.m_intent, MOVE_INTENT_WALK, "The hunter walks again when the hunt ends.")
	end_hunt(controller, partner)

/// A hunter at the top of its lust lets go, presents, and gets up again calmer.
/datum/unit_test/ai_horny_hunt/overwhelmed_hunter_presents

/datum/unit_test/ai_horny_hunt/overwhelmed_hunter_presents/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	partner.SetKnockdown(30 SECONDS)
	controller.set_blackboard_key(BB_HORNY_LUST, HORNY_LUST_MAX - HORNY_LUST_PER_CLIMAX + 1)

	SEND_SIGNAL(goblin, COMSIG_SEX_CLIMAX, null, goblin, partner, goblin)
	TEST_ASSERT(controller.blackboard[BB_HORNY_LUST] >= HORNY_LUST_MAX, "The hunter's own climax feeds its lust.")

	hunt_tick(controller)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_PRESENT, "A hunter at the top of its lust lets go and presents.")
	TEST_ASSERT_NULL(goblin.pulling, "Presenting drops the hold.")

	controller.set_blackboard_key(BB_HORNY_PRESENT_UNTIL, world.time - 1)
	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_PRESENT, "The hunter gets up again when the beat ends.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_LUST], HORNY_LUST_AFTER_PRESENT, "Presenting takes the edge off the lust.")
	end_hunt(controller, partner)
