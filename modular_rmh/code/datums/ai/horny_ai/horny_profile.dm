GLOBAL_LIST_EMPTY(horny_family_profiles)

/// The profile for a family flag. Unknown flags and NONE get the base profile.
/proc/horny_profile_for_flag(family_flag)
	if(!length(GLOB.horny_family_profiles))
		for(var/profile_type in typesof(/datum/horny_family_profile))
			var/datum/horny_family_profile/profile = new profile_type
			GLOB.horny_family_profiles["[profile.family_flag]"] = profile
	return GLOB.horny_family_profiles["[family_flag]"] || GLOB.horny_family_profiles["[NONE]"]

/// How one family of horny mobs hunts: tells, pain, break-off, prep steps, acts and lines. Singleton, keeps no mob refs.
/datum/horny_family_profile
	/// HORNY_MOB_TYPE_* flag this profile serves; NONE is the fallback.
	var/family_flag = NONE
	/// Temper gained per point of damage. Zero means pain never moves this family.
	var/pain_factor = 1
	/// Hurt fraction (get_ai_hurt_fraction) at which the hunt breaks off.
	var/hurt_limit = 0.5
	/// Hurt fraction at which the hunter gives the hunt up for good.
	var/flee_limit = 0.7
	/// What furious looks like, HORNY_BREAK_OFF_*.
	var/break_off = HORNY_BREAK_OFF_SUBDUE
	/// Human hunters that switch to the run intent inside sprint_range.
	var/can_sprint = FALSE
	var/sprint_range = HORNY_SPRINT_RANGE
	/// Handless hunters: step delay multiplier while rushing after a ranged hit.
	var/rush_speed_mult = HORNY_RUSH_SPEED_MULT
	/// How long the tell lasts before the hunter moves.
	var/notice_time = HORNY_NOTICE_TIME
	/// Prep step types, run in this order once the target is held or down.
	var/list/prep_step_types = list(
		/datum/horny_prep_step/disarm,
		/datum/horny_prep_step/undress_self,
		/datum/horny_prep_step/strip,
		/datum/horny_prep_step/bind,
	)
	/// Step singletons built from prep_step_types.
	var/list/prep_steps
	/// Strip pacing in deciseconds, and the rough-handling damage roll.
	var/strip_delay_min = 12
	var/strip_delay_max = 20
	var/strip_damage_chance = 35
	var/strip_damage_ratio = 0.15
	/// Chance to strip one more piece even when an act already fits.
	var/extra_strip_chance = 35
	/// Restraint the bind step applies; null means this family cannot bind.
	var/restraint_type = /obj/item/rope

/datum/horny_family_profile/New()
	. = ..()
	prep_steps = list()
	for(var/step_type in prep_step_types)
		prep_steps += new step_type

/// The step singleton of a given type, or null when this family lacks it.
/datum/horny_family_profile/proc/get_prep_step(step_type)
	for(var/datum/horny_prep_step/step as anything in prep_steps)
		if(step.type == step_type)
			return step
	return null

/// Called when lust tops out; the hunt already stopped the act and dropped the hold.
/datum/horny_family_profile/proc/on_overwhelmed(datum/ai_controller/controller, mob/living/hunter, mob/living/target)
	return

// --- Lines ---------------------------------------------------------------------------------------

/// The tell when a hunter picks its target.
/datum/horny_family_profile/proc/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s eyes lock onto [target], and a slow grin spreads across [hunter.p_their()] face."

/// A handless hunter settling its hold on the target.
/datum/horny_family_profile/proc/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] clamps onto [target], holding [target.p_them()] in place!"

/// The hunter giving up on its target.
/datum/horny_family_profile/proc/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] stomps on the ground, clearly unsatisfied!"

/// The hunter done with its target; heavy means sated for a long while.
/datum/horny_family_profile/proc/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] lets out a relieved sigh and releases [target] for now." : "[hunter] exhales contently!"

/// A ranged hit landing: the hunter staggers, then comes on faster.
/datum/horny_family_profile/proc/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] staggers, snarls, and comes on faster!"

/// The hunter breaking off.
/datum/horny_family_profile/proc/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] snarls and goes for [target]'s arms instead!"

/// The hunter overwhelmed by its own lust.
/datum/horny_family_profile/proc/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] loses [hunter.p_their()] grip and sags, flushed and trembling, open to [target]."

/// Start and finish lines for the bind step, keyed start, start_target, start_hear, done, done_target, done_hear.
/datum/horny_family_profile/proc/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] begins to tie up [target]'s hands!",
		"start_target" = "[hunter] begins to tie my hands!",
		"start_hear" = "I hear rope being pulled tight.",
		"done" = "[hunter] binds [target]'s wrists with rope!",
		"done_target" = "[hunter] binds my wrists with rope!",
		"done_hear" = "I hear rope knotting.",
	)

// --- Acts ----------------------------------------------------------------------------------------

/// Adds this family's act types to a weighted list, heavier entries more likely.
/datum/horny_family_profile/proc/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	var/has_penis = !!hunter.getorganslot(ORGAN_SLOT_PENIS)
	var/has_vagina = !!hunter.getorganslot(ORGAN_SLOT_VAGINA)
	var/target_has_penis = !!target.getorganslot(ORGAN_SLOT_PENIS)
	var/target_has_vagina = !!target.getorganslot(ORGAN_SLOT_VAGINA)

	// Skeletons: a funny bone gets its own acts, and one with nothing below the belt can only pet.
	if(istype(hunter.getorganslot(ORGAN_SLOT_PENIS), /obj/item/organ/genitals/penis/funny_bone))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/funny_bone, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/funny_bone)
		if(target_has_vagina && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/funny_bone, 3)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_jerk_over/funny_bone)
		return
	if(!has_penis && !has_vagina && istype(hunter, /mob/living/carbon/human/species/skeleton))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_bony_petting)
		return

	if(has_penis)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex)
		if(target_has_vagina && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex, 3)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_handjob)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_jerk_over)

	if(has_vagina)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_facesitting, 2)
		if(target_has_penis)
			if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA, TRUE))
				add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_ride_sex, 3)
			if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS, TRUE))
				add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_ride_sex)

	if(has_penis || has_vagina)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_body_rub)
		// Humanoids also dry-hump; the grind's own rules pick a spot by height and posture.
		if(ishuman(hunter))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/grind/partner/npc)

// --- Families ------------------------------------------------------------------------------------

/datum/horny_family_profile/humanoids
	family_flag = HORNY_MOB_TYPE_HUMANOIDS
	can_sprint = TRUE

/datum/horny_family_profile/undead
	family_flag = HORNY_MOB_TYPE_UNDEAD
	pain_factor = 0
	hurt_limit = 2
	flee_limit = 2
	break_off = HORNY_BREAK_OFF_NONE
	notice_time = 0

/datum/horny_family_profile/undead/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] turns its hollow gaze on [target] and starts toward [target.p_them()]."

/datum/horny_family_profile/undead/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] rattles and claws at the empty air, denied!"

/datum/horny_family_profile/undead/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] sags, its hunger dulled, and lets [target] be for now." : "[hunter] rattles with a hollow, satisfied sigh."

/datum/horny_family_profile/undead/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] rattles once and sags, hollow and still."

/datum/horny_family_profile/lycans
	family_flag = HORNY_MOB_TYPE_LYCANS
	hurt_limit = 0.4
	break_off = HORNY_BREAK_OFF_CIRCLE
	can_sprint = TRUE
	restraint_type = null

/datum/horny_family_profile/lycans/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s ears prick toward [target] and its lips peel back from its teeth."

/datum/horny_family_profile/lycans/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] slams into [target] and pins [target.p_them()] in place!"

/datum/horny_family_profile/lycans/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] snarls and paws at the ground, clearly unsatisfied!"

/datum/horny_family_profile/lycans/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] huffs, spent, and lets [target] go for now." : "[hunter] pants and shakes itself out, satisfied."

/datum/horny_family_profile/lycans/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] yelps, shakes it off, and charges!"

/datum/horny_family_profile/lycans/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] backs off, hackles up, and begins to circle [target]."

/datum/horny_family_profile/lycans/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] drops onto its back with a whine, belly up and twitching."

/datum/horny_family_profile/beasts
	family_flag = HORNY_MOB_TYPE_BEASTS
	pain_factor = 1.2
	hurt_limit = 0.4
	break_off = HORNY_BREAK_OFF_CIRCLE
	strip_damage_chance = 60
	strip_damage_ratio = 0.25
	restraint_type = null

/datum/horny_family_profile/beasts/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] lifts its head, nostrils flaring toward [target], and a low growl rolls out."

/datum/horny_family_profile/beasts/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] pins [target] in place with snapping jaws and brute weight!"

/datum/horny_family_profile/beasts/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] snarls and paws at the ground, clearly unsatisfied!"

/datum/horny_family_profile/beasts/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] huffs, spent, and lets [target] go for now." : "[hunter] pants and shakes itself out, satisfied."

/datum/horny_family_profile/beasts/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] yelps, shakes it off, and charges!"

/datum/horny_family_profile/beasts/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] backs off, hackles up, and begins to circle [target]."

/datum/horny_family_profile/beasts/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] rolls onto its back with a whine, belly up and twitching."

/datum/horny_family_profile/spiders
	family_flag = HORNY_MOB_TYPE_SPIDERS
	pain_factor = 1.5
	hurt_limit = 0.3
	break_off = HORNY_BREAK_OFF_FLEE
	extra_strip_chance = 20
	restraint_type = /obj/item/rope/spider_silk

/datum/horny_family_profile/spiders/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes still, every eye fixed on [target], then its legs begin to twitch."

/datum/horny_family_profile/spiders/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] pins [target] down under a tangle of bristling legs!"

/datum/horny_family_profile/spiders/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] clicks its mandibles and skitters in a tight, frustrated circle!"

/datum/horny_family_profile/spiders/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] goes still, sated, and lets [target] be for now." : "[hunter] settles with a satisfied chitter."

/datum/horny_family_profile/spiders/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] skitters sideways, then rushes in!"

/datum/horny_family_profile/spiders/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] skitters back into the dark, eyes still on [target]."

/datum/horny_family_profile/spiders/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s legs fold under it and it lies there, chittering weakly."

/datum/horny_family_profile/spiders/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts winding sticky silk around [target]'s wrists!",
		"start_target" = "[hunter] starts winding sticky silk around my wrists!",
		"start_hear" = "I hear wet strands of silk stretching tight.",
		"done" = "[hunter] binds [target]'s wrists in spider silk!",
		"done_target" = "[hunter] binds my wrists in sticky spider silk!",
		"done_hear" = "I hear silk tightening around someone's wrists.",
	)

/datum/horny_family_profile/bog_bugs
	family_flag = HORNY_MOB_TYPE_BOG_BUGS
	pain_factor = 1.5
	hurt_limit = 0.3
	break_off = HORNY_BREAK_OFF_FLEE
	restraint_type = null

/datum/horny_family_profile/bog_bugs/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s antennae swing toward [target] and its mandibles click."

/datum/horny_family_profile/bog_bugs/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] clamps onto [target], locking [target.p_them()] in place!"

/datum/horny_family_profile/bog_bugs/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] clicks its mandibles and skitters in a tight, frustrated circle!"

/datum/horny_family_profile/bog_bugs/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] goes still, sated, and lets [target] be for now." : "[hunter] settles with a satisfied chitter."

/datum/horny_family_profile/bog_bugs/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] skitters sideways, then rushes in!"

/datum/horny_family_profile/bog_bugs/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] scuttles back out of reach, mandibles working."

/datum/horny_family_profile/bog_bugs/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s legs fold under it and it lies there, chittering weakly."

/datum/horny_family_profile/trolls
	family_flag = HORNY_MOB_TYPE_TROLLS
	pain_factor = 0.5
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_ENRAGE
	strip_damage_chance = 60
	strip_damage_ratio = 0.3
	restraint_type = null

/datum/horny_family_profile/trolls/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] snorts, sniffs the air, and turns its whole bulk toward [target]."

/datum/horny_family_profile/trolls/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] mauls [target] to the ground and keeps [target.p_them()] there!"

/datum/horny_family_profile/trolls/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] bellows and stamps the ground, clearly unsatisfied!"

/datum/horny_family_profile/trolls/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] grunts, spent, and shoves [target] aside for now." : "[hunter] grunts, content."

/datum/horny_family_profile/trolls/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] roars and barrels forward!"

/datum/horny_family_profile/trolls/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] bellows and comes on harder!"

/datum/horny_family_profile/trolls/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] sits down heavily, chest heaving, too far gone to hold on."

/datum/horny_family_profile/minotaurs
	family_flag = HORNY_MOB_TYPE_MINOTAURS
	pain_factor = 0.5
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_ENRAGE
	strip_damage_chance = 60
	strip_damage_ratio = 0.3
	restraint_type = null

/datum/horny_family_profile/minotaurs/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] stamps once and lowers its horns toward [target], breath steaming."

/datum/horny_family_profile/minotaurs/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] hooks [target] into a crushing hold and keeps [target.p_them()] pinned!"

/datum/horny_family_profile/minotaurs/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] bellows and stamps the ground, clearly unsatisfied!"

/datum/horny_family_profile/minotaurs/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] grunts, spent, and shoves [target] aside for now." : "[hunter] grunts, content."

/datum/horny_family_profile/minotaurs/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] roars and barrels forward!"

/datum/horny_family_profile/minotaurs/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] bellows and comes on harder!"

/datum/horny_family_profile/minotaurs/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] sits down heavily, chest heaving, too far gone to hold on."

/datum/horny_family_profile/lamias
	family_flag = HORNY_MOB_TYPE_LAMIAS
	break_off = HORNY_BREAK_OFF_FLEE
	restraint_type = null

/datum/horny_family_profile/lamias/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s eyes catch the light as they settle on [target], tongue flicking."

/datum/horny_family_profile/lamias/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] coils tightly around [target], holding [target.p_them()] fast!"

/datum/horny_family_profile/lamias/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] hisses and lashes its tail, clearly unsatisfied!"

/datum/horny_family_profile/lamias/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] uncoils with a long, lazy hiss and releases [target] for now." : "[hunter] flicks its tongue, satisfied."

/datum/horny_family_profile/lamias/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] hisses and surges forward!"

/datum/horny_family_profile/lamias/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] uncoils and slips back toward the shadows."

/datum/horny_family_profile/lamias/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils go slack and it lies there, tongue lolling."

/datum/horny_family_profile/lizards
	family_flag = HORNY_MOB_TYPE_LIZARDS
	pain_factor = 0.8
	break_off = HORNY_BREAK_OFF_CIRCLE
	restraint_type = null

/datum/horny_family_profile/lizards/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes very still, then its jaws part toward [target]."

/datum/horny_family_profile/lizards/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] hisses and lashes its tail, clearly unsatisfied!"

/datum/horny_family_profile/lizards/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] uncoils with a long, lazy hiss and releases [target] for now." : "[hunter] flicks its tongue, satisfied."

/datum/horny_family_profile/lizards/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] hisses and surges forward!"

/datum/horny_family_profile/lizards/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] slides back, jaws open, waiting."

/datum/horny_family_profile/lizards/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes limp, jaws slack, tail twitching."

/datum/horny_family_profile/tentacles
	family_flag = HORNY_MOB_TYPE_TENTACLES
	pain_factor = 0.3
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_SINK
	extra_strip_chance = 20
	restraint_type = /obj/item/rope/spider_silk/tentacle_resin

/datum/horny_family_profile/tentacles/get_notice_message(mob/living/hunter, mob/living/target)
	return "Something beneath the loam shifts and strains toward [target]."

/datum/horny_family_profile/tentacles/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] coils around [target]'s limbs and pins [target.p_them()] beneath its weight!"

/datum/horny_family_profile/tentacles/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] writhes and coils in on itself, thwarted!"

/datum/horny_family_profile/tentacles/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] slackens, its coils going limp as it releases [target] for now." : "[hunter] ripples with a slow, satisfied shudder."

/datum/horny_family_profile/tentacles/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] recoils, then lashes forward!"

/datum/horny_family_profile/tentacles/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] shudders and sinks back toward the earth."

/datum/horny_family_profile/tentacles/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes slack all at once, every tentacle drooping."

/datum/horny_family_profile/tentacles/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts winding sticky resin around [target]'s wrists!",
		"start_target" = "[hunter] starts winding sticky resin around my wrists!",
		"start_hear" = "I hear wet strands stretching tight.",
		"done" = "[hunter] binds [target]'s wrists in clinging resin!",
		"done_target" = "[hunter] binds my wrists in clinging resin!",
		"done_hear" = "I hear resin tightening around someone's wrists.",
	)

/datum/horny_family_profile/tentacles/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	if(hunter.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/tentacle, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/tentacle, 2)
		if(target.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/tentacle, 3)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/tentacle_jerk, 2)

/datum/horny_family_profile/maneaters
	family_flag = HORNY_MOB_TYPE_MANEATERS
	pain_factor = 0.3
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_SINK
	extra_strip_chance = 20
	restraint_type = /obj/item/rope/spider_silk/tentacle_resin

/datum/horny_family_profile/maneaters/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s vines rustle and lean toward [target], petals parting."

/datum/horny_family_profile/maneaters/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] knots its thorny vines around [target] and pins [target.p_them()] against the loam!"

/datum/horny_family_profile/maneaters/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] writhes and coils in on itself, thwarted!"

/datum/horny_family_profile/maneaters/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] slackens, its coils going limp as it releases [target] for now." : "[hunter] ripples with a slow, satisfied shudder."

/datum/horny_family_profile/maneaters/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] recoils, then lashes forward!"

/datum/horny_family_profile/maneaters/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] shudders and sinks back toward the earth."

/datum/horny_family_profile/maneaters/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes slack all at once, every vine drooping."

/datum/horny_family_profile/maneaters/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts winding sticky resin around [target]'s wrists!",
		"start_target" = "[hunter] starts winding sticky resin around my wrists!",
		"start_hear" = "I hear wet strands stretching tight.",
		"done" = "[hunter] binds [target]'s wrists in clinging resin!",
		"done_target" = "[hunter] binds my wrists in clinging resin!",
		"done_hear" = "I hear resin tightening around someone's wrists.",
	)

/datum/horny_family_profile/maneaters/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	if(hunter.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/tentacle/maneater, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/tentacle/maneater, 2)
		if(target.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater, 3)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/tentacle_jerk/maneater, 2)
