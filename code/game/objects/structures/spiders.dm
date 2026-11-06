// This shit sucks ass

/*	..................   Spider stuff   ................... */
/obj/structure/spider/attacked_by(obj/item/I, mob/living/user) //Snipping action for webs, scissors turning webs into silk fast!
	if(user.used_intent.type != /datum/intent/snip)
		return ..()
	var/sewing_skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/sewing)
	var/snip_time = 5 SECONDS - (sewing_skill * 10)
	var/amount = rand(1, 2)
	if(!do_after(user, snip_time))
		return TRUE
	for(var/i in 1 to amount)
		new /obj/item/natural/silk (get_turf(src))
	user.visible_message(span_notice("[user] snips [src] up into silk."))
	user.mind.add_sleep_experience(/datum/attribute/skill/misc/sewing, (GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) / 2)) //We're getting experience for harvesting silk!
	playsound(src, 'sound/items/flint.ogg', 100, TRUE)
	qdel(src)
	return TRUE

/obj/structure/spider/stickyweb
	name = "web"
	icon = 'icons/roguetown/misc/webbing.dmi'
	icon_state = "stickyweb1"
	resistance_flags = FLAMMABLE
	alpha = 109
	max_integrity = 50
	opacity = TRUE

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!HAS_TRAIT(mover, TRAIT_WEBWALK) && isliving(mover))
		if(prob(50))
			to_chat(mover, "<span class='danger'>I get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/spider/stickyweb/fire_act(added, maxstacks)
	visible_message("<span class='warning'>[src] catches fire!</span>")
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/effect/hotspot(T)

/obj/structure/spider/stickyweb/solo
	icon_state = "stickyweb3"

/obj/structure/spider/stickyweb/Initialize()
	if(icon_state == "stickyweb1")
		if(prob(50))
			icon_state = "stickyweb2"
	dir = pick(GLOB.cardinals)
	alpha = rand(80,109)
	switch(pick(1,2))
		if (1)
			static_debris = FALSE
		if (2)
			static_debris = list(/obj/item/natural/silk = 1)
	. = ..()

#define SPIDER_COCOON_BREAKOUT_BASE (1 MINUTES)
#define SPIDER_COCOON_BREAKOUT_PER_EGG (15 SECONDS)
#define SPIDER_COCOON_BREAKOUT_MAX (3 MINUTES)
/// A victim who gets out is left alone this long, so an escape is an escape.
#define SPIDER_COCOON_ESCAPE_GRACE (10 MINUTES)
#define SPIDER_COCOON_SEALED_INTEGRITY 80

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon1"
	max_integrity = 40
	/// Pumped full of eggs and sealed; no spider comes back to it.
	var/brooded = FALSE

/obj/structure/spider/cocoon/Initialize(mapload, ...)
	. = ..()
	switch(pick(1,2,3,4,5))
		if(1)
			static_debris = list(/obj/item/natural/silk = 3)
			icon_state = pick("cocoon1","cocoon2")
		if(2)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/remains/bigrat = 1)
			icon_state = pick("cocoon2","cocoon3")
		if(3)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/remains/human = 1)
			icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		if(4)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/cleanable/blood/gibs = 1)
			icon_state = pick("cocoon1","cocoon2","cocoon3")
		if(5)
			static_debris = list(/obj/item/natural/silk = 2, /obj/item/natural/stone = 1)
			icon_state = pick("cocoon1","cocoon2")

/obj/structure/spider/cocoon/Destroy()
	// Whoever is inside spills out rather than being deleted with the silk.
	var/turf/drop_turf = get_turf(src)
	for(var/atom/movable/inside as anything in contents)
		inside.forceMove(drop_turf)
	return ..()

/obj/structure/spider/cocoon/Exited(atom/movable/gone, atom/newLoc)
	. = ..()
	if(isliving(gone))
		var/mob/living/escaped = gone
		escaped.kidnap_protected_until = max(escaped.kidnap_protected_until, world.time + SPIDER_COCOON_ESCAPE_GRACE)

/obj/structure/spider/cocoon/deconstruct(disassembled)
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	var/breakout_time = get_breakout_time(user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>I struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)</span>")
	visible_message("<span class='notice'>I see something struggling and writhing in \the [src]!</span>")
	if(do_after(user, breakout_time, src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/examine(mob/user)
	. = ..()
	if(brooded)
		. += span_warning("It is sealed shut and swollen.")
	var/mob/living/carbon/victim = get_wrapped_victim()
	if(victim)
		. += span_love(get_silk_glimpse(victim))

/// The living carbon wound up inside, or null.
/obj/structure/spider/cocoon/proc/get_wrapped_victim()
	for(var/mob/living/carbon/victim in contents)
		if(victim.stat != DEAD)
			return victim
	return null

/// Winds [victim] inside; the silk slowly knits their wounds so nobody dies in here.
/obj/structure/spider/cocoon/proc/wrap(mob/living/victim)
	// A fresh wrap looks slim and spills only silk; the swollen look is for sealed ones.
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")
	static_debris = list(/obj/item/natural/silk = 2)
	victim.buckled?.unbuckle_mob(victim, TRUE)
	victim.forceMove(src)
	victim.apply_status_effect(/datum/status_effect/buff/healing/spider_cocoon, 0.25)

/// Pumped full: thicker silk, a swollen look, and no spider returns.
/obj/structure/spider/cocoon/proc/seal()
	if(brooded)
		return FALSE
	brooded = TRUE
	max_integrity = SPIDER_COCOON_SEALED_INTEGRITY
	update_integrity(SPIDER_COCOON_SEALED_INTEGRITY)
	icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")
	return TRUE

/// One minute, plus a little for every egg the occupant carries, capped.
/obj/structure/spider/cocoon/proc/get_breakout_time(mob/living/user)
	return min(SPIDER_COCOON_BREAKOUT_BASE + SPIDER_COCOON_BREAKOUT_PER_EGG * count_eggs_inside(user), SPIDER_COCOON_BREAKOUT_MAX)

/// Oviposition eggs carried in every organ of [victim] that can hold them.
/obj/structure/spider/cocoon/proc/count_eggs_inside(mob/living/victim)
	if(!iscarbon(victim))
		return 0
	var/mob/living/carbon/carrier = victim
	var/count = 0
	for(var/obj/item/organ/organ as anything in carrier.internal_organs)
		if(organ.supports_oviposition_pregnancy())
			count += length(organ.get_oviposition_eggs())
	return count

/// One line naming what shows through the silk.
/obj/structure/spider/cocoon/proc/get_silk_glimpse(mob/living/carbon/victim)
	var/list/glimpses = list()
	if(victim.getorganslot(ORGAN_SLOT_BREASTS) && !is_zone_clothed(victim, BODY_ZONE_CHEST))
		glimpses += "bare breasts"
	if(victim.handcuffed)
		glimpses += "bound wrists"
	if(count_eggs_inside(victim))
		glimpses += "a belly full of eggs"
	for(var/obj/item/clothing/face/gear in victim.get_equipped_items())
		var/gear_path = "[gear.type]"
		if(!findtext(gear_path, "/silk"))
			continue
		if(findtext(gear_path, "gag"))
			glimpses += "a mouth packed with silk"
		else if(findtext(gear_path, "blindfold"))
			glimpses += "eyes wound with silk"
	if(!length(glimpses))
		return "Something moves inside the silk."
	return "Through the silk I see [english_list(glimpses)]."

/// TRUE when anything [victim] wears covers [zone].
/obj/structure/spider/cocoon/proc/is_zone_clothed(mob/living/carbon/victim, zone)
	for(var/obj/item/clothing/garment in victim.get_equipped_items())
		if(zone2covered(zone, garment.body_parts_covered))
			return TRUE
	return FALSE

#undef SPIDER_COCOON_BREAKOUT_BASE
#undef SPIDER_COCOON_BREAKOUT_PER_EGG
#undef SPIDER_COCOON_BREAKOUT_MAX
#undef SPIDER_COCOON_ESCAPE_GRACE
#undef SPIDER_COCOON_SEALED_INTEGRITY
