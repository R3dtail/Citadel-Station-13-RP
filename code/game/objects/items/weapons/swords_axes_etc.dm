/* Weapons
 * Contains:
 *		Sword
 *		Classic Baton
 *		Telescopic Baton
 */

/*
 * Classic Baton
 */
/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 10
	drop_sound = 'sound/items/drop/crowbar.ogg'
	pickup_sound = 'sound/items/pickup/crowbar.ogg'

/obj/item/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BP_HEAD)
		else
			user.take_organ_damage(2*force)
		return
	return ..()

//Telescopic baton
/obj/item/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton0"
	slot_flags = SLOT_BELT
	w_class = ITEMSIZE_SMALL
	force = 3
	var/on = 0
	var/off_force = 3
	var/on_force = 15
	var/on_pain_force = 30
	drop_sound = 'sound/items/drop/crowbar.ogg'
	pickup_sound = 'sound/items/pickup/crowbar.ogg'

/obj/item/melee/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("<span class='warning'>With a flick of their wrist, [user] extends their telescopic baton.</span>",\
		"<span class='warning'>You extend the baton.</span>",\
		"You hear an ominous click.")
		icon_state = "telebaton1"
		w_class = ITEMSIZE_NORMAL
		force = on_force //quite robust
		attack_verb = list("struck", "beat")
	else
		user.visible_message("<span class='notice'>\The [user] collapses their telescopic baton.</span>",\
		"<span class='notice'>You collapse the baton.</span>",\
		"You hear a click.")
		icon_state = "telebaton0"
		w_class = ITEMSIZE_SMALL
		force = off_force //not so robust now
		attack_verb = list("poked", "jabbed")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, BP_HEAD)
			else
				user.take_organ_damage(2*force)
			return
		var/old_damtype = damtype
		var/old_attack_verb = attack_verb
		var/old_force = force
		if(user.a_intent != INTENT_HARM)
			damtype = HALLOSS
			attack_verb = list("suppressed")
			force = on_pain_force
		. = ..()
		damtype = old_damtype
		attack_verb = old_attack_verb
		force = old_force
	else
		return ..()

/obj/item/melee/disruptor
	name = "disruptor blade"
	desc = "A long, machete-like blade, designed to mount onto the arm or some rough equivalent. Electricity courses through it."
	description_info = "This blade deals bonus damage against animals (space bears, carp) and aberrations (xenomorphs)."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "armblade"
	item_icons = list(
			slot_l_hand_str = 'icons/mob/items/lefthand_material.dmi',
			slot_r_hand_str = 'icons/mob/items/righthand_material.dmi',
			)
	item_state = "armblade"
	force = 15 // same force as a drill
	defend_chance = 20 // did you know melee weapons have a default 5% chance to block frontal melee?
	sharp = TRUE
	edge = TRUE
	var/SA_bonus_damage = 35 // 50 total against animals and aberrations.
	var/SA_vulnerability = MOB_CLASS_ANIMAL | MOB_CLASS_ABERRATION

/obj/item/melee/disruptor/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/tm = target // targeted mob
		if(SA_vulnerability & tm.mob_class)
			tm.apply_damage(SA_bonus_damage) // fuck em

/obj/item/melee/disruptor/borg
	desc = "A long, machete-like blade, designed to mount onto a facility-bound synthetic's chassis."

/obj/item/melee/spike
	name = "jagged spike"
	desc = "A polished spike with miniscule edges all over its surface. You won't be holding onto it for long if you stab someone with it."
	embed_chance = 100 // these should probably come in a bandolier or have some sort of fabricator, tbf
	force = 5 // HAVING A STICK JAMMED INTO YOU IS LIKELY BAD FOR YOUR HEALTH // well to be fair most of the damage comes from the embed not the stab
	w_class = WEIGHT_CLASS_SMALL
	matter = list(DEFAULT_WALL_MATERIAL = 2500)
	sharp = TRUE
	edge = TRUE
	icon_state = "embed_spike"
	item_icons = list(
			slot_l_hand_str = 'icons/mob/items/lefthand_material.dmi',
			slot_r_hand_str = 'icons/mob/items/righthand_material.dmi',
			)
	item_state = "switchblade_open"

//DONATOR ITEM
//okay I know making a stool a weapon is real cringe but the chair material code is fucking bad and I'm tired of fucking with it

/obj/item/melee/stool/faiza
	name = "Faiza's Stool"
	desc = "Apply munchkin cat."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "cn_stool_c"
	force = 10
	throwforce = 10
	w_class = ITEMSIZE_SMALL
	var/on =  0
	slot_flags = null
	force = 0
	hitsound = "sound/items/bikehorn.ogg"

/obj/item/melee/stool/faiza/attack_self(mob/user as mob)

	if(on == 0)
		user.visible_message("<span class='notice'>In a quick motion, [user] extends their collapsible stool.</span>")
		icon_state = "cn_stool"
		w_class = ITEMSIZE_HUGE
		on = 1
	else
		user.visible_message("<span class='notice'>\ [user] collapses their stool.</span>")
		icon_state = "cn_stool_c"
		w_class = ITEMSIZE_SMALL
		on = 0

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)