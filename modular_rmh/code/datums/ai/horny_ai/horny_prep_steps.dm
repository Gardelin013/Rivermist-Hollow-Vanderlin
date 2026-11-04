/// One unit of prep work on a held or floored target. Singletons owned by a family profile; keep no mob refs.
/datum/horny_prep_step

/// TRUE when the step has work to do right now.
/datum/horny_prep_step/proc/can_run(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	return FALSE

/// Does the work. TRUE when it acted, so the hunt pauses a beat before the next step.
/datum/horny_prep_step/proc/perform_step(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	return FALSE

/// A held weapon comes loose before anything else.
/datum/horny_prep_step/disarm

/datum/horny_prep_step/disarm/can_run(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	return hunter.Adjacent(target) && mob_has_ai_disarmable_held_item(target)

/datum/horny_prep_step/disarm/perform_step(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	return horny_disarm_target(hunter, target)

/// A handed hunter whose own clothes block every act pulls them off first.
/datum/horny_prep_step/undress_self

/datum/horny_prep_step/undress_self/can_run(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	if(has_valid_act || !ishuman(hunter))
		return FALSE
	return !isnull(horny_pick_strip_target(hunter, hunter, FALSE))

/datum/horny_prep_step/undress_self/perform_step(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	return horny_strip_target(hunter, hunter, 8 DECISECONDS, include_mouth_cover = FALSE)

/// Pulls the target's clothes off: the first piece always, then when nothing fits, or on a whim.
/datum/horny_prep_step/strip

/datum/horny_prep_step/strip/can_run(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	if(!hunter.Adjacent(target))
		return FALSE
	if(!horny_pick_strip_target(hunter, target, allow_regular_clothes = TRUE))
		return FALSE
	if(!controller.blackboard[BB_HORNY_INITIAL_STRIP_DONE])
		return TRUE
	return !has_valid_act || prob(profile.extra_strip_chance)

/datum/horny_prep_step/strip/perform_step(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	controller.set_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE, TRUE)
	var/delay = rand(profile.strip_delay_min, profile.strip_delay_max) DECISECONDS
	return horny_strip_target(hunter, target, delay, profile.strip_damage_chance, profile.strip_damage_ratio, allow_regular_clothes = TRUE)

/// Ties the wrists of a floored, empty-handed target with the family's restraint.
/datum/horny_prep_step/bind

/datum/horny_prep_step/bind/can_run(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	if(!profile.restraint_type)
		return FALSE
	if(target.body_position != LYING_DOWN || target.get_active_held_item())
		return FALSE
	if(!hunter.Adjacent(target) || target.get_num_arms(TRUE) <= 1 || target.handcuffed)
		return FALSE
	return TRUE

/datum/horny_prep_step/bind/perform_step(datum/ai_controller/controller, mob/living/hunter, mob/living/carbon/human/target, datum/horny_family_profile/profile, has_valid_act)
	var/list/lines = profile.get_bind_lines(hunter, target)
	target.visible_message(span_danger(lines["start"]), span_userdanger(lines["start_target"]), span_hear(lines["start_hear"]))
	if(!do_after(hunter, 1 SECONDS, target))
		return TRUE
	if(QDELETED(target) || !hunter.Adjacent(target) || target.handcuffed || target.body_position != LYING_DOWN)
		return TRUE

	var/obj/item/rope/restraints = new profile.restraint_type
	if(restraints.apply_cuffs(target, hunter))
		target.visible_message(span_danger(lines["done"]), span_userdanger(lines["done_target"]), span_hear(lines["done_hear"]))
		return TRUE
	qdel(restraints)
	return TRUE

// --- Shared helpers ------------------------------------------------------------------------------

/proc/get_horny_disarm_intent()
	var/static/datum/intent/unarmed/shove/disarm_intent = new()
	return disarm_intent

/// One disarm attempt with the shove intent. TRUE whenever an attempt was made.
/proc/horny_disarm_target(mob/living/hunter, mob/living/carbon/human/target)
	if(!target.Adjacent(hunter) || !mob_has_ai_disarmable_held_item(target))
		return FALSE
	var/datum/intent/disarm_intent = get_horny_disarm_intent()
	var/datum/intent/cached_intent = hunter.used_intent
	hunter.used_intent = disarm_intent
	var/defended = target.checkdefense(disarm_intent, hunter)
	hunter.used_intent = cached_intent
	if(defended)
		return TRUE

	var/handed = iscarbon(hunter)
	if(!prob(30))
		if(handed)
			target.visible_message(span_danger("[hunter] lunges for [target]'s weapon, but can't wrench it free!"), \
				span_userdanger("[hunter] lunges for my weapon, but I keep hold of it!"), span_hear("I hear a struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		else
			target.visible_message(span_danger("[hunter] swats at [target]'s hands, but fails to disarm them!"), \
				span_userdanger("[hunter] swats at my hands, but I keep hold of my weapon!"), span_hear("I hear a rough struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		return TRUE

	var/disarmed_anything = FALSE
	for(var/obj/item/held_item as anything in target.held_items)
		if(!is_ai_disarmable_held_item(held_item))
			continue
		if(target.dropItemToGround(held_item, force = FALSE, silent = FALSE))
			disarmed_anything = TRUE
	if(!disarmed_anything)
		return TRUE
	target.Stun(5)
	target.visible_message(span_danger("[hunter] [handed ? "wrenches" : "bats"] [target]'s weapon out of [target.p_their()] hands!"), \
		span_userdanger("[hunter] disarms me!"), span_hear("I hear a weapon clatter to the ground."), COMBAT_MESSAGE_RANGE)
	return TRUE

/proc/horny_add_strip_choice(list/choices, mob/living/hunter, mob/living/carbon/human/target, obj/item/item, weight)
	if(!item || weight <= 0)
		return
	if(item.loc != target || !item.canStrip(hunter, target))
		return
	var/current_weight = choices[item]
	if(isnull(current_weight))
		current_weight = 0
	choices[item] = max(current_weight, weight)

/// Picks what to pull off next: groin blockers first, then a mouth cover, then regular clothes if allowed.
/proc/horny_pick_strip_target(mob/living/hunter, mob/living/carbon/human/target, include_mouth_cover = TRUE, allow_regular_clothes = FALSE)
	var/list/weighted_blockers = list()
	var/list/weighted_regular_clothes = list()

	var/list/groin_priority = list(
		target.wear_pants = 12,
		target.underwear = 10,
		target.wear_armor = 6,
		target.cloak = 4,
		target.wear_shirt = 2,
		target.undershirt = 2,
		target.wear_mask = 1,
		target.head = 1,
		target.gloves = 1,
	)

	for(var/obj/item/item as anything in groin_priority)
		var/weight = groin_priority[item]
		if(!item || item.loc != target || !item.canStrip(hunter, target))
			continue

		if(istype(item, /obj/item/clothing))
			var/obj/item/clothing/clothing_item = item
			if(clothing_item.armor_class > AC_LIGHT && zone2covered(BODY_ZONE_PRECISE_GROIN, clothing_item.body_parts_covered))
				horny_add_strip_choice(weighted_blockers, hunter, target, clothing_item, weight)
				continue
			if((clothing_item.flags_inv & HIDECROTCH) && !clothing_item.genital_access)
				horny_add_strip_choice(weighted_blockers, hunter, target, clothing_item, weight)
				continue

		if(allow_regular_clothes)
			horny_add_strip_choice(weighted_regular_clothes, hunter, target, item, weight)

	if(include_mouth_cover)
		var/obj/item/mouth_cover = target.is_mouth_covered()
		if(istype(mouth_cover) && mouth_cover.loc == target && mouth_cover.canStrip(hunter, target))
			horny_add_strip_choice(weighted_blockers, hunter, target, mouth_cover, 3)

	if(length(weighted_blockers))
		return pickweight(weighted_blockers)
	if(allow_regular_clothes && length(weighted_regular_clothes))
		return pickweight(weighted_regular_clothes)
	return null

/// Tugs one piece off over strip_delay, with a chance to damage it and the stockings beneath. TRUE when it tried.
/proc/horny_strip_target(mob/living/hunter, mob/living/carbon/human/target, strip_delay, damage_chance = 0, damage_ratio = 0, include_mouth_cover = TRUE, allow_regular_clothes = FALSE)
	var/obj/item/stripped_item = horny_pick_strip_target(hunter, target, include_mouth_cover, allow_regular_clothes)
	if(!stripped_item)
		return FALSE

	if(target == hunter)
		hunter.visible_message(span_danger("[hunter] starts hurriedly pulling off [hunter.p_their()] [stripped_item.name]!"))
	else
		hunter.visible_message(span_danger("[hunter] starts tugging at [target]'s [stripped_item.name]!"))

	if(!do_after(hunter, strip_delay, target, interaction_key = "horny_strip"))
		return TRUE
	if(QDELETED(stripped_item) || stripped_item.loc != target)
		return TRUE
	if(!target.dropItemToGround(stripped_item, force = FALSE, silent = FALSE))
		return TRUE

	if(damage_chance && prob(damage_chance) && !istype(stripped_item, /obj/item/storage) && !istype(stripped_item, /obj/item/clothing/ring))
		stripped_item.take_damage(damage_amount = stripped_item.max_integrity * damage_ratio, sound_effect = FALSE)

	if(target == hunter)
		hunter.visible_message(span_danger("[hunter] tears off [hunter.p_their()] [stripped_item.name]!"))
		return TRUE

	hunter.visible_message(span_danger("[hunter] tears [target]'s [stripped_item.name] loose!"))
	// orange() also returns areas and objects, which throw_at cannot land on.
	var/turf/target_turf = get_turf(target)
	var/turf/landing_spot = target_turf ? pick(RANGE_TURFS(2, target_turf)) : null
	if(landing_spot)
		stripped_item.throw_at(landing_spot, 2, 1, hunter, TRUE)
	// Rough hands snag the stockings the strip just bared.
	var/obj/item/clothing/legwears/stockings = target.get_exposed_legwear()
	if(stockings && damage_chance && prob(damage_chance))
		var/stockings_name = stockings.name
		if(stockings.tear_open())
			hunter.visible_message(span_danger("[hunter]'s rough handling tears [target]'s [stockings_name]!"))
	return TRUE
