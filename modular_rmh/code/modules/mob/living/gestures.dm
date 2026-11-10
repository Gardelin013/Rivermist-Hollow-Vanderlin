// Hand gestures shown over the head for right-click intents (taunt, shoo, beckon, wave).
// Only the gesturing mob and its target see them. Ported from Azure Peak / Ratwood.

#define GESTURE_ICON 'modular_rmh/icons/mob/gestures.dmi'
#define GESTURE_DURATION (2 SECONDS)
#define GESTURE_Y_OFFSET 20

/mob/living/proc/show_gesture(mob/target, gesture, y_offset = GESTURE_Y_OFFSET)
	var/list/viewers = list()
	if(client)
		viewers += client
	if(target?.client)
		viewers |= target.client
	if(!length(viewers))
		return

	var/image/gesture_image = image(GESTURE_ICON, src, gesture, ABOVE_ALL_MOB_LAYER)
	// Above lighting, so a gesture made in the dark can still be read.
	gesture_image.plane = ABOVE_LIGHTING_PLANE
	gesture_image.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	gesture_image.pixel_y = y_offset
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		carbon_self.apply_offset(gesture_image, OFFSET_HEAD)
	flick_overlay(gesture_image, viewers, GESTURE_DURATION)

/// Patrons whose followers answer a taunt with the middle finger.
GLOBAL_LIST_INIT(rude_taunt_patrons, typecacheof(list(
	/datum/patron/faerun/evil_gods/Gorellik,
	/datum/patron/faerun/evil_gods/Gruumsh,
	/datum/patron/faerun/evil_gods/Loviatar,
	/datum/patron/faerun/evil_gods/Maglubiyet,
	/datum/patron/faerun/evil_gods/Malar,
	/datum/patron/faerun/evil_gods/Talos,
	/datum/patron/faerun/evil_gods/Umberlee,
)))

/// Patrons too gentle for more than a thumbs down.
GLOBAL_LIST_INIT(gentle_taunt_patrons, typecacheof(list(
	/datum/patron/faerun/good_gods/Eilistraee,
	/datum/patron/faerun/good_gods/Ilmater,
	/datum/patron/faerun/good_gods/Lathander,
	/datum/patron/faerun/good_gods/Selune,
	/datum/patron/faerun/good_gods/Sharess,
	/datum/patron/faerun/good_gods/Sune,
	/datum/patron/faerun/good_gods/Yondalla,
)))

/// The rude, plain or disapproving taunt, depending on who is taunting.
/mob/living/proc/show_taunt_gesture(mob/target)
	// A taunt in the middle of a fight stays a plain chat taunt.
	var/mob/living/living_target = target
	if(cmode || (istype(living_target) && living_target.cmode))
		return
	if(HAS_TRAIT(src, TRAIT_PACIFISM) || is_type_in_typecache(patron, GLOB.gentle_taunt_patrons))
		show_gesture(target, "thumbsdown", GESTURE_Y_OFFSET + 4)
	else if(is_type_in_typecache(patron, GLOB.rude_taunt_patrons) || get_stress_amount() > 10)
		show_gesture(target, "midfinger", GESTURE_Y_OFFSET + 3)
	else
		show_gesture(target, "taunt", GESTURE_Y_OFFSET + 1)

#undef GESTURE_ICON
#undef GESTURE_DURATION
#undef GESTURE_Y_OFFSET
