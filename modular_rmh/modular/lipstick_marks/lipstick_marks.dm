// Washable lipstick marks that kisses and mouth acts leave on a partner.

#define LIPSTICK_MARK_ICON 'modular_rmh/modular/lipstick_marks/icons/lipstick_marks.dmi'

/// Kisses on one spot stop counting here; examine reads it as "several".
#define LIPSTICK_MARK_MAX_COUNT 3

// Indexes into one mark entry.
#define LIPSTICK_MARK_COLOR 1
#define LIPSTICK_MARK_ALPHA 2
#define LIPSTICK_MARK_COUNT 3
#define LIPSTICK_MARK_KIND 4

#define LIPSTICK_KIND_KISS "kiss"
#define LIPSTICK_KIND_SMEAR "smear"
#define LIPSTICK_KIND_RING "ring"
#define LIPSTICK_KIND_BITE "bite"

#define LIPSTICK_SPOT_LIPS "lips"
#define LIPSTICK_SPOT_CHEEK "cheek"
#define LIPSTICK_SPOT_FOREHEAD "forehead"
#define LIPSTICK_SPOT_NOSE "nose"
#define LIPSTICK_SPOT_EAR "ear"
#define LIPSTICK_SPOT_NECK "neck"
#define LIPSTICK_SPOT_CHEST "chest"
#define LIPSTICK_SPOT_ARMPIT "armpit"
#define LIPSTICK_SPOT_BELLY "belly"
#define LIPSTICK_SPOT_CROTCH "crotch"
#define LIPSTICK_SPOT_COCK "cock"
#define LIPSTICK_SPOT_BALLS "balls"
#define LIPSTICK_SPOT_BUTT "butt"
#define LIPSTICK_SPOT_L_ARM "l_arm"
#define LIPSTICK_SPOT_R_ARM "r_arm"
#define LIPSTICK_SPOT_L_HAND "l_hand"
#define LIPSTICK_SPOT_R_HAND "r_hand"
#define LIPSTICK_SPOT_L_THIGH "l_thigh"
#define LIPSTICK_SPOT_R_THIGH "r_thigh"
#define LIPSTICK_SPOT_L_FOOT "l_foot"
#define LIPSTICK_SPOT_R_FOOT "r_foot"

/// Spots in head-to-feet order: limb that holds it, zone whose clothing hides it, optional organ and overlay.
GLOBAL_LIST_INIT(lipstick_mark_spots, list(
	LIPSTICK_SPOT_LIPS = list("name" = "lips", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_MOUTH, "face" = TRUE, "state" = "lips", "offset" = OFFSET_FACE),
	LIPSTICK_SPOT_CHEEK = list("name" = "cheek", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_HEAD, "face" = TRUE, "state" = "cheek", "offset" = OFFSET_FACE),
	LIPSTICK_SPOT_FOREHEAD = list("name" = "forehead", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_HEAD, "face" = TRUE, "state" = "forehead", "offset" = OFFSET_FACE),
	LIPSTICK_SPOT_NOSE = list("name" = "nose", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_NOSE, "face" = TRUE),
	LIPSTICK_SPOT_EAR = list("name" = "ear", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_EARS, "face" = TRUE),
	LIPSTICK_SPOT_NECK = list("name" = "neck", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_NECK, "state" = "neck", "offset" = OFFSET_NECK),
	LIPSTICK_SPOT_CHEST = list("name" = "chest", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_CHEST, "state" = "chest", "offset" = OFFSET_NECK),
	LIPSTICK_SPOT_ARMPIT = list("name" = "armpit", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_CHEST),
	LIPSTICK_SPOT_BELLY = list("name" = "belly", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_STOMACH, "state" = "belly", "offset" = OFFSET_NECK),
	LIPSTICK_SPOT_CROTCH = list("name" = "crotch", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN),
	LIPSTICK_SPOT_COCK = list("name" = "cock", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_PENIS),
	LIPSTICK_SPOT_BALLS = list("name" = "balls", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_TESTICLES),
	LIPSTICK_SPOT_BUTT = list("name" = "butt", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "state" = "butt", "offset" = OFFSET_NECK),
	LIPSTICK_SPOT_L_ARM = list("name" = "left arm", "limb" = BODY_ZONE_L_ARM, "cover" = BODY_ZONE_L_ARM, "pair" = LIPSTICK_SPOT_R_ARM, "pair_name" = "arms"),
	LIPSTICK_SPOT_R_ARM = list("name" = "right arm", "limb" = BODY_ZONE_R_ARM, "cover" = BODY_ZONE_R_ARM),
	LIPSTICK_SPOT_L_HAND = list("name" = "left hand", "limb" = BODY_ZONE_L_ARM, "cover" = BODY_ZONE_PRECISE_L_HAND, "pair" = LIPSTICK_SPOT_R_HAND, "pair_name" = "hands"),
	LIPSTICK_SPOT_R_HAND = list("name" = "right hand", "limb" = BODY_ZONE_R_ARM, "cover" = BODY_ZONE_PRECISE_R_HAND),
	LIPSTICK_SPOT_L_THIGH = list("name" = "left thigh", "limb" = BODY_ZONE_L_LEG, "cover" = BODY_ZONE_L_LEG, "pair" = LIPSTICK_SPOT_R_THIGH, "pair_name" = "thighs"),
	LIPSTICK_SPOT_R_THIGH = list("name" = "right thigh", "limb" = BODY_ZONE_R_LEG, "cover" = BODY_ZONE_R_LEG),
	LIPSTICK_SPOT_L_FOOT = list("name" = "left foot", "limb" = BODY_ZONE_L_LEG, "cover" = BODY_ZONE_PRECISE_L_FOOT, "pair" = LIPSTICK_SPOT_R_FOOT, "pair_name" = "feet"),
	LIPSTICK_SPOT_R_FOOT = list("name" = "right foot", "limb" = BODY_ZONE_R_LEG, "cover" = BODY_ZONE_PRECISE_R_FOOT),
))

/// Lipstick spots a targeting-doll zone covers, the main one first.
/proc/get_lipstick_spots_for_zone(zone)
	var/static/list/zone_spots = list(
		BODY_ZONE_PRECISE_MOUTH = list(LIPSTICK_SPOT_LIPS),
		BODY_ZONE_HEAD = list(LIPSTICK_SPOT_CHEEK),
		BODY_ZONE_PRECISE_SKULL = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_R_EYE = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_L_EYE = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_NOSE = list(LIPSTICK_SPOT_NOSE),
		BODY_ZONE_PRECISE_EARS = list(LIPSTICK_SPOT_EAR),
		BODY_ZONE_PRECISE_NECK = list(LIPSTICK_SPOT_NECK),
		BODY_ZONE_CHEST = list(LIPSTICK_SPOT_CHEST, LIPSTICK_SPOT_ARMPIT),
		BODY_ZONE_PRECISE_STOMACH = list(LIPSTICK_SPOT_BELLY),
		BODY_ZONE_PRECISE_GROIN = list(LIPSTICK_SPOT_CROTCH, LIPSTICK_SPOT_COCK, LIPSTICK_SPOT_BALLS, LIPSTICK_SPOT_BUTT),
		BODY_ZONE_L_ARM = list(LIPSTICK_SPOT_L_ARM),
		BODY_ZONE_R_ARM = list(LIPSTICK_SPOT_R_ARM),
		BODY_ZONE_PRECISE_L_HAND = list(LIPSTICK_SPOT_L_HAND),
		BODY_ZONE_PRECISE_R_HAND = list(LIPSTICK_SPOT_R_HAND),
		BODY_ZONE_L_LEG = list(LIPSTICK_SPOT_L_THIGH),
		BODY_ZONE_R_LEG = list(LIPSTICK_SPOT_R_THIGH),
		BODY_ZONE_PRECISE_L_FOOT = list(LIPSTICK_SPOT_L_FOOT),
		BODY_ZONE_PRECISE_R_FOOT = list(LIPSTICK_SPOT_R_FOOT),
	)
	return zone_spots[zone]

/// One phrase for a mark, such as "a red lipstick kiss on her cheek".
/proc/describe_lipstick_mark(list/mark, their, spot_name)
	var/shade = GLOB.lipstick_shades[LOWER_TEXT(mark[LIPSTICK_MARK_COLOR])]
	var/lipstick = shade ? "[shade] lipstick" : "lipstick"
	switch(mark[LIPSTICK_MARK_KIND])
		if(LIPSTICK_KIND_SMEAR)
			return "[lipstick] smeared over [their] [spot_name]"
		if(LIPSTICK_KIND_RING)
			return "a [lipstick] ring around [their] [spot_name]"
		if(LIPSTICK_KIND_BITE)
			return "a [lipstick]-ringed bite on [their] [spot_name]"
	switch(mark[LIPSTICK_MARK_COUNT])
		if(1)
			return "a [lipstick] kiss on [their] [spot_name]"
		if(2)
			return "two [lipstick] kisses on [their] [spot_name]"
	return "several [lipstick] kisses on [their] [spot_name]"

/mob/living/carbon/human
	/// Lipstick left on this body: spot -> list(colour, alpha, count, kind), one entry per spot.
	var/list/lipstick_marks

/// Leaves this mob's lipstick on a partner's spot; TRUE when a mark lands.
/mob/living/proc/leave_lipstick_mark(mob/living/receiver, spot, kind = LIPSTICK_KIND_KISS)
	return FALSE

/mob/living/carbon/human/leave_lipstick_mark(mob/living/receiver, spot, kind = LIPSTICK_KIND_KISS)
	if(!ishuman(receiver) || !can_leave_lipstick())
		return FALSE
	var/mob/living/carbon/human/marked = receiver
	if(!marked.can_take_lipstick_mark(spot))
		return FALSE
	return marked.add_lipstick_mark(spot, lip_color, lip_alpha, kind, src)

/// A kiss on a targeting-doll zone; lips meeting lips mark both mouths.
/mob/living/proc/leave_lipstick_kiss(mob/living/receiver, zone)
	var/list/spots = get_lipstick_spots_for_zone(zone)
	if(!length(spots))
		return FALSE
	. = leave_lipstick_mark(receiver, spots[1], LIPSTICK_KIND_KISS)
	if(spots[1] == LIPSTICK_SPOT_LIPS && receiver.leave_lipstick_mark(src, LIPSTICK_SPOT_LIPS, LIPSTICK_KIND_KISS))
		. = TRUE

/// A bite on a targeting-doll zone.
/mob/living/proc/leave_lipstick_bite(mob/living/receiver, zone)
	var/list/spots = get_lipstick_spots_for_zone(zone)
	if(!length(spots))
		return FALSE
	return leave_lipstick_mark(receiver, spots[1], LIPSTICK_KIND_BITE)

/// Lipstick only rubs off a bare mouth; masks, muzzles and anything held in the teeth but a bite keep it.
/mob/living/carbon/human/proc/can_leave_lipstick()
	if(!lip_style)
		return FALSE
	if(is_mouth_covered() || is_muzzled())
		return FALSE
	if(mouth && !istype(mouth, /obj/item/grabbing/bite))
		return FALSE
	return TRUE

/// Whether the body still has the limb and organ a spot lives on.
/mob/living/carbon/human/proc/has_lipstick_spot(spot)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(!spot_data)
		return FALSE
	var/obj/item/bodypart/limb = get_bodypart(spot_data["limb"])
	if(!limb || limb.skeletonized)
		return FALSE
	var/organ_slot = spot_data["organ"]
	if(organ_slot)
		var/obj/item/organ/organ = getorganslot(organ_slot)
		if(!organ || organ.is_false_organ())
			return FALSE
	return TRUE

/// Lips reach a spot through what the sex panel lets through; heavy armour and worn devices stop them.
/mob/living/carbon/human/proc/can_take_lipstick_mark(spot)
	if(!has_lipstick_spot(spot))
		return FALSE
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(get_sex_covering_garment(spot_data["cover"]))
		return FALSE
	var/organ_slot = spot_data["organ"]
	if(organ_slot && is_organ_slot_blocked(organ_slot))
		return FALSE
	if(spot == LIPSTICK_SPOT_LIPS && is_mouth_covered())
		return FALSE
	return TRUE

/// Bare skin at a spot, by the same clothing check tattoos use; smallclothes hide the groin.
/mob/living/carbon/human/proc/is_lipstick_spot_visible(spot)
	if(!has_lipstick_spot(spot))
		return FALSE
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	var/organ_slot = spot_data["organ"]
	if(organ_slot && is_organ_slot_blocked(organ_slot))
		return FALSE
	if(spot == LIPSTICK_SPOT_LIPS && is_mouth_covered())
		return FALSE
	return get_location_accessible(src, spot_data["cover"], grabs = FALSE, skipundies = FALSE)

/// Records a mark; the spot keeps the newest colour, alpha and kind, and a capped count.
/mob/living/carbon/human/proc/add_lipstick_mark(spot, mark_color, mark_alpha, kind, mob/living/giver)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(!spot_data || !mark_color)
		return FALSE
	LAZYINITLIST(lipstick_marks)
	var/list/mark = lipstick_marks[spot]
	var/changed = FALSE
	if(!mark)
		mark = list(mark_color, mark_alpha, 0, kind)
		lipstick_marks[spot] = mark
		changed = TRUE
	else if(mark[LIPSTICK_MARK_COLOR] != mark_color || mark[LIPSTICK_MARK_ALPHA] != mark_alpha)
		mark[LIPSTICK_MARK_COLOR] = mark_color
		mark[LIPSTICK_MARK_ALPHA] = mark_alpha
		changed = TRUE
	mark[LIPSTICK_MARK_KIND] = kind
	mark[LIPSTICK_MARK_COUNT] = min(mark[LIPSTICK_MARK_COUNT] + 1, LIPSTICK_MARK_MAX_COUNT)
	if(!changed)
		return TRUE
	if(spot_data["state"])
		update_body()
	if(giver && giver != src)
		to_chat(giver, span_notice("I leave [describe_lipstick_mark(mark, "[src]'s", spot_data["name"])]."))
		to_chat(src, span_notice("[giver] leaves [describe_lipstick_mark(mark, "my", spot_data["name"])]."))
	else if(giver)
		to_chat(src, span_notice("I leave [describe_lipstick_mark(mark, "my", spot_data["name"])]."))
	return TRUE

/mob/living/carbon/human/proc/clear_lipstick_mark(spot)
	if(!lipstick_marks?[spot])
		return FALSE
	lipstick_marks -= spot
	UNSETEMPTY(lipstick_marks)
	if(has_lipstick_mark_art(spot))
		update_body()
	return TRUE

/proc/has_lipstick_mark_art(spot)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	return !!spot_data?["state"]

/// Clears every mark on a targeting-doll zone.
/mob/living/carbon/human/proc/clear_lipstick_marks_on_zone(zone)
	. = FALSE
	for(var/spot in get_lipstick_spots_for_zone(zone))
		if(clear_lipstick_mark(spot))
			. = TRUE

/// Water and soap take marks off bare skin, and marks whose limb is gone.
/mob/living/carbon/human/proc/wash_lipstick_marks()
	if(!length(lipstick_marks))
		return FALSE
	var/redraw = FALSE
	. = FALSE
	for(var/spot in lipstick_marks.Copy())
		if(has_lipstick_spot(spot) && !is_lipstick_spot_visible(spot))
			continue
		lipstick_marks -= spot
		. = TRUE
		if(has_lipstick_mark_art(spot))
			redraw = TRUE
	UNSETEMPTY(lipstick_marks)
	if(redraw)
		update_body()

/// Wipes the marks on the wiper's targeted zone off this body; NONE when there is nothing to wipe.
/mob/living/carbon/human/proc/try_wipe_lipstick_mark(obj/item/wiper, mob/living/user)
	var/list/wiped_spots = list()
	for(var/spot in get_lipstick_spots_for_zone(user.zone_selected))
		if(lipstick_marks?[spot] && is_lipstick_spot_visible(spot))
			wiped_spots += spot
	if(!length(wiped_spots))
		return NONE
	var/spot_name = GLOB.lipstick_mark_spots[wiped_spots[1]]["name"]
	if(user == src)
		to_chat(user, span_notice("I wipe the lipstick off my [spot_name] with [wiper]."))
	else
		user.visible_message(span_warning("[user] begins to wipe the lipstick off [src]'s [spot_name] with [wiper]."), \
			span_notice("I begin to wipe the lipstick off [src]'s [spot_name]..."))
		if(!do_after(user, 1 SECONDS, src))
			return ITEM_INTERACT_BLOCKING
		user.visible_message(span_notice("[user] wipes the lipstick off [src]'s [spot_name]."), \
			span_notice("I wipe the lipstick off [src]'s [spot_name]."))
	for(var/spot in wiped_spots)
		clear_lipstick_mark(spot)
	return ITEM_INTERACT_SUCCESS

/// The standard face frame the lips art is drawn for; species with their own lips state have another.
/mob/living/carbon/human/proc/has_standard_face_frame()
	var/datum/species/species = dna?.species
	if(!species)
		return FALSE
	if(get_body_build())
		return TRUE
	return !((gender == MALE) ? species.lips_state_m : species.lips_state_f)

/// BODY_LAYER overlays for marked spots that have art; clothing layers draw over them.
/mob/living/carbon/human/proc/get_lipstick_mark_overlays()
	. = list()
	if(!length(lipstick_marks) || HAS_TRAIT(src, TRAIT_HUSK))
		return
	var/standard_face = has_standard_face_frame()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	var/snouted = istype(head) && head.get_snout_lips("lipstick")
	var/obj/item/bodypart/taur/taur = get_bodypart(BODY_ZONE_TAUR)
	for(var/spot in lipstick_marks)
		var/list/spot_data = GLOB.lipstick_mark_spots[spot]
		var/state = spot_data?["state"]
		if(!state || !has_lipstick_spot(spot))
			continue
		if(spot_data["face"] && (!standard_face || (snouted && spot == LIPSTICK_SPOT_LIPS)))
			continue
		var/list/mark = lipstick_marks[spot]
		var/mutable_appearance/overlay = mutable_appearance(LIPSTICK_MARK_ICON, state, -BODY_LAYER)
		overlay.color = mark[LIPSTICK_MARK_COLOR]
		overlay.alpha = mark[LIPSTICK_MARK_ALPHA]
		apply_offset(overlay, spot_data["offset"])
		if(taur?.body_offset_y)
			overlay.pixel_y += taur.body_offset_y
		. += overlay

/// One examine line for the visible marks on the face, or on the body.
/mob/living/carbon/human/proc/get_lipstick_mark_line(mob/user, list/P, face)
	if(!length(lipstick_marks))
		return null
	var/see_all = isobserver(user)
	var/list/phrases = list()
	var/list/merged = list()
	for(var/spot in GLOB.lipstick_mark_spots)
		var/list/mark = lipstick_marks[spot]
		var/list/spot_data = GLOB.lipstick_mark_spots[spot]
		if(!mark || (spot in merged) || !!spot_data["face"] != !!face)
			continue
		if(!has_lipstick_spot(spot) || (!see_all && !is_lipstick_spot_visible(spot)))
			continue
		var/spot_name = spot_data["name"]
		var/pair = spot_data["pair"]
		var/list/pair_mark = pair ? lipstick_marks[pair] : null
		if(pair_mark && pair_mark[LIPSTICK_MARK_COLOR] == mark[LIPSTICK_MARK_COLOR] && pair_mark[LIPSTICK_MARK_KIND] == mark[LIPSTICK_MARK_KIND] \
			&& has_lipstick_spot(pair) && (see_all || is_lipstick_spot_visible(pair)))
			merged += pair
			spot_name = spot_data["pair_name"]
			var/both_count = min(mark[LIPSTICK_MARK_COUNT] + pair_mark[LIPSTICK_MARK_COUNT], LIPSTICK_MARK_MAX_COUNT)
			mark = list(mark[LIPSTICK_MARK_COLOR], mark[LIPSTICK_MARK_ALPHA], both_count, mark[LIPSTICK_MARK_KIND])
		phrases += describe_lipstick_mark(mark, P[THEIR], spot_name)
	if(!length(phrases))
		return null
	return "[capitalize(P[THEYVE])] [english_list(phrases)]."

/mob/living/carbon/human/proc/get_face_lipstick_mark_lines(mob/user, list/P)
	var/line = get_lipstick_mark_line(user, P, TRUE)
	return line ? list(span_info(line)) : list()

/mob/living/carbon/human/proc/get_body_lipstick_mark_lines(mob/user, list/P)
	var/line = get_lipstick_mark_line(user, P, FALSE)
	return line ? list(line) : list()

/datum/sex_action
	/// Lipstick spots the giving mouth marks each cycle; null leaves none.
	var/list/lipstick_spots
	var/lipstick_kind = LIPSTICK_KIND_SMEAR
	/// The action target's mouth does the work, as in facesitting.
	var/lipstick_from_target = FALSE
	/// Both mouths meet and mark each other.
	var/lipstick_mutual = FALSE

/// Run after each perform; gates live on the giver and the marked spot.
/datum/sex_action/proc/leave_perform_lipstick_marks()
	if(!length(lipstick_spots) || !action_user || !action_target)
		return
	var/mob/living/giver = lipstick_from_target ? action_target : action_user
	var/mob/living/receiver = lipstick_from_target ? action_user : action_target
	for(var/spot in lipstick_spots)
		giver.leave_lipstick_mark(receiver, spot, lipstick_kind)
		if(lipstick_mutual)
			receiver.leave_lipstick_mark(giver, spot, lipstick_kind)

/datum/sex_action/kissing
	lipstick_spots = list(LIPSTICK_SPOT_LIPS)
	lipstick_kind = LIPSTICK_KIND_KISS
	lipstick_mutual = TRUE

/datum/sex_action/penis_head_worship
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_KISS

/datum/sex_action/blowjob
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_RING

/datum/sex_action/sex/throat
	lipstick_spots = list(LIPSTICK_SPOT_COCK)
	lipstick_kind = LIPSTICK_KIND_RING
	lipstick_from_target = TRUE

/datum/sex_action/suck_balls
	lipstick_spots = list(LIPSTICK_SPOT_BALLS)

/datum/sex_action/cunnilingus
	lipstick_spots = list(LIPSTICK_SPOT_CROTCH)

/datum/sex_action/crotch_nuzzle
	lipstick_spots = list(LIPSTICK_SPOT_CROTCH)

/datum/sex_action/rimming
	lipstick_spots = list(LIPSTICK_SPOT_BUTT)

/datum/sex_action/facesitting
	lipstick_spots = list(LIPSTICK_SPOT_BUTT)
	lipstick_from_target = TRUE

/datum/sex_action/suck_nipples
	lipstick_spots = list(LIPSTICK_SPOT_CHEST)

/datum/sex_action/armpit_nuzzle
	lipstick_spots = list(LIPSTICK_SPOT_ARMPIT)

/datum/sex_action/tonguebath
	lipstick_spots = list(LIPSTICK_SPOT_CHEST, LIPSTICK_SPOT_BELLY)

/datum/sex_action/foot_lick
	lipstick_spots = list(LIPSTICK_SPOT_L_FOOT, LIPSTICK_SPOT_R_FOOT)

#undef LIPSTICK_MARK_ICON
#undef LIPSTICK_MARK_MAX_COUNT
#undef LIPSTICK_MARK_COLOR
#undef LIPSTICK_MARK_ALPHA
#undef LIPSTICK_MARK_COUNT
#undef LIPSTICK_MARK_KIND
#undef LIPSTICK_KIND_KISS
#undef LIPSTICK_KIND_SMEAR
#undef LIPSTICK_KIND_RING
#undef LIPSTICK_KIND_BITE
#undef LIPSTICK_SPOT_LIPS
#undef LIPSTICK_SPOT_CHEEK
#undef LIPSTICK_SPOT_FOREHEAD
#undef LIPSTICK_SPOT_NOSE
#undef LIPSTICK_SPOT_EAR
#undef LIPSTICK_SPOT_NECK
#undef LIPSTICK_SPOT_CHEST
#undef LIPSTICK_SPOT_ARMPIT
#undef LIPSTICK_SPOT_BELLY
#undef LIPSTICK_SPOT_CROTCH
#undef LIPSTICK_SPOT_COCK
#undef LIPSTICK_SPOT_BALLS
#undef LIPSTICK_SPOT_BUTT
#undef LIPSTICK_SPOT_L_ARM
#undef LIPSTICK_SPOT_R_ARM
#undef LIPSTICK_SPOT_L_HAND
#undef LIPSTICK_SPOT_R_HAND
#undef LIPSTICK_SPOT_L_THIGH
#undef LIPSTICK_SPOT_R_THIGH
#undef LIPSTICK_SPOT_L_FOOT
#undef LIPSTICK_SPOT_R_FOOT
